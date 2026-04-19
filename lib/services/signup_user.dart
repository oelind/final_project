import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<UserCredential?> signupUser({
  required FirebaseAuth auth,
  required String email,
  required String password,
  FirebaseFirestore? firestore,
}) async {
  try {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final effectiveFirestore = firestore ?? FirebaseFirestore.instance;
      await effectiveFirestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
          'timeGoal': 0.0,
          'isWeeklyGoal': true,
          'wantNotifications': false,
          'reminderFrequency': 'Daily',
          'reminderStartTime': '12:00 PM',
          'reminderEndTime': '12:00 AM',
        }
      });
    }

    return credential;
  } on FirebaseAuthException catch (e) {
    debugPrint('Signup failed for: $email - ${e.code}');
    rethrow;
  } catch (e) {
    debugPrint('An error occurred during signup: $e');
    rethrow;
  }
}
