import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart';

/// HOST player test - starts the game
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HOST: Play game', (tester) async {
    const credsFile = '/tmp/host_creds.json';
    const isHost = true;

    Map<String, dynamic> creds;
    try {
      final content = File(credsFile).readAsStringSync();
      creds = jsonDecode(content);
    } catch (e) {
      print('Failed to load credentials: $e');
      return;
    }

    print('=== PLAY GAME TEST ===');
    print('Role: HOST');
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

    // Wait for both players in lobby
    print('Waiting for lobby...');
    for (var i = 0; i < 30; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final startButton = find.text('Start Game');
      if (startButton.evaluate().isNotEmpty) {
        print('Both players in lobby!');
        break;
      }
      print('Waiting... ($i/30)');
    }

    // Start the game
    print('HOST: Starting game...');
    final startButton = find.text('Start Game');
    if (startButton.evaluate().isNotEmpty) {
      await tester.tap(startButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('Game started!');
    }

    // Wait for game to be active
    for (var i = 0; i < 10; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final roundText = find.textContaining('Round');
      if (roundText.evaluate().isNotEmpty) {
        print('Game is active!');
        break;
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
    print('HOST test complete. Waiting for observation...');
    for (var i = 0; i < 30; i++) {
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  });
}
