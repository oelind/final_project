import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../home_screen.dart';

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

Future<void> loginProcess({
  required BuildContext context,
  required FirebaseAuth auth,
  required String email,
  required String password,
  required FirebaseFirestore? firestore,
  required List<String>? initialPrompts,
}) async {
  // Case for if the user did not enter their password
  // or if the user did not enter their email
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter both your email and your password.'),
        backgroundColor: Colors.orangeAccent,
      ),
    );
    return;
  }

  // This chunk of code gets the user's user-credentials for firebase
  try {
    final userCredential = await loginUser(
      auth: auth,
      email: email,
      password: password,
    );

    // If statement for if a user does have the proper credential
    // for/through firebase authorization
    if (userCredential?.user != null && userCredential?.user?.email != null) {
      debugPrint('Login successful for: ${userCredential?.user?.email}');
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              auth: auth,
              firestore: firestore,
              initialPrompts: initialPrompts,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    debugPrint('Login failed for: $email - ${e.code}');
    String message = 'Invalid email or password.';
    if (e.code == 'user-not-found') {
      message = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password provided for that user.';
    } else if (e.code == 'invalid-email') {
      message = 'The email address is badly formatted.';
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  } catch (e) {
    debugPrint('An error occurred during login: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
