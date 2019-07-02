import 'package:flutter/widgets.dart';

typedef InitScrollControllerCallback = void Function(ScrollPosition position);

class InitScrollController extends ScrollController {
  InitScrollController(this.onAttach, {
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String debugLabel,
  }) : super(
    initialScrollOffset: initialScrollOffset,
    keepScrollOffset: keepScrollOffset,
    debugLabel: debugLabel,
  );

  InitScrollControllerCallback onAttach;

  void attach(ScrollPosition position) {
    onAttach(position);
    super.attach(position);
  }
}