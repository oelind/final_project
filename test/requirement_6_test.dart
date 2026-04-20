import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/home_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Requirement 6: Buttons on home screen and settings dropdown', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    

    await tester.pumpWidget(MaterialApp(home: HomeScreen(auth: mockAuth)));
    await tester.pumpAndSettle();

    // Floating Action Button
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Settings Button
    expect(find.byIcon(Icons.settings), findsAtLeast(1));

    await tester.tap(find.byIcon(Icons.settings).first);
    await tester.pumpAndSettle();

    // Dropdown items -- tests to check the drop down menu works
    expect(find.text('Edit Goal'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
