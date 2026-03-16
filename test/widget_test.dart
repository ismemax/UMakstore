// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umakstore/main.dart';
import 'package:umakstore/onboarding_screen.dart';

void main() {
  testWidgets('App renders splash screen and navigates to onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify splash screen immediately
    expect(find.text('University of Makati'), findsOneWidget);

    // Wait for the timer and navigation animation
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify onboarding screen is shown
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
