import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart';

/// GUEST player test - waits for host to start
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GUEST: Play game', (tester) async {
    const credsFile = '/tmp/guest_creds.json';
    const isHost = false;

    Map<String, dynamic> creds;
    try {
      final content = File(credsFile).readAsStringSync();
      creds = jsonDecode(content);
    } catch (e) {
      print('Failed to load credentials: $e');
      return;
    }

    print('=== PLAY GAME TEST ===');
    print('Role: GUEST');
    print('Credentials: $credsFile');
    print('Email: ${creds['email']}');

    // Start app
    runApp(const ProviderScope(child: FiveCrownsApp()));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Login
    print('Logging in...');
    for (var i = 0; i < 10; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) break;
    }

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    final textFields = find.byType(TextFormField);
    if (loginButton.evaluate().isNotEmpty && textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.at(0), creds['email']);
      await tester.enterText(textFields.at(1), creds['password']);
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('Login complete');
    }

    // Find and tap game
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final gameId = creds['gameId'] as String;
    final gameIdPrefix = gameId.substring(0, 8);
    print('Looking for game: $gameIdPrefix');

    final targetGameText = find.textContaining('Game $gameIdPrefix');
    if (targetGameText.evaluate().isNotEmpty) {
      print('Found target game, tapping...');
      await tester.tap(targetGameText.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // Check if we need to click "Join Game" button (game already in progress)
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final joinGameButton = find.text('Join Game');
    if (joinGameButton.evaluate().isNotEmpty) {
      print('Game in progress, clicking Join Game...');
      await tester.tap(joinGameButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // Wait for lobby or active game
    print('Waiting for lobby/game...');
    bool gameActive = false;
    for (var i = 0; i < 30; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if game is already active
      final roundText = find.textContaining('Round');
      if (roundText.evaluate().isNotEmpty) {
        gameActive = true;
        print('Game already active!');
        break;
      }

      // Check if we need to join (game in progress)
      final joinButton = find.text('Join Game');
      if (joinButton.evaluate().isNotEmpty) {
        print('Clicking Join Game...');
        await tester.tap(joinButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        continue;
      }

      // Check if in lobby
      final startButton = find.text('Start Game');
      if (startButton.evaluate().isNotEmpty) {
        print('In lobby, waiting for host to start...');
        // Wait for host to start
        for (var j = 0; j < 20; j++) {
          await tester.pumpAndSettle(const Duration(seconds: 2));
          final roundText = find.textContaining('Round');
          if (roundText.evaluate().isNotEmpty) {
            gameActive = true;
            print('Game started by host!');
            break;
          }
          print('Waiting for host... ($j/20)');
        }
        break;
      }
      print('Waiting... ($i/30)');
    }

    if (!gameActive) {
      // Final check
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final roundText = find.textContaining('Round');
        if (roundText.evaluate().isNotEmpty) {
          gameActive = true;
          print('Game is active!');
          break;
        }
      }
    }

    // Play turns
    print('=== PLAYING GAME ===');
    for (var turn = 0; turn < 20; turn++) {
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final yourTurnDraw = find.textContaining('Your turn: Draw');
      final yourTurnDiscard = find.textContaining('Your turn: Discard');
      final waiting = find.textContaining('Waiting');

      if (yourTurnDraw.evaluate().isNotEmpty) {
        print('Turn $turn: Drawing from stock...');
        final stockPile = find.byIcon(Icons.layers_rounded);
        if (stockPile.evaluate().isNotEmpty) {
          await tester.tap(stockPile.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('Drew a card');
        }
      } else if (yourTurnDiscard.evaluate().isNotEmpty) {
        print('Turn $turn: Discarding...');
        final handCards = find.descendant(
          of: find.byType(Wrap),
          matching: find.byType(GestureDetector),
        );
        if (handCards.evaluate().isNotEmpty) {
          await tester.tap(handCards.first);
          await tester.pumpAndSettle();
          await tester.tap(handCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('Discarded a card');
        }
      } else if (waiting.evaluate().isNotEmpty) {
        print('Turn $turn: Waiting for other player...');
      }

      final gameOver = find.text('Game Over!');
      if (gameOver.evaluate().isNotEmpty) {
        print('=== GAME OVER ===');
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    print('');
    print('=== FINAL STATE ===');
    final finalText = find.byType(Text);
    for (final element in finalText.evaluate().take(15)) {
      final textWidget = element.widget as Text;
      final data = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
      if (data.isNotEmpty) print('  $data');
    }

    print('');
    print('GUEST test complete. Waiting for observation...');
    for (var i = 0; i < 30; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  });
}
