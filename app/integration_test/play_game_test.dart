import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart';

/// Play game test - actually starts and plays the game.
///
/// Run on two simulators:
///   flutter test integration_test/play_game_test.dart -d <sim1-id> --dart-define=CREDS_FILE=/tmp/host_creds.json --dart-define=IS_HOST=true
///   flutter test integration_test/play_game_test.dart -d <sim2-id> --dart-define=CREDS_FILE=/tmp/guest_creds.json --dart-define=IS_HOST=false
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Play game - join, start, and take turns', (tester) async {
    const credsFile = String.fromEnvironment('CREDS_FILE', defaultValue: '/tmp/host_creds.json');

    Map<String, dynamic> creds;
    try {
      final content = File(credsFile).readAsStringSync();
      creds = jsonDecode(content);
    } catch (e) {
      print('Failed to load credentials: $e');
      return;
    }

    // Read isHost from credentials file to avoid dart-define issues with concurrent builds
    final isHost = creds['isHost'] == true;

    print('=== PLAY GAME TEST ===');
    print('Role: ${isHost ? "HOST" : "GUEST"}');
    print('Credentials: $credsFile');
    print('Email: ${creds['email']}');

    // Start app
    runApp(const ProviderScope(child: FiveCrownsApp()));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Always try to log in with the test credentials
    // This ensures we're logged in as the correct user even if cached state exists
    print('Attempting login as ${creds['email']}...');

    // First, check if we need to log out
    final logoutButton = find.text('Logout');
    if (logoutButton.evaluate().isNotEmpty) {
      print('Already logged in - logging out first...');
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // Wait for login screen
    for (var i = 0; i < 10; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        break;
      }
    }

    // Debug: print what's on screen
    print('Checking screen state...');
    final allText = find.byType(Text);
    for (final element in allText.evaluate().take(10)) {
      final textWidget = element.widget as Text;
      final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
      if (data.isNotEmpty) print('  Screen text: "$data"');
    }

    // Try to find login elements
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    final textFields = find.byType(TextFormField);

    if (loginButton.evaluate().isNotEmpty && textFields.evaluate().length >= 2) {
      print('Found login screen, entering credentials...');
      await tester.enterText(textFields.at(0), creds['email']);
      await tester.enterText(textFields.at(1), creds['password']);
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('Login submitted');
    } else {
      print('Login button: ${loginButton.evaluate().isNotEmpty}, textFields: ${textFields.evaluate().length}');
      // May already be on games screen, continue
    }

    // Wait for games screen
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Debug current state
    print('After login, screen shows:');
    for (final element in find.byType(Text).evaluate().take(8)) {
      final textWidget = element.widget as Text;
      final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
      if (data.isNotEmpty) print('  $data');
    }

    // Find and tap the specific game by ID
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final gameId = creds['gameId'] as String;
    final gameIdPrefix = gameId.substring(0, 8);
    print('Looking for game: $gameIdPrefix');

    // Try to find the specific game card
    final targetGameText = find.textContaining('Game $gameIdPrefix');
    if (targetGameText.evaluate().isNotEmpty) {
      print('Found target game, tapping...');
      await tester.tap(targetGameText.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    } else {
      // List available games for debugging
      print('Target game not found. Available games:');
      final allGameTexts = find.textContaining('Game ');
      for (final element in allGameTexts.evaluate().take(5)) {
        final textWidget = element.widget as Text;
        final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
        print('  - $data');
      }
      // Try tapping first game card as fallback
      final gameCards = find.byType(Card);
      if (gameCards.evaluate().isNotEmpty) {
        print('Fallback: tapping first game card');
        await tester.tap(gameCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }

    // Wait for lobby or active game
    print('Waiting for lobby/game...');
    bool gameAlreadyActive = false;
    bool inLobby = false;
    for (var i = 0; i < 30; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if game is already active (Round text visible)
      final roundText = find.textContaining('Round');
      if (roundText.evaluate().isNotEmpty) {
        gameAlreadyActive = true;
        print('Game already active!');
        break;
      }

      // Check if in lobby with Start Game button
      final startButton = find.text('Start Game');
      if (startButton.evaluate().isNotEmpty) {
        inLobby = true;
        print('Both players in lobby!');
        break;
      }
      print('Waiting... ($i/30)');
    }

    if (!gameAlreadyActive && !inLobby) {
      print('Could not enter lobby or game in time');
      return;
    }

    // If in lobby, handle game start
    if (inLobby && !gameAlreadyActive) {
      if (isHost) {
        print('HOST: Starting game...');
        await tester.tap(find.text('Start Game'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('Game started!');
      } else {
        print('GUEST: Waiting for host to start...');
        // Wait longer for guest - host might not have clicked yet
        for (var i = 0; i < 15; i++) {
          await tester.pumpAndSettle(const Duration(seconds: 2));
          final roundText = find.textContaining('Round');
          if (roundText.evaluate().isNotEmpty) {
            print('Game started by host!');
            gameAlreadyActive = true;
            break;
          }
          print('Waiting for host... ($i/15)');
        }
      }
    }

    // Wait for game to be active (if not already)
    if (!gameAlreadyActive) {
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final roundText = find.textContaining('Round');
        if (roundText.evaluate().isNotEmpty) {
          print('Game is active!');
          break;
        }
      }
    }

    // Play turns
    print('=== PLAYING GAME ===');
    for (var turn = 0; turn < 20; turn++) {
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check turn status
      final yourTurnDraw = find.textContaining('Your turn: Draw');
      final yourTurnDiscard = find.textContaining('Your turn: Discard');
      final waiting = find.textContaining('Waiting');

      if (yourTurnDraw.evaluate().isNotEmpty) {
        print('Turn $turn: Drawing from stock...');

        // Find and tap stock pile (the left pile with layer icon)
        final stockPile = find.byIcon(Icons.layers_rounded);
        if (stockPile.evaluate().isNotEmpty) {
          await tester.tap(stockPile.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('Drew a card');
        }
      } else if (yourTurnDiscard.evaluate().isNotEmpty) {
        print('Turn $turn: Discarding...');

        // Find cards in hand and tap one to select
        final cardWidgets = find.byType(GestureDetector);
        // The hand cards are in the lower part of the screen
        // Let's try to find any card and double-tap to discard

        // Look for card images or containers in the hand area
        final handCards = find.descendant(
          of: find.byType(Wrap),
          matching: find.byType(GestureDetector),
        );

        if (handCards.evaluate().isNotEmpty) {
          // Double tap to discard
          await tester.tap(handCards.first);
          await tester.pumpAndSettle();
          await tester.tap(handCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('Discarded a card');
        } else {
          print('No cards found to discard');
        }
      } else if (waiting.evaluate().isNotEmpty) {
        print('Turn $turn: Waiting for other player...');
      }

      // Check if game ended
      final gameOver = find.text('Game Over!');
      if (gameOver.evaluate().isNotEmpty) {
        print('=== GAME OVER ===');
        break;
      }

      // Small delay between turns
      await Future.delayed(const Duration(seconds: 1));
    }

    // Print final screen state
    print('');
    print('=== FINAL STATE ===');
    final finalText = find.byType(Text);
    for (final element in finalText.evaluate().take(15)) {
      final textWidget = element.widget as Text;
      final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
      if (data.isNotEmpty) {
        print('  $data');
      }
    }

    print('');
    print('Test complete. Waiting for observation...');

    // Keep running for observation
    for (var i = 0; i < 30; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  });
}
