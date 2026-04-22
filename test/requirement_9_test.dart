import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/goal_progress_widget.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  testWidgets('Requirement 9: Goal progress widget shows percentage and progress bar', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase();

    // 1. Set goal to 10 hours
    await mockDatabase.ref('users/test_uid/settings').set({
      'timeGoal': 10.0,
      'isWeeklyGoal': true,
    });

    // 2. Log 5 hours (300 minutes)
    await mockDatabase.ref('drawings').push().set({
      'userId': 'test_uid',
      'title': 'Drawing 1',
      'timeSpentMinutes': 300,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoalProgressWidget(auth: mockAuth, database: mockDatabase),
      ),
    ));
    await tester.pumpAndSettle();
    
    // We need an extra pump for the internal StreamBuilder
    await tester.pump();

    expect(find.text('50.0%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('5.0 / 10.0 hours logged'), findsOneWidget);
  });

  testWidgets('Requirement 9: Congratulation message when goal reached', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase();

    // 1. Set goal to 1 hour
    await mockDatabase.ref('users/test_uid/settings').set({
      'timeGoal': 1.0,
      'isWeeklyGoal': true,
    });

    // 2. Log 1 hour (60 minutes)
    await mockDatabase.ref('drawings').push().set({
      'userId': 'test_uid',
      'title': 'Drawing 1',
      'timeSpentMinutes': 60,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoalProgressWidget(auth: mockAuth, database: mockDatabase),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.text('100.0%'), findsOneWidget);
    expect(find.textContaining('Congratulations!'), findsOneWidget);
  });
}
