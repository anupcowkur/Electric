import 'package:flutter/material.dart';

void main() {
  runApp(LightningApp());
}

class LightningApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lightning',
      home: Lightning(),
    );
  }
}

class Lightning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Text("Hi"),
    );
  }
}
