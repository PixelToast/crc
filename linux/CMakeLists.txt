cmake_minimum_required(VERSION 3.7)
project(circ2)

file(GLOB vm_SRC "./*.h" "./*.cc")

file(GLOB vm_CSRC "./*.h" "./*.cc")

include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/flutter/cpp_client_wrapper/include ${CMAKE_SOURCE_DIR}/flutter)

add_executable(dummy ${vm_SRC})