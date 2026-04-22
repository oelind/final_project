import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Requirement 2: User is prompted for weekly/daily drawing goals', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth(signedIn: true);
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase.instance;

    await tester.pumpWidget(MaterialApp(home: GoalSetupScreen(auth: mockAuth, database: mockDatabase)));
    await tester.pumpAndSettle();

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);

    expect(find.text('Hours per week'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pump();

    expect(find.text('Hours per day'), findsOneWidget);
  });
}
