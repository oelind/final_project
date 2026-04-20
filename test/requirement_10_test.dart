import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/widgets/prompt_generator_widget.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';

void main() {
  testWidgets('Requirement 10: Prompt generator displays random prompt', (WidgetTester tester) async {
    final user = MockUser(uid: 'test_uid');
    final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final mockDatabase = MockFirebaseDatabase.instance;
    final prompts = ['Apple', 'Banana', 'Cat'];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PromptGeneratorWidget(
          initialPrompts: prompts,
          auth: mockAuth,
          database: mockDatabase,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tap the button to generate a prompt!'), findsOneWidget);

    await tester.tap(find.text('Generate Random Prompt'));
    await tester.pumpAndSettle();

    // Verify one of the prompts is shown
    expect(
      find.byWidgetPredicate((widget) => 
        widget is Text && prompts.contains(widget.data)), 
      findsOneWidget
    );
  });
}
