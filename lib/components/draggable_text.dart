import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:myapp/data/text_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_widget/auto_size_widget.dart';

class DraggableText extends StatelessWidget {
  final TextData textData;
  final bool isSelected;
  final Function(Offset) onDragEnd;
  final Function() onTap;
  final Function(double) onResize;
  final Size screenSize;
  final int pageIndex;

  const DraggableText({
    Key? key,
    required this.textData,
    required this.isSelected,
    required this.onDragEnd,
    required this.onTap,
    required this.onResize,
    required this.screenSize,
    required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxWidth = screenSize.width - 180; // Adjust padding as needed

    return Positioned(
      left: pageIndex == 2
          ? screenSize.width / 2 - maxWidth / 2
          : textData.position.dx,
      top: textData.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (pageIndex == 2) {
            // Only allow vertical movement on the third page
            onDragEnd(Offset(
                textData.position.dx, textData.position.dy + details.delta.dy));
          } else {
            onDragEnd(textData.position + details.delta);
          }
          onDragEnd(textData.position + details.delta);
        },
        onTap: onTap,
        child: Stack(
          children: [
            DottedBorder(
              color: isSelected
                  ? const Color.fromARGB(255, 255, 77, 0)
                  : Colors.transparent,
              strokeWidth: 2,
              dashPattern: [5, 5],
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Container(
                  child: Text(
                    textData.text,
                    style: GoogleFonts.getFont(
                      textData.fontStyle,
                      fontSize: textData.fontSize,
                      color: textData.textColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                right: -20,
                bottom: -20,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    onResize(details.delta.dy);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.zoom_out_map, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
