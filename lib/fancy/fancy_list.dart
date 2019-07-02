import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:example_flutter/fancy/scrollbar.dart';
import 'package:example_flutter/misc/init_scoll_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FancyList extends StatefulWidget {
  FancyList({this.children});
  final List<Widget> children;
  createState() => _FancyListState();
}

class _FancyListState extends State<FancyList> with AfterLayoutMixin<FancyList> {
  ScrollController scrollCtrl;
  ScrollMetrics _metrics;

  double get getScrollInside => _metrics.maxScrollExtent + _metrics.viewportDimension;

  initState() {
    super.initState();

    scrollCtrl = InitScrollController((offset) {
      // _metrics = offset;
    });
  }

  build(BuildContext context) => Row(children: [
    Expanded(child: NotificationListener<ScrollNotification>(child: ListView(
      physics: NeverScrollableScrollPhysics(),
      children: widget.children,
      controller: scrollCtrl,
    ), onNotification: (ScrollNotification nf) {
      Future.microtask(() => setState(() {
        _metrics = nf.metrics;
      }));
      return true;
    })),

    FancyScrollbar(_metrics, onScroll: (dt) {
      scrollCtrl.jumpTo(max(0, min(_metrics.maxScrollExtent, dt * _metrics.maxScrollExtent)));
    }),
  ]);

  afterFirstLayout(BuildContext context) {
    setState(() {
      _metrics = scrollCtrl.position;
    });
  }
}