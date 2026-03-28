import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';

void main() {
  testWidgets('Requirement 2: User is prompted for weekly/daily drawing goals', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: GoalSetupScreen()));

    // Verify presence of choice chips for weekly/daily goal selection.
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);

    // Initial state: Weekly Goal selected.
    expect(find.text('Hours per week'), findsOneWidget);

    // Select Daily Goal.
    await tester.tap(find.text('Daily'));
    await tester.pump();

    // Verify label changes correctly.
    expect(find.text('Hours per day'), findsOneWidget);

    // Enter time goal.
    await tester.enterText(find.byType(TextField), '10');
    expect(find.text('10'), findsOneWidget);

    // Save goal.
    await tester.tap(find.text('Save & Continue'));
    await tester.pump();

    // Verify snackbar feedback is shown.
    expect(find.textContaining('Goal: 10 hrs/daily'), findsOneWidget);
  });
}
