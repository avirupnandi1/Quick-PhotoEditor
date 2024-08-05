import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;

  ColorPicker({required this.onColorChanged});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color selectedColor;

  final List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = colors[0];
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Color>(
      value: selectedColor,
      onChanged: (Color? newValue) {
        if (newValue != null) {
          setState(() {
            selectedColor = newValue;
          });
          widget.onColorChanged(newValue);
        }
      },
      items: colors.map<DropdownMenuItem<Color>>((Color color) {
        return DropdownMenuItem<Color>(
          value: color,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10),
              Text(colorToString(color)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String colorToString(Color color) {
    if (color == Colors.black) return 'Black';
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.green) return 'Green';
    if (color == Colors.cyan) return 'Cyan';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.orange) return 'Orange';

    return 'Unknown';
  }
}
