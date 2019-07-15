import 'package:circ2/misc/cursor_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FancyTextField extends StatefulWidget {
  createState() => _FancyTextFieldState();
}

class _FancyTextFieldState extends State<FancyTextField> {
  build(BuildContext context) => Cursor(index: 152, child: ClipRRect(child: Container(
    child: TextField(
      decoration: InputDecoration.collapsed(hintText: null),
      style: Theme.of(context).textTheme.body1.copyWith(
        color: Color(0xFFD8DEE9),
        fontWeight: FontWeight.w100,
      ),
    ),
    color: Color(0xFF303948),
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  ), borderRadius: BorderRadius.circular(4.0)));
}