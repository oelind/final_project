import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Requirement 1: Login screen has option to create an account', (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(DrawingLogApp(auth: mockAuth));

    // Verify that the "Create one" text button is present.
    expect(find.text('Don\'t have an account? Create one'), findsOneWidget);

    // Tap the "Create one" button.
    await tester.tap(find.text('Don\'t have an account? Create one'));
    await tester.pumpAndSettle();

    // Verify that we are on the "Create Account" screen.
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
