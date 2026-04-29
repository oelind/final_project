import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/models/drawing.dart';
import 'package:final_project/widgets/drawing_log_dialog.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  final random = Random();

  group('Prompt 28: Fuzzing Tests', () {
    test('Fuzz Drawing.fromMap with malformed and random data', () {
      final keys = [
        'userId', 'title', 'description', 'colors', 'mediums', 
        'size', 'effort', 'timestamp', 'timeSpentMinutes', 'wasPromptUsed'
      ];
      
      final randomValues = [
        null,
        '',
        '   ',
        'A' * 1000,
        123,
        123.45,
        true,
        false,
        ['a', 'b', 'c'],
        {'a': 1},
        DateTime.now().toIso8601String(),
        'not a date',
        -1,
        double.infinity,
      ];

      for (int i = 0; i < 200; i++) {
        final Map<dynamic, dynamic> fuzzedData = {};
        // Randomly pick keys to include
        for (var key in keys) {
          if (random.nextBool()) {
            fuzzedData[key] = randomValues[random.nextInt(randomValues.length)];
          }
        }

        // The test passes if it doesn't throw an unhandled exception (crash)
        try {
          final drawing = Drawing.fromMap(fuzzedData);
          // Basic sanity check on properties if needed
          expect(drawing, isA<Drawing>());
        } catch (e) {
          fail('Drawing.fromMap crashed with data: $fuzzedData\nError: $e');
        }
      }
    });

    testWidgets('Fuzz DrawingLogDialog UI inputs', (tester) async {
      final mockAuth = MockFirebaseAuth(signedIn: true);
      final mockDatabase = MockFirebaseDatabase();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => DrawingLogDialog(auth: mockAuth, database: mockDatabase),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      final fuzzedInputs = [
        'Normal Title',
        '   ',
        '',
        'T' * 2000,
        '!@#\$%^&*()_+|}{POIUYTREWQ',
        '1234567890',
        '\n\n\n\b\r\t',
        '❤️😊🚀',
      ];

      for (var title in fuzzedInputs) {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Enter fuzzed title
        await tester.enterText(find.widgetWithText(TextFormField, 'Title (Optional)'), title);
        
        // Enter fuzzed description
        await tester.enterText(find.widgetWithText(TextFormField, 'Description (Optional)'), title);

        // Enter fuzzed time (should only accept numbers, but we fuzz it)
        await tester.enterText(find.widgetWithText(TextFormField, 'Time Spent (Minutes)'), 'not a number');
        
        // Try to save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // It shouldn't crash. It might show a validation error or save defaults.
        // We just ensure the UI is still responsive.
        if (find.text('Log Your Drawing').evaluate().isNotEmpty) {
           // Close if still open
           await tester.tap(find.text('Cancel'));
           await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Fuzz GoalSetupScreen UI inputs', (tester) async {
      final mockAuth = MockFirebaseAuth(signedIn: true);
      final mockDatabase = MockFirebaseDatabase();

      final fuzzedTimeGoals = [
        '10',
        '999999999',
        '-5',
        '0.0000000001',
        'abc',
        '   ',
        '!@#\$',
        'NaN',
      ];

      await tester.pumpWidget(MaterialApp(
        home: GoalSetupScreen(auth: mockAuth, database: mockDatabase),
      ));
      await tester.pumpAndSettle();

      for (var goal in fuzzedTimeGoals) {
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField, goal);
          await tester.tap(find.text('Save & Continue'));
          await tester.pumpAndSettle();
          
          // If dialog appeared (Requirement 12), close it
          final okButton = find.text('OK');
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });
}
