import 'package:flutter/material.dart';
import 'package:myapp/editor_app.dart';

// ignore: use_key_in_widget_constructors
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editor App'),
      ),
      body: EditorApp(),
    );
  }
}
