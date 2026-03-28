import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';

void main() {
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

    final saveButton = find.text('Save & Continue');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.textContaining('Goal: 10 hrs/daily'), findsOneWidget);
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

    // Requirement 4: Check frequency dropdown exists when enabled
    expect(find.text('Reminder Frequency:'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Select frequency
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every 2 hours').last);
    await tester.pumpAndSettle();

    // Enter goal
    await tester.enterText(find.byType(TextField), '5');
    
    // Scroll to save button and tap
    final saveButton = find.text('Save & Continue');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.textContaining('Notifications: On (Every 2 hours)'), findsOneWidget);
  });
}
