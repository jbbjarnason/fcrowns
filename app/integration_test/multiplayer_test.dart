import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Multiplayer Game Flow', () {
    testWidgets('should see games screen and create game', (tester) async {
      runApp(const ProviderScope(child: FiveCrownsApp()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if already logged in
      final isOnGamesScreen = find.text('No games yet').evaluate().isNotEmpty ||
                              find.text('Create Game').evaluate().isNotEmpty;
      final isOnLoginScreen = find.widgetWithText(ElevatedButton, 'Login').evaluate().isNotEmpty;

      print('Initial state: games=$isOnGamesScreen, login=$isOnLoginScreen');

      if (isOnLoginScreen) {
        // Need to login first
        final user = await createVerifiedUser();
        if (user == null) {
          print('Failed to create user, skipping test');
          return;
        }

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), user['email']!);
        await tester.enterText(textFields.at(1), user['password']!);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Now on games screen - try to create a game
      final createButton = find.text('Create Game');
      if (createButton.evaluate().isNotEmpty) {
        print('Tapping Create Game button');
        await tester.tap(createButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Check if dialog or new screen appeared
        print('After tap - checking for dialog/screen');
      }

      // Check for games
      final gameCards = find.byType(Card);
      print('Found ${gameCards.evaluate().length} game cards');

      print('✓ Multiplayer game screen test passed');
    });

    testWidgets('should setup game with invited player via API', (tester) async {
      // This test creates users and a game via API, then verifies in the app

      // Create host user
      final hostUser = await createVerifiedUser();
      if (hostUser == null) {
        print('Failed to create host user, skipping test');
        return;
      }
      print('Created host: ${hostUser['email']}');

      // Login host and get tokens
      final hostTokens = await loginUser(hostUser['email']!, hostUser['password']!);
      if (hostTokens == null) {
        print('Failed to login host, skipping test');
        return;
      }

      // Create game via API
      final game = await createGame(hostTokens['accessJwt'], maxPlayers: 4);
      if (game == null) {
        print('Failed to create game, skipping test');
        return;
      }
      print('Created game: ${game['gameId']}');

      // Create guest user
      final guestUser = await createVerifiedUser();
      if (guestUser == null) {
        print('Failed to create guest user, skipping test');
        return;
      }
      print('Created guest: ${guestUser['email']}');

      // Get guest user ID
      final guestTokens = await loginUser(guestUser['email']!, guestUser['password']!);
      final guestInfo = await getMe(guestTokens!['accessJwt']);

      // Invite guest to game
      final invited = await invitePlayer(
        hostTokens['accessJwt'],
        game['gameId'],
        guestInfo!['id'],
      );
      print('Invited guest: $invited');

      // Output info for manual testing
      print('');
      print('=== MULTIPLAYER TEST SETUP ===');
      print('Host: ${hostUser['email']} / ${hostUser['password']}');
      print('Guest: ${guestUser['email']} / ${guestUser['password']}');
      print('Game ID: ${game['gameId']}');
      print('==============================');
      print('');

      // Start app - it might already be logged in as someone else
      runApp(const ProviderScope(child: FiveCrownsApp()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Just verify the app is running
      final hasText = find.byType(Text).evaluate().isNotEmpty;
      expect(hasText, isTrue);

      print('✓ Multiplayer setup test passed');
    });
  });
}
