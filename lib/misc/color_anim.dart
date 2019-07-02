import 'package:flutter/widgets.dart';

class ColorAnimator {
  ColorAnimator({
    @required TickerProvider vsync,
    Color value = const Color(0),
    Duration duration,
  }) {
    ctrl = AnimationController(vsync: vsync);
    assert (value != null);
    tween = ColorTween(begin: value, end: value);
  }

  AnimationController ctrl;
  ColorTween tween;

  Color get value => tween.animate(ctrl).value;

  set value(Color value) {
    assert (value != null);
    ctrl.value = 0;
    tween = ColorTween(begin: value, end: value);
  }

  TickerFuture animateTo(Color color, {Duration duration, Curve curve = Curves.linear}) {
    assert (color != null);
    tween = ColorTween(begin: value, end: color);
    ctrl.value = 0;
    if (tween.begin != tween.end) {
      return ctrl.animateTo(1.0, duration: duration, curve: curve);
    }
    return TickerFuture.complete();
  }
}