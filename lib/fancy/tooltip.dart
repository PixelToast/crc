import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FancyTooltip extends StatefulWidget {
  FancyTooltip({@required this.child, @required this.message, this.forceClose = false});
  final bool forceClose;
  final Widget child;
  final String message;
  createState() => _FancyTooltipState();
}

class _FancyTooltipState extends State<FancyTooltip> with SingleTickerProviderStateMixin {
  OverlayEntry _entry;
  AnimationController _animation;
  var _target = ValueNotifier<Offset>(null);
  var _link = LayerLink();

  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    if (widget.forceClose && !old.forceClose) _hideTooltip();
  }

  initState() {
    super.initState();
    _animation = AnimationController(vsync: this);
  }

  void _updateTarget() {
    final RenderBox box = context.findRenderObject();
    _target.value = box.size.centerRight(Offset.zero);
  }

  void _showTooltip() {
    if (widget.forceClose) return;
    _animation.animateTo(1, duration: Duration(milliseconds: 50));

    if (_entry != null) return;

    _updateTarget();

    final Widget overlay = _FancyTooltipOverlay(
      message: widget.message,
      animation: _animation,
      target: _target,
      link: _link,
    );

    _entry = OverlayEntry(builder: (ctx) => overlay);

    Overlay.of(context).insert(_entry);
  }

  void _hideTooltip() {
    if (_entry == null) return;
    _animation.animateTo(0, duration: Duration(milliseconds: widget.forceClose ? 50 : 150));
  }

  build(BuildContext context) => CompositedTransformTarget(child: Listener(
    child: widget.child,
    onPointerEnter: (e) => _showTooltip(),
    onPointerExit: (e) => _hideTooltip(),
  ), link: _link);

  dispose() {
    super.dispose();
    _entry?.remove();
    _entry = null;
  }
}

class _FancyTooltipOverlay extends StatelessWidget {
  _FancyTooltipOverlay({this.message, this.target, this.link, this.animation});
  final String message;
  final ValueNotifier<Offset> target;
  final LayerLink link;
  final Animation<double> animation;

  build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ValueListenableBuilder<Offset>(
          valueListenable: target,
          builder: (ctx, val, child) => CompositedTransformFollower(
            link: link,
            offset: val,
            showWhenUnlinked: false,
            child: CustomSingleChildLayout(
              delegate: _FancyTooltipPositionDelegate(offset: val),
              child: child,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Text(message, style: Theme.of(context).textTheme.body2.apply(
                  color: Color(0xFFD8DEE9),
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FancyTooltipPositionDelegate extends SingleChildLayoutDelegate {
  _FancyTooltipPositionDelegate({this.offset});

  final Offset offset;

  getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  getPositionForChild(Size size, Size childSize) => -childSize.centerLeft(Offset.zero);

  shouldRelayout(_FancyTooltipPositionDelegate oldDelegate) => false;
}

Tooltip x;