import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: true);
    mockFirestore = FakeFirebaseFirestore();
  });

  testWidgets('Requirement 2: User is prompted for weekly/daily drawing goals', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GoalSetupScreen()));

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);

    expect(find.text('Hours per week'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pump();

    expect(find.text('Hours per day'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '10');
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('Requirement 3 & 4: User can toggle notifications and select frequency', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GoalSetupScreen()));

    // Requirement 3: Check notification toggle exists
    expect(find.text('Enable Reminders'), findsOneWidget);
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    // Toggle on
    await tester.tap(switchFinder);
    await tester.pump();

    // Requirement 4: Check frequency dropdown and time pickers exist when enabled
    expect(find.text('Reminder Frequency:'), findsOneWidget);
    expect(find.text('Daily'), findsAtLeast(1));
    expect(find.text('Start Time:'), findsOneWidget);
    expect(find.text('Latest Time:'), findsOneWidget);
  });
}
