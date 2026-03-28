import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<UserCredential?> loginUser({
  required FirebaseAuth auth,
  required String email,
  required String password,
}) async {
  try {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    debugPrint('Login failed for: $email - ${e.code}');
    rethrow;
  } catch (e) {
    debugPrint('An error occurred during login: $e');
    rethrow;
  }
}
