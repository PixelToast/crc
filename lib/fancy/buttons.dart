import 'package:example_flutter/misc/color_anim.dart';
import 'package:example_flutter/misc/cursor_manager.dart';
import 'package:flutter/widgets.dart';

class FancyButton extends StatefulWidget {
  FancyButton({
    this.child,
    this.iconSize = 24,
    this.color,
    this.padding = const EdgeInsets.all(2),
    this.borderRadius = 4,
    this.innerPadding,
    this.onTap,
  });

  final Widget child;
  final double iconSize;
  final EdgeInsets padding;
  final double borderRadius;
  final EdgeInsets innerPadding;
  final VoidCallback onTap;
  final Color color;

  createState() => _FancyButtonState();
}

class _FancyButtonState extends State<FancyButton> with SingleTickerProviderStateMixin {
  ColorAnimator _hover;

  initState() {
    super.initState();
    _hover = ColorAnimator(vsync: this, value: Color(0x00D8DEE9));
  }

  bool hovered = false;
  bool pressed = false;

  void updateColor() {
    if (pressed) {
      _hover.animateTo(Color(0x06D8DEE9), duration: Duration(milliseconds: 50));
    } else if (hovered) {
      _hover.animateTo(Color(0x0AD8DEE9), duration: Duration(milliseconds: 50));
    } else {
      _hover.animateTo(Color(0x00D8DEE9), duration: Duration(milliseconds: 150));
    }
  }

  build(BuildContext context) => Cursor(index: 58, child: Listener(child: GestureDetector(
    child: Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedBuilder(
          animation: _hover.ctrl,
            child: IconTheme.merge(
              data: IconThemeData(size: widget.iconSize, color: widget.color),
              child: widget.child,
            ),
          builder: (ctx, child) => Container(
            color: _hover.value,
            child: child,
            padding: widget.innerPadding,
          ),
        ),
      ),
    ),
    onTap: widget.onTap,
    onTapDown: (e) {
      pressed = true;
      updateColor();
    },
    onTapUp: (e) {
      pressed = false;
      updateColor();
    },
    onTapCancel: () {
      pressed = false;
      updateColor();
    },
    behavior: HitTestBehavior.opaque,
  ),
    onPointerEnter: (e) {
      hovered = true;
      updateColor();
    },
    onPointerExit: (e) {
      hovered = false;
      updateColor();
    },
    behavior: HitTestBehavior.opaque,
  ));
}

