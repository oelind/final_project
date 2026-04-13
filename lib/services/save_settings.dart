import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveSettings({
  required BuildContext context,
  required String timeGoal,
  required bool isWeeklyGoal,
  required bool wantNotifications,
  required String reminderFrequency,
  String? reminderStartTime,
  String? reminderEndTime,
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
}) async {
  if (timeGoal.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a time goal')),
    );
    return;
  }

  final effectiveAuth = auth ?? FirebaseAuth.instance;
  final effectiveFirestore = firestore ?? FirebaseFirestore.instance;
  final user = effectiveAuth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  try {
    await effectiveFirestore.collection('users').doc(user.uid).set({
      'settings': {
        'timeGoal': double.tryParse(timeGoal) ?? 0.0,
        'isWeeklyGoal': isWeeklyGoal,
        'wantNotifications': wantNotifications,
        'reminderFrequency': reminderFrequency,
        'reminderStartTime': reminderStartTime ?? '12:00 PM',
        'reminderEndTime': reminderEndTime ?? '12:00 AM',
      }
    }, SetOptions(merge: true));

    if (context.mounted) {
      // Show success popup (Requirement 12)
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Goal Saved'),
          content: Text(
            'You were able to successfully create a goal that was saved!\n\n'
            'Goal: $timeGoal hrs/${isWeeklyGoal ? 'weekly' : 'daily'}.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (context.mounted) {
        // After dialog is dismissed, go back to Home Screen
        Navigator.of(context).pop();
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }
}
