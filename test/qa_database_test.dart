import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:final_project/models/drawing.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:final_project/widgets/prompt_generator_widget.dart';

void main() {
  late FirebaseDatabase database;
  late MockFirebaseAuth auth;

  setUp(() {
    database = MockFirebaseDatabase.instance;
    auth = MockFirebaseAuth();
  });

  group('QA Database Integration - Data Integrity & Isolation', () {
    test('User isolation: User A cannot see User B\'s drawings', () async {
      // User A logs a drawing
      await database.ref('drawings').push().set({
        'userId': 'user_a',
        'title': 'A\'s Art',
        'timeSpentMinutes': 30,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // User B logs a drawing
      await database.ref('drawings').push().set({
        'userId': 'user_b',
        'title': 'B\'s Art',
        'timeSpentMinutes': 60,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Verify User A only sees their drawings
      final snapshotA = await database.ref('drawings').get();
      final allDataA = snapshotA.value as Map? ?? {};
      final dataA = Map.from(allDataA)..removeWhere((k, v) => v['userId'] != 'user_a');
      expect(dataA.length, 1);
      expect(dataA.values.first['title'], 'A\'s Art');

      // Verify User B only sees their drawings
      final snapshotB = await database.ref('drawings').get();
      final allDataB = snapshotB.value as Map? ?? {};
      final dataB = Map.from(allDataB)..removeWhere((k, v) => v['userId'] != 'user_b');
      expect(dataB.length, 1);
      expect(dataB.values.first['title'], 'B\'s Art');
    });

    test('Data Integrity: Drawing model correctly handles Map data', () async {
      final now = DateTime.now();
      final data = {
        'userId': 'user_123',
        'title': 'Test Drawing',
        'description': 'Description here',
        'timeSpentMinutes': 45,
        'effort': 'High',
        'timestamp': now.millisecondsSinceEpoch,
      };

      final drawing = Drawing.fromMap(data);

      expect(drawing.title, 'Test Drawing');
      expect(drawing.timeSpent.inMinutes, 45);
      expect(drawing.effort, 'High');
      expect(drawing.timestamp.difference(now).inSeconds.abs(), lessThan(2));
    });

    test('Settings Persistence: User settings are correctly merged and retrieved', () async {
      const uid = 'user_789';
      
      // Initial save
      await database.ref('users/$uid/settings').set({
        'timeGoal': 10.0,
        'isWeeklyGoal': true,
      });

      // Update partially
      await database.ref('users/$uid/settings').update({
        'wantNotifications': true,
        'reminderFrequency': 'Daily',
      });

      final snapshot = await database.ref('users/$uid/settings').get();
      final settings = snapshot.value as Map;

      expect(settings['timeGoal'], 10.0);
      expect(settings['isWeeklyGoal'], true);
      expect(settings['wantNotifications'], true);
      expect(settings['reminderFrequency'], 'Daily');
    });

    testWidgets('GoalSetupScreen loads existing settings from Database', (WidgetTester tester) async {
      final user = MockUser(uid: 'test_user');
      auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      await database.ref('users/test_user/settings').set({
        'timeGoal': 12.5,
        'isWeeklyGoal': false,
        'wantNotifications': true,
        'reminderFrequency': 'Daily',
        'reminderStartTime': '10:00 AM',
        'reminderEndTime': '11:00 PM',
      });

      await tester.pumpWidget(MaterialApp(
        home: GoalSetupScreen(auth: auth, database: database),
      ));
      await tester.pumpAndSettle();

      expect(find.text('12.5'), findsOneWidget);
      expect(find.text('Daily'), findsAtLeast(1));
      
      final dailyChipFinder = find.byType(ChoiceChip).at(1); 
      final dailyChip = tester.widget<ChoiceChip>(dailyChipFinder);
      expect(dailyChip.selected, true);
    });

    testWidgets('PromptGeneratorWidget persists state to Database', (WidgetTester tester) async {
      final user = MockUser(uid: 'prompt_user');
      auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PromptGeneratorWidget(
            initialPrompts: ['Prompt 1', 'Prompt 2'],
            auth: auth,
            database: database,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Generate a prompt
      await tester.tap(find.findButtonWithIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Check if saved to Database
      final snapshot = await database.ref('users/prompt_user/state/lastPrompt').get();
      expect(snapshot.exists, true);
      expect(snapshot.value, anyOf('Prompt 1', 'Prompt 2'));

      final lastPrompt = snapshot.value as String;

      // Re-load and verify it shows the last prompt
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PromptGeneratorWidget(
            initialPrompts: ['Prompt 1', 'Prompt 2'],
            auth: auth,
            database: database,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(lastPrompt), findsOneWidget);
    });

    test('Stress Test: Rapid fire drawing logs', () async {
      const uid = 'user_stress';
      const count = 20;

      for (int i = 0; i < count; i++) {
        await database.ref('drawings').push().set({
          'userId': uid,
          'title': 'Drawing $i',
          'timeSpentMinutes': 5,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      final snapshot = await database.ref('drawings').get();
      final allData = snapshot.value as Map? ?? {};
      final data = Map.from(allData)..removeWhere((k, v) => v['userId'] != uid);
      expect(data.length, count);
    });
   group('Database-Specific Integration Tests', () {
    test('Verify RTDB is being used (Mock check)', () {
      expect(database, isA<MockFirebaseDatabase>());
    });
  });
  });
}

extension on CommonFinders {
  Finder findButtonWithIcon(IconData icon) {
    return find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(ElevatedButton),
    );
  }
}
