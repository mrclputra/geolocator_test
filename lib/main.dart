import 'package:flutter/material.dart';
import 'package:geolocator_test/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.blueGrey,
            secondary: Colors.teal,
          )),
      home: const PageManager(),
    );
  }
}
