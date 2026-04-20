import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('Requirement 2: User is prompted for weekly/daily drawing goals', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth(signedIn: true);
    final mockFirestore = FakeFirebaseFirestore();

    await tester.pumpWidget(MaterialApp(home: GoalSetupScreen(auth: mockAuth, firestore: mockFirestore)));
    await tester.pumpAndSettle();

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);

    expect(find.text('Hours per week'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pump();

    expect(find.text('Hours per day'), findsOneWidget);
  });
}
