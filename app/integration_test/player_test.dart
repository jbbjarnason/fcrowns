import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart';

/// Generic player test that reads credentials from a file.
///
/// Run on simulator 1 (Host):
///   flutter test integration_test/player_test.dart -d <sim1-id> --dart-define=CREDS_FILE=/tmp/host_creds.json
///
/// Run on simulator 2 (Guest):
///   flutter test integration_test/player_test.dart -d <sim2-id> --dart-define=CREDS_FILE=/tmp/guest_creds.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Player joins game from credentials', (tester) async {
    // Get credentials file from dart-define
    const credsFile = String.fromEnvironment('CREDS_FILE', defaultValue: '/tmp/host_creds.json');

    print('Loading credentials from: $credsFile');

    Map<String, dynamic> creds;
    try {
      final content = File(credsFile).readAsStringSync();
      creds = jsonDecode(content);
      print('Email: ${creds['email']}');
      print('Game ID: ${creds['gameId']}');
    } catch (e) {
      print('Failed to load credentials: $e');
      print('Using default test - will just show app');
      creds = {};
    }

    // Start app
    runApp(const ProviderScope(child: FiveCrownsApp()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check if already logged in
    final isOnGamesScreen = find.text('No games yet').evaluate().isNotEmpty ||
                            find.text('Create Game').evaluate().isNotEmpty ||
                            find.byType(Card).evaluate().isNotEmpty;
    final isOnLoginScreen = find.widgetWithText(ElevatedButton, 'Login').evaluate().isNotEmpty;

    print('Current state: games=$isOnGamesScreen, login=$isOnLoginScreen');

    if (isOnLoginScreen && creds.isNotEmpty) {
      // Login with credentials
      print('Logging in as ${creds['email']}...');

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), creds['email']);
      await tester.enterText(textFields.at(1), creds['password']);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      print('Login submitted');
    }

    // Now on games screen - find and tap the game
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final gameCards = find.byType(Card);
    print('Found ${gameCards.evaluate().length} game cards');

    if (gameCards.evaluate().isNotEmpty) {
      print('Tapping first game card...');
      await tester.tap(gameCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('Entered game');
    }

    // Print what's on screen now
    final allText = find.byType(Text);
    print('Current screen text:');
    for (final element in allText.evaluate().take(10)) {
      final textWidget = element.widget as Text;
      final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '<rich>';
      print('  - "$data"');
    }

    print('');
    print('Player is ready. Waiting for game interaction...');
    print('Press Ctrl+C to exit.');

    // Keep the test running to allow observation
    for (var i = 0; i < 60; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check for any state changes
      final cards = find.byType(Card).evaluate().length;
      if (i % 10 == 0) {
        print('Still running... ($i/60) - ${cards} cards visible');
      }
    }

    print('Test completed');
  });
}
