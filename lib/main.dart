import 'package:example_flutter/misc/cursor_manager.dart';
import 'package:example_flutter/windows/editor.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  timeDilation = 1;
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(CursorManager(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EditorWindow(),
    theme: ThemeData(
      fontFamily: "Noto Sans",
    ),
  )));
}