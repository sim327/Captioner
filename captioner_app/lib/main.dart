import 'dart:ui';
import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color.fromARGB(255, 23, 13, 58),
        scaffoldBackgroundColor: Color.fromARGB(255, 33, 9, 61),
      ),
      home: Home(),
    );
  }
}
