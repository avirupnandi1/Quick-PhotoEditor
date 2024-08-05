import 'package:flutter/material.dart';

class TextData {
  String text;
  Offset position;
  double fontSize;
  Color textColor;
  String fontStyle;
  bool isEditing;

  TextData(this.text, this.position, this.fontSize, this.textColor,
      this.fontStyle, this.isEditing);
}
