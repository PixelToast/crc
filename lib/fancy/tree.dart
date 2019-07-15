import 'dart:collection';
import 'dart:math';

import 'package:circ2/fancy/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TreeElement extends StatelessWidget {
  TreeElement(this.icon, this.title);
  final IconData icon;
  final String title;
  build(BuildContext context) => FancyButton(child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    if (icon != null)
      Padding(child: Icon(icon, size: 16, color: Color(0xFFD8DEE9)), padding: EdgeInsets.only(right: 6)),
    Text(title, style: TextStyle(color: Color(0xFFD8DEE9), fontWeight: FontWeight.normal)),
  ]),
    padding: EdgeInsets.all(1),
    innerPadding: EdgeInsets.only(top: 0, bottom: 2, left: 8),
  );
}


class TreeList extends StatefulWidget {
  TreeList({@required this.title, @required this.children});
  final String title;
  final List<Widget> children;
  createState() => _TreeListState();
}

class _TreeListState extends State<TreeList> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  AnimationController _expandCtrl;

  initState() {
    super.initState();
    _expandCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
  }

  build(BuildContext context) => Column(children: [
    FancyButton(
      color: Color(0xFFD8DEE9),
      iconSize: 16,
      innerPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.all(1),
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
        _expandCtrl.animateTo(_expanded ? 1.0 : 0.0, curve: Curves.fastLinearToSlowEaseIn);
      },
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(_expanded ? Icons.folder_open : Icons.folder),
        Padding(padding: EdgeInsets.only(right: 6)),
        Expanded(child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD8DEE9), fontSize: 14))),
      ]
    )),

    SizeTransition(
      child: AnimatedOpacity(child: Padding(
        child: Padding(child: Column(children: widget.children), padding: EdgeInsets.only(bottom: 4)),
        padding: EdgeInsets.only(left: 14),
      ), opacity: _expanded ? 1.0 : 0.0, duration: Duration(milliseconds: 100)),
      sizeFactor: _expandCtrl,
      axisAlignment: -0.5,
    ),
  ]);
}

Scrollbar s;