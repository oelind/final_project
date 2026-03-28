import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const DrawingLogApp());
}

class DrawingLogApp extends StatelessWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  const DrawingLogApp({super.key, this.auth, this.firestore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrawingLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginPage(auth: auth, firestore: firestore),
    );
  }
}
