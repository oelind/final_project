import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/drawing.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:final_project/widgets/prompt_generator_widget.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
  });

  group('QA Firestore Integration - Data Integrity & Isolation', () {
    test('User isolation: User A cannot see User B\'s drawings', () async {
      // Setup User A
      final userA = MockUser(uid: 'user_a', email: 'a@example.com');
      final authA = MockFirebaseAuth(mockUser: userA);
      
      // Setup User B
      final userB = MockUser(uid: 'user_b', email: 'b@example.com');
      final authB = MockFirebaseAuth(mockUser: userB);

      // User A logs a drawing
      await firestore.collection('drawings').add({
        'userId': 'user_a',
        'title': 'A\'s Art',
        'timeSpentMinutes': 30,
        'timestamp': Timestamp.now(),
      });

      // User B logs a drawing
      await firestore.collection('drawings').add({
        'userId': 'user_b',
        'title': 'B\'s Art',
        'timeSpentMinutes': 60,
        'timestamp': Timestamp.now(),
      });

      // Verify User A only sees their drawings
      final drawingsA = await firestore
          .collection('drawings')
          .where('userId', isEqualTo: 'user_a')
          .get();
      expect(drawingsA.docs.length, 1);
      expect(drawingsA.docs.first['title'], 'A\'s Art');

      // Verify User B only sees their drawings
      final drawingsB = await firestore
          .collection('drawings')
          .where('userId', isEqualTo: 'user_b')
          .get();
      expect(drawingsB.docs.length, 1);
      expect(drawingsB.docs.first['title'], 'B\'s Art');
    });

    test('Data Integrity: Drawing model correctly handles Firestore data types', () async {
      final now = DateTime.now();
      final data = {
        'userId': 'user_123',
        'title': 'Test Drawing',
        'description': 'Description here',
        'timeSpentMinutes': 45,
        'effort': 'High',
        'timestamp': Timestamp.fromDate(now),
      };

      final drawing = Drawing.fromFirestore(data);

      expect(drawing.title, 'Test Drawing');
      expect(drawing.timeSpent.inMinutes, 45);
      expect(drawing.effort, 'High');
      expect(drawing.timestamp.difference(now).inSeconds.abs(), lessThan(2));
    });

    test('Settings Persistence: User settings are correctly merged and retrieved', () async {
      const uid = 'user_789';
      
      await firestore.collection('users').doc(uid).set({
        'settings': {
          'timeGoal': 10.0,
          'isWeeklyGoal': true,
        }
      });

      await firestore.collection('users').doc(uid).set({
        'settings': {
          'wantNotifications': true,
          'reminderFrequency': 'Daily',
        }
      }, SetOptions(merge: true));

      final doc = await firestore.collection('users').doc(uid).get();
      final settings = doc.data()!['settings'] as Map<String, dynamic>;

      expect(settings['timeGoal'], 10.0);
      expect(settings['isWeeklyGoal'], true);
      expect(settings['wantNotifications'], true);
      expect(settings['reminderFrequency'], 'Daily');
    });

    testWidgets('GoalSetupScreen loads existing settings from Firestore', (WidgetTester tester) async {
      final user = MockUser(uid: 'test_user');
      auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      await firestore.collection('users').doc('test_user').set({
        'settings': {
          'timeGoal': 12.5,
          'isWeeklyGoal': false,
          'wantNotifications': true,
          'reminderFrequency': 'Daily',
          'reminderStartTime': '10:00 AM',
          'reminderEndTime': '11:00 PM',
        }
      });

      await tester.pumpWidget(MaterialApp(
        home: GoalSetupScreen(auth: auth, firestore: firestore),
      ));
      await tester.pumpAndSettle();

      expect(find.text('12.5'), findsOneWidget);
      expect(find.text('Daily'), findsAtLeast(1));
      
      // Check ChoiceChip for 'Daily' is selected
      final dailyChipFinder = find.byType(ChoiceChip).at(1); // 'Daily' is the second chip (at index 1)
      final dailyChip = tester.widget<ChoiceChip>(dailyChipFinder);
      expect(dailyChip.selected, true);
    });

    testWidgets('PromptGeneratorWidget persists state to Firestore', (WidgetTester tester) async {
      final user = MockUser(uid: 'prompt_user');
      auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PromptGeneratorWidget(
            initialPrompts: ['Prompt 1', 'Prompt 2'],
            auth: auth,
            firestore: firestore,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Generate a prompt
      await tester.tap(find.findButtonWithIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Check if saved to Firestore
      final doc = await firestore.collection('users').doc('prompt_user').get();
      expect(doc.exists, true);
      final state = doc.data()!['state'] as Map<String, dynamic>;
      expect(state['lastPrompt'], anyOf('Prompt 1', 'Prompt 2'));

      final lastPrompt = state['lastPrompt'];

      // Re-load and verify it shows the last prompt
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PromptGeneratorWidget(
            initialPrompts: ['Prompt 1', 'Prompt 2'],
            auth: auth,
            firestore: firestore,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(lastPrompt), findsOneWidget);
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
