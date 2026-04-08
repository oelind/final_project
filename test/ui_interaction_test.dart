import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/home_screen.dart';
import 'package:final_project/goal_setup_screen.dart';
import 'package:final_project/widgets/drawing_log_dialog.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: true);
    mockFirestore = FakeFirebaseFirestore();
  });

  testWidgets('Home Screen UI: Empty state shows record button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(auth: mockAuth, firestore: mockFirestore),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No drawings logged yet.'), findsOneWidget);
    expect(find.text('Record your first entry'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Home Screen UI: Settings menu shows correct options', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(auth: mockAuth, firestore: mockFirestore),
    ));
    await tester.pumpAndSettle();

    final settingsButton = find.byIcon(Icons.settings);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.text('Edit Goal'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Log Drawing Dialog: Interactions and Timer', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DrawingLogDialog(auth: mockAuth, firestore: mockFirestore),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Check initial fields
    expect(find.text('Log Your Drawing'), findsOneWidget);
    expect(find.text('Time Spent (Hours)'), findsOneWidget);

    // Test Timer button
    final timerButton = find.byIcon(Icons.play_arrow);
    await tester.tap(timerButton);
    await tester.pump();

    expect(find.textContaining('Timer active:'), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);

    // Enter data and save
    await tester.enterText(find.widgetWithText(TextFormField, 'Title (Optional)'), 'My Masterpiece');
    await tester.enterText(find.widgetWithText(TextFormField, 'Time Spent (Hours)'), '1.5');
    
    await tester.tap(find.text('Finished'));
    await tester.pumpAndSettle();

    // Verify drawing is in Firestore
    final drawings = await mockFirestore.collection('drawings').get();
    expect(drawings.docs.length, 1);
    expect(drawings.docs.first['title'], 'My Masterpiece');
    expect(drawings.docs.first['timeSpentMinutes'], 90);
  });

  testWidgets('Goal Setup Screen: Buttons and Toggles', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GoalSetupScreen()));

    // Toggle Goal Type
    await tester.tap(find.text('Daily'));
    await tester.pump();
    expect(find.text('Hours per day'), findsOneWidget);

    // Toggle Notifications
    final switchFinder = find.byType(Switch);
    await tester.tap(switchFinder);
    await tester.pump();

    expect(find.text('Reminder Frequency:'), findsOneWidget);
    expect(find.text('Daily'), findsAtLeast(1)); // Initial value and item in list
    expect(find.text('Start Time:'), findsOneWidget);
    expect(find.text('Latest Time:'), findsOneWidget);

    // Check if Save button is present and clickable
    expect(find.text('Save & Continue'), findsOneWidget);
  });
}
