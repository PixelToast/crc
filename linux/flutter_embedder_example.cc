// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include <linux/limits.h>
#include <unistd.h>

#include <cstdlib>
#include <iostream>
#include <memory>
#include <vector>
#include <iostream>

#include <dlfcn.h>
#include <link.h>

#include <cstring>

#include "malloc.h"

#include "flutter/flutter_window_controller.h"

#define _GLFW_X11
#include "glfw_src/internal.h"

namespace {

std::string GetExecutableDirectory() {
  char buffer[PATH_MAX + 1];
  ssize_t length = readlink("/proc/self/exe", buffer, sizeof(buffer));
  if (length > PATH_MAX) {
    std::cerr << "Couldn't locate executable" << std::endl;
    return "";
  }
  std::string executable_path(buffer, length);
  size_t last_separator_position = executable_path.find_last_of('/');
  if (last_separator_position == std::string::npos) {
    std::cerr << "Unabled to find parent directory of " << executable_path
              << std::endl;
    return "";
  }
  return executable_path.substr(0, last_separator_position);
}

}

struct FlutterDesktopWindow {
    // The GLFW window that (indirectly) owns this state object.
    GLFWwindow* window;

    // Whether or not to track mouse movements to send kHover events.
    bool hover_tracking_enabled = true;

    // The ratio of pixels per screen coordinate for the window.
    double pixels_per_screen_coordinate = 1.0;

    // Resizing triggers a window refresh, but the resize already updates Flutter.
    // To avoid double messages, the refresh after each resize is skipped.
    bool skip_next_window_refresh = false;
};

template<typename T> inline T hs(Elf64_Ehdr* base, unsigned long offset) {
  return reinterpret_cast<T>(reinterpret_cast<unsigned long>(base) + offset);
}

static _GLFWwindow* window;
static _GLFWlibrary* glfw;
static _GLFWcursor* cursor;

flutter::FlutterWindowController* flutter_controller;

static void (*_glfwSetWindowIcon)(_GLFWwindow* window, int count, const GLFWimage* images);

void setCursor(int id) {
  cursor->x11.handle = XCreateFontCursor(glfw->x11.display, id);
  if (!cursor->x11.handle) {
    std::cerr << "x11 handle bork";
    exit(1);
  }

  window->cursor = cursor;

  XDefineCursor(glfw->x11.display, window->x11.handle, window->cursor->x11.handle);
  XFlush(glfw->x11.display);
}

int main(int argc, char **argv) {
  auto flutterDl = dlopen("libflutter_linux.so", RTLD_LAZY);

  if (flutterDl == nullptr) {
    std::cerr << "dlopen failed: " << dlerror() << std::endl;
    return 1;
  }

  auto flutterDlLm = reinterpret_cast<link_map*>(flutterDl);
  auto flutterDlEhdr = reinterpret_cast<Elf64_Ehdr*>(flutterDlLm->l_addr);

  glfw = hs<_GLFWlibrary*>(flutterDlEhdr, 0x1c05830);

  _glfwSetWindowIcon = hs<void (*)(_GLFWwindow*, int, const GLFWimage*)>(flutterDlEhdr, 0x1a51ee0);

  std::string base_directory = GetExecutableDirectory();
  if (base_directory.empty()) {
    base_directory = ".";
  }

  std::string data_directory = base_directory + "/data";
  std::string assets_path = data_directory + "/flutter_assets";
  std::string icu_data_path = data_directory + "/icudtl.dat";

  // Arguments for the Flutter Engine.
  std::vector<std::string> arguments;

  flutter_controller = new flutter::FlutterWindowController(icu_data_path);

  // Start the engine.
  if (!flutter_controller->CreateWindow(800, 600, "Flutter Desktop Example", assets_path, arguments)) {
    return EXIT_FAILURE;
  }

  auto cursorRegistrar = flutter_controller->GetRegistrarForPlugin("cursor");
  auto cursorMessenger = FlutterDesktopRegistrarGetMessenger(cursorRegistrar);
  window = (_GLFWwindow*)flutter_controller->window()->window_->window;

  auto setWindowTitle = hs<void (*)(_GLFWwindow*, const char*)>(flutterDlEhdr, 0x1a51ec0);
  setWindowTitle(window, "OwO What's this?");

  cursor = static_cast<_GLFWcursor*>(calloc(sizeof(_GLFWcursor), 1));

  cursor->next = glfw->cursorListHead;
  glfw->cursorListHead = cursor;

  FlutterDesktopMessengerSetCallback(cursorMessenger, "setCursor", [](
    FlutterDesktopMessengerRef messenger, const FlutterDesktopMessage* message, void* udata
  ) {
    setCursor(*message->message);
  }, nullptr);


  FlutterDesktopMessengerSetCallback(cursorMessenger, "setIcon", [](
    FlutterDesktopMessengerRef messenger, const FlutterDesktopMessage* message, void* udata
  ) {
    std::cout << "Setting icon " << message->message_size << std::endl;

    flutter_controller->window()->SetIcon((uint8_t*)message->message, 64, 64);
  }, nullptr);

  // Run until the window is closed.
  flutter_controller->RunEventLoop();
  return EXIT_SUCCESS;
}
