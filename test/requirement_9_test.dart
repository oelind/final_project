import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/goal_progress_widget.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  testWidgets('Requirement 9: Goal progress widget shows percentage and progress bar', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockFirestore = FakeFirebaseFirestore();

    // 1. Set goal to 10 hours
    await mockFirestore.collection('users').doc('test_uid').set({
      'settings': {
        'timeGoal': 10.0,
        'isWeeklyGoal': true,
      }
    });

    // 2. Log 5 hours (300 minutes)
    await mockFirestore.collection('drawings').add({
      'userId': 'test_uid',
      'title': 'Drawing 1',
      'timeSpentMinutes': 300,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoalProgressWidget(auth: mockAuth, firestore: mockFirestore),
      ),
    ));
    await tester.pumpAndSettle();
    
    // We need an extra pump for the internal StreamBuilder in GoalProgressWidget
    await tester.pump();

    expect(find.text('50.0%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('5.0 / 10.0 hours logged'), findsOneWidget);
  });

  testWidgets('Requirement 9: Congratulation message when goal reached', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockFirestore = FakeFirebaseFirestore();

    // 1. Set goal to 1 hour
    await mockFirestore.collection('users').doc('test_uid').set({
      'settings': {
        'timeGoal': 1.0,
        'isWeeklyGoal': true,
      }
    });

    // 2. Log 1 hour (60 minutes)
    await mockFirestore.collection('drawings').add({
      'userId': 'test_uid',
      'title': 'Drawing 1',
      'timeSpentMinutes': 60,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoalProgressWidget(auth: mockAuth, firestore: mockFirestore),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.text('100.0%'), findsOneWidget);
    expect(find.textContaining('Congratulations!'), findsOneWidget);
  });
}
