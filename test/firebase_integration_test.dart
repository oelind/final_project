import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FirebaseDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockFirebaseDatabase();
    mockAuth = MockFirebaseAuth();
  });

  testWidgets('Full Firebase Integration Flow: Signup, Login, Settings, and Logs', (WidgetTester tester) async {
    // Set a standard window size to avoid overflow and hit test issues
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. App starts with Login Page
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      database: mockDatabase,
      initialPrompts: ['Mock Prompt'],
    ));
    await tester.pumpAndSettle();

    // 2. Navigate to Signup
    await tester.tap(find.text('Don\'t have an account? Create one'));
    await tester.pumpAndSettle();

    // 3. Perform Signup
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'newuser@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'password123');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // After signup, it pops back to Login
    expect(find.text('DrawingLog Login'), findsOneWidget);

    // 4. Perform Login
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'newuser@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify Home Screen
    expect(find.text('Drawing Log'), findsOneWidget);
    final userId = mockAuth.currentUser!.uid;

    // 5. Save Settings (Goal)
    // Find the settings button in the AppBar
    final settingsButton = find.widgetWithIcon(IconButton, Icons.settings);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle(); // Wait for popup menu
    
    await tester.tap(find.text('Edit Goal'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '15.0');
    final saveButton = find.text('Save & Continue');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    
    // Close success dialog
    expect(find.text('Goal Saved'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify Settings in Database
    final snapshot = await mockDatabase.ref('users/$userId/settings/timeGoal').get();
    expect(snapshot.value, 15.0);

    // 6. Log a Drawing
    final fabFinder = find.byType(FloatingActionButton);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title (Optional)'), 'Firebase Masterpiece');
    await tester.enterText(find.widgetWithText(TextFormField, 'Time Spent (Minutes)'), '120');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Extra pumps for StreamBuilder and animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Firebase Masterpiece'), findsOneWidget);

    // Verify Drawing in Database
    final drawingsSnapshot = await mockDatabase.ref('drawings').get();
    final allDrawings = drawingsSnapshot.value as Map? ?? {};
    final drawingsData = Map.from(allDrawings)..removeWhere((k, v) => v['userId'] != userId);
    
    expect(drawingsData.length, 1);
    expect(drawingsData.values.first['title'], 'Firebase Masterpiece');
    expect(drawingsData.values.first['timeSpentMinutes'], 120);

    // 7. Sign Out and Verify Persistence
    await tester.tap(find.widgetWithIcon(IconButton, Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(find.text('DrawingLog Login'), findsOneWidget);

    // Log back in
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'newuser@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify data still present
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Firebase Masterpiece'), findsOneWidget);
  });
}
