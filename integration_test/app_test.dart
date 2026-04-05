import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:umakstore/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UMakstore Thorough Integration Tests', () {
    
    // Improved helper to wait for the app to reach the Home Screen
    Future<void> startApp(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      bool foundHome = false;
      for (int i = 0; i < 20; i++) { // Wait up to 10 seconds
        await tester.pump(const Duration(milliseconds: 500));
        
        // Auto-skip onboarding if it appears
        final onboardingFinder = find.textContaining('Skip');
        if (onboardingFinder.evaluate().isNotEmpty) {
          await tester.tap(onboardingFinder);
          await tester.pumpAndSettle();
        }

        if (find.byKey(const Key('nav_home')).evaluate().isNotEmpty) {
          foundHome = true;
          break;
        }
      }

      if (!foundHome) {
        // Diagnostic information
        final loginFinder = find.textContaining('Sign in');
        if (loginFinder.evaluate().isNotEmpty) {
           fail('TEST FAILED: Stuck at Login Screen. Please sign in on the device manually first.');
        }
        
        final splashFinder = find.textContaining('University of Makati');
        if (splashFinder.evaluate().isNotEmpty) {
           fail('TEST FAILED: Stuck at Splash Screen. The delay or initialization is taking too long.');
        }

        fail('TEST FAILED: Could not reach Home Screen after 10 seconds. Check if the app is logged in or if there is a blocking dialog.');
      }
      
      await tester.pumpAndSettle();
    }

    testWidgets('1. Localization Logic', (tester) async {
      await startApp(tester);

      // Navigate to Profile
      final profileNav = find.byKey(const Key('nav_profile'));
      expect(profileNav, findsOneWidget);
      await tester.tap(profileNav);
      await tester.pumpAndSettle();

      // Go to Settings
      final settingsTile = find.byKey(const Key('tile_settings'));
      expect(settingsTile, findsOneWidget);
      await tester.tap(settingsTile);
      await tester.pumpAndSettle();

      // Toggle to Filipino
      await tester.tap(find.byKey(const Key('tile_language')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filipino'));
      await tester.pumpAndSettle();

      // Verify translation
      expect(find.text('Wika'), findsOneWidget);
    });

    testWidgets('2. Storage Flow', (tester) async {
      await startApp(tester);

      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_settings')));
      await tester.pumpAndSettle();

      // Clear Cache
      final clearCacheTile = find.byKey(const Key('tile_clear_cache'));
      expect(clearCacheTile, findsOneWidget);
      await tester.tap(clearCacheTile);
      await tester.pumpAndSettle();

      // Confirm (The button text is 'Clear')
      final clearButton = find.text('Clear');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    });

    testWidgets('3. Tab Navigation', (tester) async {
      await startApp(tester);

      // Verify each navigation tab responds correctly
      await tester.tap(find.byKey(const Key('nav_search')));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav_favorites')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('nav_home')));
      await tester.pumpAndSettle();
    });

  });
}
