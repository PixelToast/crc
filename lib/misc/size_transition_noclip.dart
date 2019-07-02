import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class SizeTransitionNoClip extends AnimatedWidget {
  const SizeTransitionNoClip({
    Key key,
    this.axis = Axis.vertical,
    @required Animation<double> sizeFactor,
    this.axisAlignment = 0.0,
    this.child,
  }) : assert(axis != null),
        assert(sizeFactor != null),
        assert(axisAlignment != null),
        super(key: key, listenable: sizeFactor);

  final Axis axis;

  Animation<double> get sizeFactor => listenable;

  final double axisAlignment;

  final Widget child;

  build(BuildContext context) {
    AlignmentDirectional alignment;
    if (axis == Axis.vertical)
      alignment = AlignmentDirectional(-1.0, axisAlignment);
    else
      alignment = AlignmentDirectional(axisAlignment, -1.0);
    return Container(
      child: Align(
        alignment: alignment,
        heightFactor: axis == Axis.vertical ? math.max(sizeFactor.value, 0.0) : null,
        widthFactor: axis == Axis.horizontal ? math.max(sizeFactor.value, 0.0) : null,
        child: child,
      ),
    );
  }
}