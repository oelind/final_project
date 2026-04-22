import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/drawing_log_dialog.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  testWidgets('Requirement 8: Real-time log entry with timer', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DrawingLogDialog(auth: mockAuth, database: mockDatabase),
      ),
    ));
    await tester.pumpAndSettle();

    final timerButtonFinder = find.byIcon(Icons.play_arrow);
    expect(timerButtonFinder, findsOneWidget);

    // Start timer
    await tester.tap(timerButtonFinder);
    await tester.pump(const Duration(seconds: 2));

    expect(find.byIcon(Icons.stop), findsOneWidget);
    
    await tester.pump(const Duration(seconds: 60)); // 62 seconds total
    expect(find.text('1.0'), findsOneWidget); // 60/60 = 1.0

    // Stop timer
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
