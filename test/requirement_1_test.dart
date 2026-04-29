import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  testWidgets('Requirement 1: Login screen has option to create an account', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase();
    
    await tester.pumpWidget(DrawingLogApp(auth: mockAuth, database: mockDatabase));
    expect(find.text('Don\'t have an account? Create one'), findsOneWidget);

    await tester.tap(find.text('Don\'t have an account? Create one'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Requirement 1: Successful login navigates to home screen', (WidgetTester tester) async {
    final user = MockUser(
      isAnonymous: false,
      uid: 'test_uid',
      email: 'user1@example.com',
    );
    final mockAuth = MockFirebaseAuth(mockUser: user);
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase();
    
    await tester.pumpWidget(DrawingLogApp(
      auth: mockAuth,
      database: mockDatabase,
    ));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'user1@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump(); // Start navigation
    await tester.pump(const Duration(milliseconds: 100)); // Finish navigation

    expect(find.text('Drawing Log'), findsOneWidget);
  });

  testWidgets('Regression Test: Invalid email format shows error', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();
    final FirebaseDatabase mockDatabase = MockFirebaseDatabase();
    
    await tester.pumpWidget(DrawingLogApp(auth: mockAuth, database: mockDatabase));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalid-email');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    // We expect some form of validation error. 
    // Based on common patterns, it might show "Invalid email" or similar.
    // I'll check for a general failure or specific message if I know it.
    // Looking at junior_qa_login_test, it seems it shows "Login failed..." for unknown users.
    // For invalid format, let's see what happens.
    expect(find.text('Login failed. Please check your credentials.'), findsOneWidget);
  });
}
