import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:image/image.dart' as pimg;

class CursorAnnotation {
  CursorAnnotation(this.index);
  int index;
}

class Cursor extends StatelessWidget {
  Cursor({@required this.child, @required this.index});
  final Widget child;
  final int index;

  build(BuildContext context) => AnnotatedRegion(
    child: child,
    value: CursorAnnotation(index),
  );
}


class CursorManager extends StatefulWidget {
  CursorManager(this.child);
  final Widget child;
  createState() => _CursorManagerState();
}

class _CursorManagerState extends State<CursorManager> {
  static const cursor = const MethodChannel('cursor');

  var key = GlobalKey();

  int currentCursor = 68;

  void updateCursor(Offset pos) {
    RenderBox ro = key.currentContext.findRenderObject();
    var c = ro.layer.find<CursorAnnotation>(pos);

    int lastCursor = currentCursor;

    if (c != null) {
      currentCursor = c.index;
    } else {
      currentCursor = 68;
    }

    if (currentCursor != lastCursor) {
      cursor.binaryMessenger.send("setCursor", Uint8List.fromList([currentCursor]).buffer.asByteData());
    }
  }

  build(BuildContext context) => Listener(
    child: RepaintBoundary(key: key, child: widget.child),
    onPointerMove: (e) => updateCursor(e.localPosition),
    onPointerHover: (e) => updateCursor(e.localPosition),
  );
}
