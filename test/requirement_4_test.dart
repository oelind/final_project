import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  testWidgets('Requirement 4: Notification settings (frequency, times)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase.instance;

    await tester.pumpWidget(MaterialApp(home: GoalSetupScreen(auth: mockAuth, database: mockDatabase)));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    expect(find.text('Every 2 hours'), findsAtLeast(1));
    expect(find.text('Start Time:'), findsOneWidget);
    expect(find.text('Latest Time:'), findsOneWidget);

    // Close dropdown
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '5');
    
    final saveButton = find.text('Save & Continue');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Goal Saved'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final snapshot = await mockDatabase.ref('users/test_uid/settings/reminderFrequency').get();
    expect(snapshot.value, 'Daily');
  });
}
