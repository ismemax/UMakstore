import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CI Smoke Test: Basic Rendering', (WidgetTester tester) async {
    // Build a simple widget to verify the CI can run tests
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('CI Check Passed'))),
      ),
    );

    expect(find.text('CI Check Passed'), findsOneWidget);
  });
}
