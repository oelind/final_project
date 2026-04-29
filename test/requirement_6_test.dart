import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/home_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  testWidgets('Requirement 6: Buttons on home screen and settings dropdown', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(home: HomeScreen(auth: mockAuth, database: mockDatabase)));
    await tester.pumpAndSettle();

    // Floating Action Button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsAtLeast(1));

    // Settings Button
    expect(find.byIcon(Icons.settings), findsAtLeast(1));

    await tester.tap(find.byIcon(Icons.settings).first);
    await tester.pumpAndSettle();

    // Dropdown items
    expect(find.text('Edit Goal'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Regression Test: Signing out redirects to login page', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid_signout');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(home: HomeScreen(auth: mockAuth, database: mockDatabase)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify we are back at the login page (or at least out of HomeScreen)
    expect(find.text('Login'), findsAtLeast(1));
    expect(mockAuth.currentUser, isNull);
  });
}
