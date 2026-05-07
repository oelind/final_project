import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/models/drawing.dart';
import 'package:final_project/utils/summary_utils.dart';
import 'package:final_project/widgets/weekly_summary_dialog.dart';
import 'package:final_project/widgets/prompt_generator_widget.dart';
import 'package:final_project/widgets/complex_prompt_generator_widget.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  final random = Random();

  group('Requirement 13: Weekly Summary Tests', () {
    
    test('calculateWeeklySummary should correctly aggregate drawing data', () {
      final drawings = [
        Drawing(
          title: 'D1',
          description: '',
          // colors: [],
          // mediums: [],
          // size: '',
          // effort: 'Low',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 20),
        ),
        Drawing(
          title: 'D2',
          description: '',
          // colors: [],
          // mediums: [],
          // size: '',
          effort: 'High',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 40),
        ),
      ];

      final summary = calculateWeeklySummary(drawings, 5);

      expect(summary.drawingCount, 2);
      expect(summary.averageTimeSpent.inMinutes, 30);
      expect(summary.promptGeneratorsPressedCount, 5);
      expect(summary.averageEffort, 'Medium'); // (1 + 3) / 2 = 2 (Medium)
      expect(summary.averageDrawingsPerDay, 2 / 7.0);
    });

    test('calculateWeeklySummary should handle empty list', () {
      final summary = calculateWeeklySummary([], 0);

      expect(summary.drawingCount, 0);
      expect(summary.averageTimeSpent, Duration.zero);
      expect(summary.promptGeneratorsPressedCount, 0);
      expect(summary.averageEffort, 'None');
      expect(summary.averageDrawingsPerDay, 0.0);
    });

    test('Fuzzing Test: calculateWeeklySummary with random drawings', () {
      final effortOptions = ['Low', 'Medium', 'High'];
      
      for (int i = 0; i < 100; i++) {
        final List<Drawing> drawings = List.generate(random.nextInt(20), (index) {
          return Drawing(
            title: 'Fuzz $index',
            description: '',
            // colors: [],
            // mediums: [],
            // size: '',
            effort: effortOptions[random.nextInt(effortOptions.length)],
            timestamp: DateTime.now(),
            timeSpent: Duration(minutes: random.nextInt(120)),
          );
        });

        final promptPresses = random.nextInt(100);
        
        try {
          final summary = calculateWeeklySummary(drawings, promptPresses);
          expect(summary.drawingCount, drawings.length);
          expect(summary.promptGeneratorsPressedCount, promptPresses);
          if (drawings.isNotEmpty) {
            expect(effortOptions.contains(summary.averageEffort), true);
          }
        } catch (e) {
          fail('calculateWeeklySummary crashed during fuzzing: $e');
        }
      }
    });

    test('Regression Test: calculateWeeklySummary with unknown effort strings', () {
      final drawings = [
        Drawing(
          title: 'Unknown Effort',
          description: '',
          // colors: [],
          // mediums: [],
          // size: '',
          effort: 'Super High', // Unknown
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 10),
        ),
      ];
      
      final summary = calculateWeeklySummary(drawings, 0);
      // Should default to 'Medium' (2) for unknown effort
      expect(summary.averageEffort, 'Medium');
    });

    testWidgets('WeeklySummaryDialog displays correct information', (tester) async {
      final user = MockUser(uid: 'summary_user');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final database = MockFirebaseDatabase();

      // Seed data
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      await database.ref('users/summary_user/drawings').push().set({
        'userId': 'summary_user',
        'title': 'Recent',
        'effort': 'High',
        'timestamp': oneDayAgo,
        'timeSpentMinutes': 60,
      });

      await database.ref('users/summary_user/prompt_presses').push().set(oneDayAgo);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WeeklySummaryDialog(auth: auth, database: database),
        ),
      ));

      // Wait for loading
      await tester.pump(); // Start loading
      await tester.pump(const Duration(seconds: 1)); // Wait for data fetch
      await tester.pumpAndSettle();

      expect(find.text('Weekly Summary'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Drawing count
      expect(find.text('60 minutes'), findsOneWidget); // Average time
      expect(find.text('1 times'), findsOneWidget); // Prompt presses
      expect(find.text('High'), findsOneWidget); // Effort
    });

    testWidgets('Requirement 35: Prompt presses are logged to Real-time Database', (tester) async {
      final user = MockUser(uid: 'press_user');
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final database = MockFirebaseDatabase();

      // Test PromptGeneratorWidget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PromptGeneratorWidget(
            auth: auth,
            database: database,
            initialPrompts: ['A'],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Random Prompt'));
      await tester.pumpAndSettle();

      // Verify press logged
      final snapshot = await database.ref('users/press_user/prompt_presses').get();
      expect(snapshot.exists, true);
      expect((snapshot.value as Map).length, 1);

      // Test ComplexPromptGeneratorWidget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ComplexPromptGeneratorWidget(
            auth: auth,
            database: database,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sub-topic'));
      await tester.pumpAndSettle();

      // Verify second press logged
      final snapshot2 = await database.ref('users/press_user/prompt_presses').get();
      expect((snapshot2.value as Map).length, 2);
    });
  });
}
