import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart';

/// Simple integration test that tests the app's UI flow without making
/// direct API calls from the test framework.
///
/// This test uses the app's built-in API connectivity.
///
/// Run with:
///   flutter test integration_test/simple_flow_test.dart -d <device-id>
///   --dart-define=API_URL=http://<host-ip>:8080
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple UI Flow Tests', () {
    testWidgets('should display login screen and navigate', (tester) async {
      runApp(const ProviderScope(child: FiveCrownsApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify login screen elements
      expect(find.text('Five Crowns'), findsOneWidget);
      expect(find.text("Don't have an account? Sign up"), findsOneWidget);

      // Navigate to signup
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();

      // Verify signup screen
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Display Name'), findsOneWidget);

      // Navigate back to login
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();

      // Navigate to forgot password
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      // Verify forgot password screen
      expect(find.text('Reset Password'), findsOneWidget);

      print('Simple UI flow test completed successfully!');
    });

    testWidgets('should show form validation on login', (tester) async {
      runApp(const ProviderScope(child: FiveCrownsApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to login without credentials
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Enter invalid email format
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);

      print('Form validation test completed successfully!');
    });

    testWidgets('should show signup form validation', (tester) async {
      runApp(const ProviderScope(child: FiveCrownsApp()));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to signup
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();

      // Try to signup without filling form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a username'), findsOneWidget);
      expect(find.text('Please enter your display name'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);

      print('Signup validation test completed successfully!');
    });
  });
}
