import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:final_project/goal_setup_screen.dart';

void main() {
  testWidgets('Verify user goal persists after app "restart"', (WidgetTester tester) async {
    // 1. Setup persistent mock instances
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase.instance;
    final user = MockUser(
      isAnonymous: false,
      uid: 'goal_user_id',
      email: 'goal@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);

    // 2. "First Run": Set a goal
    await tester.pumpWidget(MaterialApp(
      home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
    ));
    await tester.pumpAndSettle();

    // Enter a goal
    await tester.enterText(find.byType(TextField).first, '20.5');
    // Ensure Weekly is selected (default)
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    // Save the goal
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();

    // Close the success dialog
    expect(find.text('Goal Saved'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 3. "Shutdown": Clear the widget tree
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // 4. "Restart": Rebuild the app with the same mockDatabase instance
    await tester.pumpWidget(MaterialApp(
      home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
    ));
    // Wait for the initState's _loadSettings to complete
    await tester.pumpAndSettle();

    // 5. Verify the goal is still there in the UI
    expect(find.text('20.5'), findsOneWidget);
    
    // Verify it's still Weekly (the first chip)
    final weeklyChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Weekly'));
    expect(weeklyChip.selected, true);

    // 6. Double-check directly in Database
    final snapshot = await mockDatabase.ref('users/goal_user_id/settings').get();
    expect(snapshot.exists, true);
    final settings = snapshot.value as Map;
    expect(settings['timeGoal'], 20.5);
    expect(settings['isWeeklyGoal'], true);
  });

  testWidgets('Verify daily goal also persists', (WidgetTester tester) async {
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase.instance;
    final user = MockUser(uid: 'daily_user');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);

    // Set a daily goal
    await tester.pumpWidget(MaterialApp(
      home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '2.0');
    
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Restart
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    await tester.pumpWidget(MaterialApp(
      home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
    ));
    await tester.pumpAndSettle();

    // Verify
    expect(find.text('2.0'), findsOneWidget);
    final dailyChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Daily'));
    expect(dailyChip.selected, true);
  });
}
