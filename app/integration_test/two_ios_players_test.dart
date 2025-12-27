import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart' as app;

import 'test_helpers.dart';

/// This test is designed to be run on two iOS simulators simultaneously.
/// Run with different --dart-define values:
///
/// Simulator 1 (Host):
///   flutter test integration_test/two_ios_players_test.dart -d <sim1-id> --dart-define=PLAYER_ROLE=host
///
/// Simulator 2 (Guest):
///   flutter test integration_test/two_ios_players_test.dart -d <sim2-id> --dart-define=PLAYER_ROLE=guest
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Get player role from dart-define
  const playerRole = String.fromEnvironment('PLAYER_ROLE', defaultValue: 'host');
  // ignore: unused_local_variable
  const sharedGameId = String.fromEnvironment('GAME_ID', defaultValue: '');

  group('Two iOS Players Game - $playerRole', () {
    if (playerRole == 'host') {
      testWidgets('Host: Create game and wait for guest', (tester) async {
        // Create host user
        final hostUser = await createVerifiedUser();
        expect(hostUser, isNotNull);

        // Login host via API to create game
        final tokens = await loginUser(hostUser!['email']!, hostUser['password']!);
        expect(tokens, isNotNull);

        // Create game
        final game = await createGame(tokens!['accessJwt'], maxPlayers: 2);
        expect(game, isNotNull);

        // Create guest user for the other simulator
        final guestUser = await createVerifiedUser();
        expect(guestUser, isNotNull);

        // Get guest user ID
        final guestTokens = await loginUser(guestUser!['email']!, guestUser['password']!);
        final guestInfo = await getMe(guestTokens!['accessJwt']);

        // Invite guest
        final invited = await invitePlayer(
          tokens['accessJwt'],
          game!['gameId'],
          guestInfo!['id'],
        );
        expect(invited, isTrue);

        print('');
        print('========================================');
        print('HOST SETUP COMPLETE');
        print('========================================');
        print('Game ID: ${game['gameId']}');
        print('');
        print('GUEST CREDENTIALS:');
        print('Email: ${guestUser['email']}');
        print('Password: ${guestUser['password']}');
        print('');
        print('Run on second simulator:');
        print('flutter test integration_test/two_ios_players_test.dart \\');
        print('  -d <second-simulator-id> \\');
        print('  --dart-define=PLAYER_ROLE=guest \\');
        print('  --dart-define=GUEST_EMAIL=${guestUser['email']} \\');
        print('  --dart-define=GUEST_PASSWORD=${guestUser['password']}');
        print('========================================');
        print('');

        // Now launch app as host
        app.main();
        await tester.pumpAndSettle();

        // Login
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), hostUser['email']!);
        await tester.enterText(textFields.at(1), hostUser['password']!);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Go to games screen
        expect(find.text('My Games'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find and tap game
        final gameCards = find.byType(Card);
        if (gameCards.evaluate().isNotEmpty) {
          await tester.tap(gameCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        print('Host is in the game lobby');
        print('Waiting for guest to join...');

        // Keep waiting
        for (var i = 0; i < 60; i++) {
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('Waiting... ($i/60)');
        }
      });
    } else {
      testWidgets('Guest: Join game', (tester) async {
        const guestEmail = String.fromEnvironment('GUEST_EMAIL', defaultValue: '');
        const guestPassword = String.fromEnvironment('GUEST_PASSWORD', defaultValue: '');

        // If no credentials provided, create a new user
        String email = guestEmail;
        String password = guestPassword;

        if (email.isEmpty) {
          print('No guest credentials provided, creating new user');
          final user = await createVerifiedUser();
          expect(user, isNotNull);
          email = user!['email']!;
          password = user['password']!;

          print('');
          print('========================================');
          print('GUEST USER CREATED');
          print('Email: $email');
          print('Password: $password');
          print('');
          print('Invite this user to a game from the host');
          print('========================================');
          print('');
        }

        app.main();
        await tester.pumpAndSettle();

        // Login
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), email);
        await tester.enterText(textFields.at(1), password);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Go to games screen
        expect(find.text('My Games'), findsOneWidget);
        print('Guest logged in successfully');

        // Poll for games
        for (var i = 0; i < 30; i++) {
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final gameCards = find.byType(Card);
          if (gameCards.evaluate().isNotEmpty) {
            print('Found ${gameCards.evaluate().length} game(s)');
            await tester.tap(gameCards.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            break;
          }

          print('Waiting for game invite... ($i/30)');
        }

        print('Guest is ready');

        // Keep running
        for (var i = 0; i < 60; i++) {
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      });
    }
  });
}
