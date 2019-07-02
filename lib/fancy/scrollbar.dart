import 'package:example_flutter/misc/color_anim.dart';
import 'package:flutter/widgets.dart';

typedef OnScrollCallback = void Function(double delta);

class FancyScrollbar extends StatefulWidget {
  FancyScrollbar(this.metrics, {@required this.onScroll});
  final ScrollMetrics metrics;
  final OnScrollCallback onScroll;
  createState() => _FancyScrollbarState();
}

class _FancyScrollbarState extends State<FancyScrollbar> with SingleTickerProviderStateMixin {
  ColorAnimator _thumb;

  initState() {
    super.initState();
    _thumb = ColorAnimator(vsync: this, value: Color(0x50D8DEE9));
  }

  void updateThumb() {
    if (dragging) {
      _thumb.animateTo(Color(0x80D8DEE9), duration: Duration(milliseconds: 50));
    } else if (hovering) {
      _thumb.animateTo(Color(0xC0D8DEE9), duration: Duration(milliseconds: 50));
    } else {
      _thumb.animateTo(Color(0x50D8DEE9), duration: Duration(milliseconds: 150));
    }
  }

  bool dragging = false;
  bool hovering = false;

  double dragOffset = 0.0;

  GlobalKey thumbKey = GlobalKey();

  double get getScrollInside => widget.metrics.maxScrollExtent + widget.metrics.viewportDimension;

  build(BuildContext context) => LayoutBuilder(builder: (ctx, cns) {
    return Container(
      width: 16,
      child: widget.metrics == null || getScrollInside <= cns.maxHeight ? Container() : Column(children: [Expanded(child: FractionallySizedBox(
        child: Listener(child: GestureDetector(child: AnimatedBuilder(
          animation: _thumb.ctrl,
          builder: (ctx, child) => Container(child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(color: _thumb.value),
          ), padding: EdgeInsets.all(4), key: thumbKey),
        ),
          onVerticalDragStart: (d) {
            dragging = true;
            updateThumb();
            RenderBox tro = thumbKey.currentContext.findRenderObject();
            dragOffset = tro.localToGlobal(Offset.zero).dy - d.globalPosition.dy;
          },
          onVerticalDragUpdate: (d) {
            RenderBox ro = context.findRenderObject();
            RenderBox tro = thumbKey.currentContext.findRenderObject();
            widget.onScroll((dragOffset + d.globalPosition.dy - ro.localToGlobal(Offset.zero).dy) / (ro.size.height - tro.size.height));
          },
          onVerticalDragEnd: (e) {
            dragging = false;
            updateThumb();
          },
          behavior: HitTestBehavior.opaque,
        ),
          onPointerEnter: (e) {
            hovering = true;
            updateThumb();
          },
          onPointerExit: (e) {
            hovering = false;
            updateThumb();
          },
        ),
        widthFactor: 1.0,
        heightFactor: cns.maxHeight / getScrollInside,
        alignment: Alignment(0.0, (widget.metrics.pixels / widget.metrics.maxScrollExtent) * 2 - 1),
      ))]),
    );
  });
}