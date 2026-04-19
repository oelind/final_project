import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//this function saves modifications for the user's notifications,
// it also should save modifications made to the user's goal(verifying if it does).
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

//if a user somehow got this far without logging in and tried to set a goal 
//then they would be notified that they are not signed in
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in. Please log in to be able to save your selected settings')),
    );
    return;
  }//end of if statment to catch case of user not being signed in

//the following code stores values entered by the user
// for variables to ultimatly be stored with data for their account
  try {
    await effectiveFirestore.collection('users').doc(user.uid).set({
      'settings': {
        'timeGoal': double.tryParse(timeGoal) ?? 0.0,
        'isWeeklyGoal': isWeeklyGoal,
        'wantNotifications': wantNotifications,
        'reminderFrequency': reminderFrequency,
        'reminderStartTime': reminderStartTime ?? '12:00 PM',
        'reminderEndTime': reminderEndTime ?? '12:00 AM',
      } //end of try
      //replaces specified values like user input instead
      //of the default values for those variables
    }, SetOptions(merge: true));
//what happens if the goal is successfully saved--> which is a pop up notifying
//the user that their log entry was saved properly
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
//then after the notification if no errors occur then the user is then sent
//back to the home screen
      if (context.mounted) {
        // After dialog is dismissed, go back to Home Screen
        Navigator.of(context).pop();
      }
    }

    //this is to account for the case of a log entry not being properly saved
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }
}
