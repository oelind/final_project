import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/drawing.dart';

class GoalProgressWidget extends StatelessWidget {
  final FirebaseAuth? auth;
  final FirebaseDatabase? database;

  const GoalProgressWidget({super.key, this.auth, this.database});

  @override
  Widget build(BuildContext context) {
    final effectiveAuth = auth ?? FirebaseAuth.instance;
    final effectiveDatabase = database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DatabaseEvent>(
      stream: effectiveDatabase.ref('users/${user.uid}').onValue,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data?.snapshot.value == null) {
          return const SizedBox.shrink();
        }

        final userData = Map<dynamic, dynamic>.from(userSnapshot.data!.snapshot.value as Map);
        final settings = userData['settings'] as Map<dynamic, dynamic>?;
        if (settings == null) return const SizedBox.shrink();

        final double timeGoal = (settings['timeGoal'] as num?)?.toDouble() ?? 0.0;
        final bool isWeeklyGoal = settings['isWeeklyGoal'] ?? true;

        if (timeGoal <= 0) return const SizedBox.shrink();

        return StreamBuilder<DatabaseEvent>(
          stream: effectiveDatabase.ref('drawings')
              .orderByChild('userId')
              .equalTo(user.uid)
              .onValue,
          builder: (context, drawingSnapshot) {
            if (!drawingSnapshot.hasData) return const LinearProgressIndicator();

            List<Drawing> drawings = [];
            if (drawingSnapshot.data!.snapshot.value != null) {
              final drawingsMap = Map<dynamic, dynamic>.from(drawingSnapshot.data!.snapshot.value as Map);
              drawings = drawingsMap.values
                  .map((data) => Drawing.fromMap(Map<dynamic, dynamic>.from(data as Map)))
                  .toList();
            }

            // Calculate time spent in current period
            final now = DateTime.now();
            double totalHoursSpent = 0;

            for (var drawing in drawings) {
              bool isInPeriod = false;
              if (isWeeklyGoal) {
                // Simplified week check: last 7 days
                isInPeriod = now.difference(drawing.timestamp).inDays < 7;
              } else {
                // Daily check: same day
                isInPeriod = now.year == drawing.timestamp.year &&
                    now.month == drawing.timestamp.month &&
                    now.day == drawing.timestamp.day;
              }

              if (isInPeriod) {
                totalHoursSpent += drawing.timeSpent.inMinutes / 60.0;
              }
            }

            double progress = totalHoursSpent / timeGoal;
            bool goalReached = progress >= 1.0;
            if (progress > 1.0) progress = 1.0;

            return Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isWeeklyGoal ? 'Weekly Goal' : 'Daily Goal',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: goalReached ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goalReached ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${totalHoursSpent.toStringAsFixed(1)} / ${timeGoal.toStringAsFixed(1)} hours logged',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (goalReached) ...[
                      const SizedBox(height: 12),
                      const Text(
                        '🎉 Congratulations! You have completed more than your goal!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
