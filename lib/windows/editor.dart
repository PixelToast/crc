import 'dart:convert';
import 'dart:typed_data';

import 'package:example_flutter/fancy/buttons.dart';
import 'package:example_flutter/fancy/fancy_list.dart';
import 'package:example_flutter/fancy/tooltip.dart';
import 'package:example_flutter/fancy/tree.dart';
import 'package:example_flutter/misc/size_transition_noclip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EditorWindow extends StatefulWidget {
  createState() => _EditorWindowState();
}

class _EditorWindowState extends State<EditorWindow> with SingleTickerProviderStateMixin {

  List<GlobalKey<_EditorPanelWrapperState>> panels;
  List<GlobalKey<_EditorPanelBtnWrapperState>> panelBtns;

  List<Widget> panelWidgets;
  List<int> panelOrder;

  initState() {
    super.initState();
    panels = [GlobalKey(), GlobalKey(), GlobalKey()];
    panelBtns = [GlobalKey(), GlobalKey(), GlobalKey()];
    panelOrder = List.generate(3, (i) => i);
    panelWidgets = [
      EditorPanelWrapper(ComponentsPanel(), key: panels[0], onClose: () => contractSlide(0)),
      EditorPanelWrapper(ProjectPanel(), key: panels[1], onClose: () => contractSlide(1)),
      EditorPanelWrapper(SettingsPanel(), key: panels[2], onClose: () => contractSlide(2)),
    ];
  }

  void expandSlide(int i) {
    panels[i].currentState.expand();
    panelBtns[i].currentState.collapse();
    setState(() {
      panelOrder.remove(i);
      panelOrder.add(i);
    });
  }

  void contractSlide(int i) {
    panels[i].currentState.collapse();
    panelBtns[i].currentState.expand();
  }

  build(context) {
    return Material(color: Color(0xFF202632), child: Stack(children: [
      Positioned(
        top: 0, left: 0, bottom: 0, child: Row(children: [
          for (int i in panelOrder) panelWidgets[i],
          ClipRect(child: Column(children: [
            Padding(padding: EdgeInsets.only(top: 4)),
            EditorPanelBtnWrapper(icon: Icons.developer_board, title: "Components", key: panelBtns[0], onTap: () => expandSlide(0)),
            EditorPanelBtnWrapper(icon: MdiIcons.packageVariant, title: "Project", key: panelBtns[1], onTap: () => expandSlide(1)),
            EditorPanelBtnWrapper(icon: Icons.settings_applications, title: "Settings", key: panelBtns[2], onTap: () => expandSlide(2)),
          ])),
        ]),
      ),
    ]));
  }
}

class EditorPanelBtnWrapper extends StatefulWidget {
  EditorPanelBtnWrapper({this.onTap, this.title, this.icon, Key key}) : super(key: key);
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  createState() => _EditorPanelBtnWrapperState();
}

class _EditorPanelBtnWrapperState extends State<EditorPanelBtnWrapper> with SingleTickerProviderStateMixin {
  AnimationController _expand;
  bool expanded = true;

  void expand() {
    _expand.animateTo(1, curve: Curves.ease);
    setState(() {
      expanded = true;
    });
  }

  void collapse() {
    _expand.animateTo(0, curve: Curves.ease);
    setState(() {
      expanded = false;
    });
  }

  initState() {
    super.initState();
    _expand = AnimationController(vsync: this, duration: Duration(milliseconds: 150), value: 1);
  }

  build(BuildContext context) => SlideTransition(child: AnimatedOpacity(
    child: SizeTransitionNoClip(
      child: FancyTooltip(child: FancyButton(
        color: Color(0xFFD8DEE9),
        onTap: widget.onTap,
        child: Icon(widget.icon),
        iconSize: 24,
        innerPadding: EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ), message: widget.title, forceClose: !expanded),
      sizeFactor: _expand,
      axis: Axis.vertical,
    ),
    opacity: expanded ? 1 : 0,
    duration: Duration(milliseconds: 150),
  ), position: Tween(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)).animate(_expand));
}


class EditorPanelWrapper extends StatefulWidget {
  EditorPanelWrapper(this.panel, {this.onClose, Key key}) : super(key: key);
  final VoidCallback onClose;
  final Widget panel;
  createState() => _EditorPanelWrapperState();
}

class _EditorPanelWrapperState extends State<EditorPanelWrapper> with SingleTickerProviderStateMixin {
  AnimationController _expand;

  initState() {
    super.initState();
    _expand = AnimationController(vsync: this, duration: Duration(milliseconds: 150), value: 0);
  }

  void expand() {
    _expand.animateTo(1, curve: Curves.ease);
  }

  void collapse() {
    _expand.animateTo(0, curve: Curves.ease);
  }

  build(BuildContext context) => NotificationListener<EditorCloseNotification>(
    child: SizeTransition(
      //axisAlignment: 1,
      child: Container(child: widget.panel, decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF28303D))),
      )),
      sizeFactor: _expand,
      axis: Axis.horizontal,
    ),
    onNotification: (n) {
      widget.onClose();
      return true;
    },
  );
}

class EditorCloseNotification extends Notification {}

class ComponentsPanel extends StatelessWidget {
  build(BuildContext context) {
    void collapse() {
      EditorCloseNotification().dispatch(context);
    }

    return GestureDetector(child: SizedBox(width: 300, child: Material(color: Color(0xFF303948), child: Column(children: [
      Row(children: [
        Padding(padding: EdgeInsets.only(left: 8)),
        Expanded(child: Text("Components", style: TextStyle(color: Color(0xFFD8DEE9), fontSize: 14))),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          //FancyButton(child: Icon(MdiIcons.arrowCollapseVertical, color: Color(0xFFD8DEE9)), onTap: collapse),
          FancyButton(child: Icon(Icons.remove, color: Color(0xFFD8DEE9)), onTap: collapse),
        ]),
      ]),
      Expanded(child: Container(width: 300, color: Color(0xFF384152), child:
      Padding(child: FancyList(children: [Column(children: [
        Padding(padding: EdgeInsets.only(top: 4)),

        TreeList(title: "Circuits", children: [
          TreeElement(Icons.developer_board, "Main"),
          TreeElement(Icons.developer_board, "CPU"),
          TreeElement(Icons.developer_board, "ALU"),
          TreeElement(Icons.developer_board, "Instruction Decoder"),
          TreeElement(Icons.developer_board, "XBus"),
          TreeElement(Icons.developer_board, "Memory Controller"),
        ]),

        TreeList(title: "Wiring", children: [
          TreeElement(Icons.call_split, "Splitter"),
          TreeElement(MdiIcons.mapMarker, "Pin"),
          TreeElement(MdiIcons.cardText, "Probe"),
          TreeElement(MdiIcons.rayStartEnd, "Tunnel"),
          TreeElement(MdiIcons.resistor, "Pull Resistor"),
          TreeElement(MdiIcons.chartHistogram, "Clock"),
          TreeElement(MdiIcons.contrast, "Constant"),
          TreeElement(MdiIcons.power, "Power"),
          TreeElement(MdiIcons.powerOff, "Ground"),
          TreeElement(MdiIcons.lightSwitch, "Transistor"),
          TreeElement(MdiIcons.lightSwitch, "Transmission Gate"),
          TreeElement(Icons.call_split, "Bit Extender"),
        ]),

        TreeList(title: "Gates", children: [
          TreeElement(MdiIcons.gateNot, "NOT Gate"),
          TreeElement(MdiIcons.gateOr, "Buffer"),
          TreeElement(MdiIcons.gateAnd, "AND Gate"),
          TreeElement(MdiIcons.gateOr, "OR Gate"),
          TreeElement(MdiIcons.gateNand, "NAND Gate"),
          TreeElement(MdiIcons.gateXor, "XOR Gate"),
          TreeElement(MdiIcons.gateXnor, "XNOR Gate"),
          TreeElement(MdiIcons.dipSwitch, "Odd Parity"),
          TreeElement(MdiIcons.dipSwitch, "Even Parity"),
          TreeElement(MdiIcons.dipSwitch, "Controlled Buffer"),
        ]),

        TreeList(title: "Plexers", children: [
          TreeElement(MdiIcons.dipSwitch, "Multiplexer"),
          TreeElement(MdiIcons.dipSwitch, "Demultiplexer"),
          TreeElement(MdiIcons.dipSwitch, "Decoder"),
          TreeElement(MdiIcons.dipSwitch, "Priority Encoder"),
          TreeElement(MdiIcons.dipSwitch, "Bit Selector"),
        ]),

        TreeList(title: "Arithmetic", children: [
          TreeElement(MdiIcons.dipSwitch, "Adder"),
          TreeElement(MdiIcons.dipSwitch, "Subtractor"),
          TreeElement(MdiIcons.dipSwitch, "Multiplier"),
          TreeElement(MdiIcons.dipSwitch, "Divider"),
          TreeElement(MdiIcons.dipSwitch, "Negator"),
          TreeElement(MdiIcons.dipSwitch, "Comparator"),
          TreeElement(MdiIcons.dipSwitch, "Shifter"),
          TreeElement(MdiIcons.dipSwitch, "Bit Adder"),
          TreeElement(MdiIcons.dipSwitch, "Bit Finder"),
          TreeElement(MdiIcons.dipSwitch, "Pow"),
        ]),

        TreeList(title: "Memory", children: [
          TreeElement(MdiIcons.dipSwitch, "D Latch"),
          TreeElement(MdiIcons.dipSwitch, "T Latch"),
          TreeElement(MdiIcons.dipSwitch, "JK Latch"),
          TreeElement(MdiIcons.dipSwitch, "SR Latch"),
          TreeElement(MdiIcons.dipSwitch, "Register"),
          TreeElement(MdiIcons.dipSwitch, "Counter"),
          TreeElement(MdiIcons.dipSwitch, "Shift Register"),
          TreeElement(MdiIcons.dipSwitch, "Random Generator"),
          TreeElement(MdiIcons.dipSwitch, "RAM"),
          TreeElement(MdiIcons.dipSwitch, "ROM"),
        ]),

        TreeList(title: "Input / Output", children: [
          TreeElement(MdiIcons.dipSwitch, "Button"),
          TreeElement(MdiIcons.dipSwitch, "Joystick"),
          TreeElement(MdiIcons.dipSwitch, "Keyboard"),
          TreeElement(MdiIcons.dipSwitch, "LED"),
          TreeElement(MdiIcons.dipSwitch, "7 Segment Display"),
          TreeElement(MdiIcons.dipSwitch, "Hex Display"),
          TreeElement(MdiIcons.dipSwitch, "LED Matrix"),
          TreeElement(MdiIcons.dipSwitch, "TTY"),
        ]),

        Padding(padding: EdgeInsets.only(top: 4)),
      ])]), padding: EdgeInsets.only(left: 4)),
      )),
    ]))), behavior: HitTestBehavior.opaque);
  }
}

class ProjectPanel extends StatelessWidget {
  build(BuildContext context) {
    void collapse() {
      EditorCloseNotification().dispatch(context);
    }

    return GestureDetector(child: SizedBox(width: 300, child: Material(color: Color(0xFF303948), child: Column(children: [
      Row(children: [
        Padding(padding: EdgeInsets.only(left: 8)),
        Expanded(child: Text("Project", style: TextStyle(color: Color(0xFFD8DEE9), fontSize: 14))),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          //FancyButton(child: Icon(MdiIcons.arrowCollapseVertical, color: Color(0xFFD8DEE9)), onTap: collapse),
          FancyButton(child: Icon(Icons.remove, color: Color(0xFFD8DEE9)), onTap: collapse),
        ]),
      ]),
      Expanded(child: Container(width: 300, color: Color(0xFF384152), child:
      Padding(child: FancyList(children: [Column(children: [
        Padding(padding: EdgeInsets.only(top: 32)),

        Row(children: [Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(MdiIcons.packageVariant, size: 128, color: Color(0xFFD8DEE9)),
        ]))]),

        Padding(padding: EdgeInsets.only(top: 4)),
      ])]), padding: EdgeInsets.only(left: 4)),
      )),
    ]))), behavior: HitTestBehavior.opaque);
  }
}

class SettingsPanel extends StatelessWidget {
  build(BuildContext context) {
    void collapse() {
      EditorCloseNotification().dispatch(context);
    }

    return GestureDetector(child: SizedBox(width: 300, child: Material(color: Color(0xFF303948), child: Column(children: [
      Row(children: [
        Padding(padding: EdgeInsets.only(left: 8)),
        Expanded(child: Text("Settings", style: TextStyle(color: Color(0xFFD8DEE9), fontSize: 14))),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          //FancyButton(child: Icon(MdiIcons.arrowCollapseVertical, color: Color(0xFFD8DEE9)), onTap: collapse),
          FancyButton(child: Icon(Icons.remove, color: Color(0xFFD8DEE9)), onTap: collapse),
        ]),
      ]),
      Expanded(child: Container(width: 300, color: Color(0xFF384152), child:
      Padding(child: FancyList(children: [Column(children: [
        Padding(padding: EdgeInsets.only(top: 32)),

        Row(children: [Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(MdiIcons.settingsBox, size: 128, color: Color(0xFFD8DEE9)),
        ]))]),

        Padding(padding: EdgeInsets.only(top: 4)),
      ])]), padding: EdgeInsets.only(left: 4)),
      )),
    ]))), behavior: HitTestBehavior.opaque);
  }
}
