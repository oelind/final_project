import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const DrawingLogApp());
}

class DrawingLogApp extends StatelessWidget {
  const DrawingLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrawingLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
