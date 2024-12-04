import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mt1/pages/home_page.dart';
import 'package:mt1/pages/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MainPage(), theme: ThemeData(primarySwatch: Colors.green));
  }
}
