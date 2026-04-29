import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  group('Prompt 23: Database Storage Verification', () {
    late FirebaseDatabase database;

    setUp(() {
      database = MockFirebaseDatabase();
    });

    test('Verify drawing log entries are properly stored in the user\'s specific node', () async {
      const uid = 'user_drawing_storage';
      final drawingData = {
        'userId': uid,
        'title': 'Test Drawing Storage',
        'description': 'Verifying storage structure',
        'timeSpentMinutes': 45,
        'effort': 'High',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'wasPromptUsed': true,
      };

      // Store the drawing
      await database.ref('users/$uid/drawings').push().set(drawingData);

      // Retrieve and verify
      final snapshot = await database.ref('users/$uid/drawings').get();
      expect(snapshot.exists, true, reason: 'Drawings node should exist for user');
      
      final data = snapshot.value as Map;
      expect(data.length, 1);
      
      final storedDrawing = data.values.first as Map;
      expect(storedDrawing['title'], 'Test Drawing Storage');
      expect(storedDrawing['userId'], uid);
      expect(storedDrawing['timeSpentMinutes'], 45);
      expect(storedDrawing['wasPromptUsed'], true);
    });

    test('Verify user set goal is properly stored in the user\'s settings node', () async {
      const uid = 'user_goal_storage';
      final goalData = {
        'timeGoal': 15.5,
        'isWeeklyGoal': true,
        'wantNotifications': true,
        'reminderFrequency': 'Daily',
        'reminderStartTime': '09:00 AM',
        'reminderEndTime': '09:00 PM',
      };

      // Store the goal
      await database.ref('users/$uid/settings').set(goalData);

      // Retrieve and verify
      final snapshot = await database.ref('users/$uid/settings').get();
      expect(snapshot.exists, true, reason: 'Settings node should exist for user');
      
      final storedGoal = snapshot.value as Map;
      expect(storedGoal['timeGoal'], 15.5);
      expect(storedGoal['isWeeklyGoal'], true);
      expect(storedGoal['reminderFrequency'], 'Daily');
      expect(storedGoal['reminderStartTime'], '09:00 AM');
    });

    test('Verify user goal is updated every time the user changes it', () async {
      const uid = 'user_goal_update';
      
      // 1. Initial goal
      await database.ref('users/$uid/settings').set({
        'timeGoal': 5.0,
        'isWeeklyGoal': false,
      });

      var snapshot = await database.ref('users/$uid/settings').get();
      var data = snapshot.value as Map;
      expect(data['timeGoal'], 5.0);

      // 2. Update goal
      await database.ref('users/$uid/settings').update({
        'timeGoal': 12.0,
      });

      snapshot = await database.ref('users/$uid/settings').get();
      data = snapshot.value as Map;
      expect(data['timeGoal'], 12.0);
      expect(data['isWeeklyGoal'], false, reason: 'Other fields should remain unchanged');

      // 3. Change goal type
      await database.ref('users/$uid/settings').update({
        'isWeeklyGoal': true,
      });

      snapshot = await database.ref('users/$uid/settings').get();
      data = snapshot.value as Map;
      expect(data['isWeeklyGoal'], true);
      expect(data['timeGoal'], 12.0);
    });

    test('Verify multiple drawings for the same user are stored correctly', () async {
      const uid = 'user_multi_drawing';
      await database.ref('users/$uid/drawings').push().set({'title': 'Drawing 1', 'userId': uid});
      await database.ref('users/$uid/drawings').push().set({'title': 'Drawing 2', 'userId': uid});

      final snapshot = await database.ref('users/$uid/drawings').get();
      final data = snapshot.value as Map;
      expect(data.length, 2);
    });

    test('Verify prompt generator state is stored in the database', () async {
      const uid = 'user_prompt_state';
      const lastPrompt = 'Draw a dragon with a top hat';

      // Store the last prompt state
      await database.ref('users/$uid/state').set({
        'lastPrompt': lastPrompt,
        'updatedAt': ServerValue.timestamp,
      });

      // Retrieve and verify
      final snapshot = await database.ref('users/$uid/state/lastPrompt').get();
      expect(snapshot.exists, true);
      expect(snapshot.value, lastPrompt);
    });
  });
}
