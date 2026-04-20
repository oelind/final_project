import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

class DrawingLogApp extends StatelessWidget {
  final FirebaseAuth? auth;
  final FirebaseDatabase? database;
  final List<String>? initialPrompts;
  const DrawingLogApp({super.key, this.auth, this.database, this.initialPrompts});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrawingLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginPage(auth: auth, database: database, initialPrompts: initialPrompts),
    );
  }
}
