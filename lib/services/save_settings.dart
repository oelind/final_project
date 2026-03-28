import 'package:flutter/material.dart';

void saveSettings({
  required BuildContext context,
  required String timeGoal,
  required bool isWeeklyGoal,
  required bool wantNotifications,
  required String reminderFrequency,
}) {
  if (timeGoal.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a time goal')),
    );
    return;
  }

  final goalType = isWeeklyGoal ? 'weekly' : 'daily';
  debugPrint('Goal set: $timeGoal hours per $goalType');
  debugPrint('Notifications: $wantNotifications');
  if (wantNotifications) {
    debugPrint('Reminder Frequency: $reminderFrequency');
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Settings saved! Goal: $timeGoal hrs/$goalType. '
        'Notifications: ${wantNotifications ? 'On ($reminderFrequency)' : 'Off'}'
      ),
    ),
  );
  
  Navigator.of(context).pop(); 
}
