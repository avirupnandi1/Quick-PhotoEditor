import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/color_picker.dart';
import 'package:myapp/components/draggable_text.dart';
import 'package:myapp/data/text_data.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:async';

class EditorApp extends StatefulWidget {
  @override
  _EditorAppState createState() => _EditorAppState();
}

class _EditorAppState extends State<EditorApp> {
  List<List<TextData>> textsPerPage = [[], [], []];
  int currentPage = 0;
  int selectedTextIndex = -1;
  double fontSize = 20.0;
  Color selectedColor = Colors.black;
  String selectedFontStyle = 'Roboto';
  PageController _pageController = PageController();
  late TextEditingController _textController;
  Timer? _debounce;

  List<String> backgroundImages = [
    'assets/background1.png',
    'assets/background2.png',
    'assets/background3.png',
  ];

  List<String> fontStyles = [
    'Roboto',
    'Lato',
    'Open Sans',
    'Montserrat',
    'Poppins',
    'Gloria Hallelujah',
    'Handlee'
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    for (int i = 0; i < 3; i++) {
      textsPerPage[i].add(TextData("Existing text ${i + 1}", Offset(50.0, 50.0),
          20.0, Colors.black, 'Roboto', false));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void addText() {
    setState(() {
      textsPerPage[currentPage].add(TextData("New Text", Offset(100.0, 100.0),
          fontSize, selectedColor, selectedFontStyle, false));
      selectedTextIndex = textsPerPage[currentPage].length - 1;
      _updateTextController();
    });
  }

  void _debouncedUpdateText(String newText) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      updateText(newText, fontSize, selectedColor, selectedFontStyle);
    });
  }

  void updateText(
      String newText, double newFontSize, Color newColor, String newFontStyle) {
    if (selectedTextIndex != -1) {
      setState(() {
        TextData textData = textsPerPage[currentPage][selectedTextIndex];
        textData.text = newText;
        textData.fontSize = newFontSize;
        textData.textColor = newColor;
        textData.fontStyle = newFontStyle;
      });
    }
  }

  void deleteText() {
    setState(() {
      if (selectedTextIndex != -1) {
        textsPerPage[currentPage].removeAt(selectedTextIndex);
        selectedTextIndex = -1;
        _updateTextController();
      }
    });
  }

  void _updateTextController() {
    if (selectedTextIndex != -1) {
      _textController.text = textsPerPage[currentPage][selectedTextIndex].text;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    } else {
      _textController.text = '';
    }
  }

  double calculateMaxFontSize(String text, double maxWidth, String fontStyle) {
    double fontSize = 10.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.getFont(fontStyle, fontSize: fontSize),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );

    while (true) {
      textPainter.text = TextSpan(
        text: text,
        style: GoogleFonts.getFont(fontStyle, fontSize: fontSize),
      );
      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines || textPainter.width > maxWidth) {
        return fontSize - 1;
      }

      fontSize += 1;
      if (fontSize > 100) return 100; // Set a maximum font size
    }
  }

  void resizeText(double delta) {
    setState(() {
      if (selectedTextIndex != -1) {
        TextData textData = textsPerPage[currentPage][selectedTextIndex];
        double maxWidth = MediaQuery.of(context).size.width - 40; // Padding
        double maxFontSize =
            calculateMaxFontSize(textData.text, maxWidth, textData.fontStyle);

        double newFontSize =
            (textData.fontSize + delta * 0.5).clamp(10.0, maxFontSize);

        if (currentPage == 2) {
          // For the third page, adjust the vertical position to keep the top center fixed
          double heightDifference = newFontSize - textData.fontSize;
          textData.position = Offset(textData.position.dx,
              textData.position.dy - heightDifference / 2);
        }

        textData.fontSize = newFontSize;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                    selectedTextIndex = -1;
                    _updateTextController();
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTapUp: (details) {
                      setState(() {
                        selectedTextIndex = -1;
                        _updateTextController();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(backgroundImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          for (int i = 0; i < textsPerPage[index].length; i++)
                            DraggableText(
                              textData: textsPerPage[index][i],
                              isSelected: i == selectedTextIndex &&
                                  index == currentPage,
                              onDragEnd: (offset) {
                                setState(() {
                                  textsPerPage[index][i].position = offset;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  selectedTextIndex = i;
                                  _updateTextController();
                                });
                              },
                              onResize: (delta) {
                                resizeText(delta);
                              },
                              screenSize: MediaQuery.of(context).size,
                              pageIndex: index,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Left arrow
              if (currentPage > 0)
                Positioned(
                  left: 10,
                  top: MediaQuery.of(context).size.height / 2 - 25,
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              // Right arrow
              if (currentPage < 2)
                Positioned(
                  right: 10,
                  top: MediaQuery.of(context).size.height / 2 - 25,
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (selectedTextIndex != -1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  onChanged: _debouncedUpdateText,
                  decoration: InputDecoration(labelText: 'Edit Text'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedFontStyle,
                        items: fontStyles.map((style) {
                          return DropdownMenuItem<String>(
                            value: style,
                            child: Text(style),
                          );
                        }).toList(),
                        onChanged: (newStyle) {
                          setState(() {
                            selectedFontStyle = newStyle!;
                            updateText(
                                textsPerPage[currentPage][selectedTextIndex]
                                    .text,
                                fontSize,
                                selectedColor,
                                selectedFontStyle);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: 10.0,
                        max: 40.0,
                        onChanged: (newSize) {
                          setState(() {
                            fontSize = newSize;
                          });
                          updateText(
                              textsPerPage[currentPage][selectedTextIndex].text,
                              newSize,
                              selectedColor,
                              selectedFontStyle);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ColorPicker(
                        onColorChanged: (newColor) {
                          setState(() {
                            selectedColor = newColor;
                          });
                          updateText(
                              textsPerPage[currentPage][selectedTextIndex].text,
                              fontSize,
                              newColor,
                              selectedFontStyle);
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: deleteText,
                      child: const Text('Delete Text'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ElevatedButton(
          onPressed: addText,
          child: const Text(
            'Add Text',
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
        ),
      ],
    );
  }
}
