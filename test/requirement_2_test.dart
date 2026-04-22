import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Requirement 2: User is prompted for weekly/daily drawing goals', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth(signedIn: true);
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(home: GoalSetupScreen(auth: mockAuth, database: mockDatabase)));
    await tester.pumpAndSettle();

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);

    expect(find.text('Hours per week'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pump();

    expect(find.text('Hours per day'), findsOneWidget);
  });

  testWidgets('Requirement 2: User goal persists and is loaded back into UI', (WidgetTester tester) async {
    final user = MockUser(uid: 'goal_user_id');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase();

    // 1. Set a goal
    await tester.pumpWidget(MaterialApp(
      home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '20.5');
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 2. Restart (rebuild widget tree)
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    await tester.pumpWidget(MaterialApp(
      home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
    ));
    await tester.pumpAndSettle();

    // 3. Verify it loaded back
    expect(find.text('20.5'), findsOneWidget);
    final weeklyChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Weekly'));
    expect(weeklyChip.selected, true);
  });
}
