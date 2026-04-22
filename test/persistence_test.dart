import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Verify drawing log entries persist between logins', (WidgetTester tester) async {
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase.instance;
    final user = MockUser(
      isAnonymous: false,
      uid: 'test_user_id',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    // Start NOT signed in to test the full flow
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: false);

    // 1. Initial login
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      database: mockDatabase,
      initialPrompts: ['Test Prompt'],
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(); // Navigate to Home

    // Verify we are on Home Screen
    expect(find.text('Drawing Log'), findsOneWidget);

    // 2. Add drawing
    // Find and tap the FAB to open the log dialog
    // FAB usually has a tooltip or icon
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Fill out the dialog
    await tester.enterText(find.widgetWithText(TextFormField, 'Title (Optional)'), 'Persistent Drawing');
    await tester.enterText(find.widgetWithText(TextFormField, 'Time Spent (Minutes)'), '30');
    await tester.enterText(find.widgetWithText(TextFormField, 'Description (Optional)'), 'This should persist');
    
    // Save the entry
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify it appeared on the home screen
    // We might need an extra pump for StreamBuilder
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Persistent Drawing'), findsOneWidget);

    // 3. Sign out
    await tester.tap(find.widgetWithIcon(IconButton, Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verify we are back at the login page
    expect(find.text('DrawingLog Login'), findsOneWidget);

    // 4. Log back in
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify the drawing entry is still there
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Persistent Drawing'), findsOneWidget);
  });

  testWidgets('Verify drawing log entries persist during page switches', (WidgetTester tester) async {
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase.instance;
    final user = MockUser(
      isAnonymous: false,
      uid: 'test_user_id',
      email: 'test@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: false);

    // Add a drawing to database directly for this test
    await mockDatabase.ref('drawings').push().set({
      'userId': 'test_user_id',
      'title': 'Page Switch Test',
      'description': 'Testing navigation persistence',
      'timeSpentMinutes': 45,
      'effort': 'High',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'createdAt': ServerValue.timestamp,
    });

    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth, 
      database: mockDatabase,
      initialPrompts: ['Test Prompt'],
    ));
    await tester.pumpAndSettle();

    // Login
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify drawing is visible on Home Screen
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Page Switch Test'), findsOneWidget);

    // Navigate to Goal Setup Screen
    await tester.tap(find.widgetWithIcon(IconButton, Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Goal'));
    await tester.pumpAndSettle();

    // Verify we are on Goal Setup Screen
    expect(find.text('Goal & Notifications'), findsOneWidget);

    // Go back to Home Screen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Verify the drawing entry is still visible
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Page Switch Test'), findsOneWidget);
  });
}
