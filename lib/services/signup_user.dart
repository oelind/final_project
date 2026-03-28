import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<UserCredential?> signupUser({
  required FirebaseAuth auth,
  required String email,
  required String password,
}) async {
  try {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    debugPrint('Signup failed for: $email - ${e.code}');
    rethrow;
  } catch (e) {
    debugPrint('An error occurred during signup: $e');
    rethrow;
  }
}
