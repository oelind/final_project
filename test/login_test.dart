import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/main.dart';
import 'package:final_project/services/mock_data.dart';

void main() {
  testWidgets('Successful login navigates to home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DrawingLogApp());

    // Enter correct credentials from MockData
    final user = MockData.users.first;
    await tester.enterText(find.widgetWithText(TextField, 'Email'), user.email);
    await tester.enterText(find.widgetWithText(TextField, 'Password'), user.password);

    // Tap login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify home screen is shown
    expect(find.text('Drawing Log'), findsOneWidget);
    // Verify mock drawings are shown
    expect(find.text(MockData.drawings.first.title), findsOneWidget);
  });

  testWidgets('Failed login shows error snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(const DrawingLogApp());

    // Enter wrong credentials
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'wrong@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'wrongpassword');

    // Tap login button
    await tester.tap(find.text('Login'));
    await tester.pump(); // Pump for the snackbar

    // Verify error snackbar
    expect(find.text('Invalid email or password.'), findsOneWidget);
    
    // Verify we are still on login screen
    expect(find.text('DrawingLog Login'), findsOneWidget);
  });
}
