import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart' as app;

import 'test_helpers.dart';

/// Integration test for inviting friends to games.
/// This test verifies the fix for the "Too many elements" error that occurred
/// when inviting friends after a mutual friendship was established.
///
/// Run with:
///   flutter test integration_test/invite_friend_test.dart -d <simulator-id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Invite Friend to Game', () {
    testWidgets('Host can invite friend after mutual friendship accepted', (tester) async {
      // This test covers the bug fix where inviting a friend failed with
      // "Too many elements" error because accepted friendships create two rows
      // in the database (one for each direction).

      // Step 1: Create two verified users
      final host = await createVerifiedUser();
      expect(host, isNotNull, reason: 'Failed to create host user');

      final guest = await createVerifiedUser();
      expect(guest, isNotNull, reason: 'Failed to create guest user');

      print('Created host: ${host!['email']}');
      print('Created guest: ${guest!['email']}');

      // Step 2: Login both users to get access tokens
      final hostTokens = await loginUser(host['email']!, host['password']!);
      expect(hostTokens, isNotNull, reason: 'Failed to login host');

      final guestTokens = await loginUser(guest['email']!, guest['password']!);
      expect(guestTokens, isNotNull, reason: 'Failed to login guest');

      // Step 3: Get user IDs
      final hostInfo = await getMe(hostTokens!['accessJwt']);
      expect(hostInfo, isNotNull, reason: 'Failed to get host info');

      final guestInfo = await getMe(guestTokens!['accessJwt']);
      expect(guestInfo, isNotNull, reason: 'Failed to get guest info');

      print('Host ID: ${hostInfo!['id']}');
      print('Guest ID: ${guestInfo!['id']}');

      // Step 4: Create mutual friendship (this creates TWO rows in friendships table)
      // Host sends friend request
      final requestSent = await sendFriendRequest(hostTokens['accessJwt'], guestInfo['id']);
      expect(requestSent, isTrue, reason: 'Failed to send friend request');

      // Guest accepts friend request (this is where the bug manifested)
      final accepted = await acceptFriendRequest(guestTokens['accessJwt'], hostInfo['id']);
      expect(accepted, isTrue, reason: 'Failed to accept friend request');

      print('Friendship established between host and guest');

      // Step 5: Create a game
      final game = await createGame(hostTokens['accessJwt'], maxPlayers: 2);
      expect(game, isNotNull, reason: 'Failed to create game');
      print('Game created: ${game!['gameId']}');

      // Step 6: Invite guest - THIS WAS FAILING before the fix
      final invited = await invitePlayer(hostTokens['accessJwt'], game['gameId'], guestInfo['id']);
      expect(invited, isTrue, reason: 'Failed to invite friend to game');

      print('Successfully invited friend to game!');

      // Step 7: Verify both players are in the game
      final games = await getGames(hostTokens['accessJwt']);
      expect(games, isNotNull);
      expect(games!.length, greaterThan(0));

      final ourGame = games.firstWhere((g) => g['id'] == game['gameId'], orElse: () => null);
      expect(ourGame, isNotNull, reason: 'Game not found in games list');
      expect(ourGame['players'].length, equals(2), reason: 'Expected 2 players in game');

      print('Verified game has 2 players');

      // Step 8: Launch the app and verify we can see the game
      app.main();
      await tester.pumpAndSettle();

      // Login as host
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), host['email']!);
      await tester.enterText(textFields.at(1), host['password']!);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on the games screen
      expect(find.text('My Games'), findsOneWidget);
      print('Host logged in and sees games screen');

      // Find and tap the game
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final gameCards = find.byType(Card);
      expect(gameCards.evaluate().isNotEmpty, isTrue, reason: 'No game cards found');

      await tester.tap(gameCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Host entered game lobby');
      print('Test completed successfully!');
    });

    testWidgets('Mutual friend request auto-accepts correctly', (tester) async {
      // Test the case where both users send friend requests to each other

      final user1 = await createVerifiedUser();
      expect(user1, isNotNull);

      final user2 = await createVerifiedUser();
      expect(user2, isNotNull);

      final tokens1 = await loginUser(user1!['email']!, user1['password']!);
      final tokens2 = await loginUser(user2!['email']!, user2['password']!);

      final info1 = await getMe(tokens1!['accessJwt']);
      final info2 = await getMe(tokens2!['accessJwt']);

      // User1 sends friend request to user2
      await sendFriendRequest(tokens1['accessJwt'], info2!['id']);

      // User2 sends friend request to user1 (should auto-accept)
      await sendFriendRequest(tokens2['accessJwt'], info1!['id']);

      // Create game as user1
      final game = await createGame(tokens1['accessJwt'], maxPlayers: 2);
      expect(game, isNotNull);

      // Invite user2 - should work despite mutual friend requests
      final invited = await invitePlayer(tokens1['accessJwt'], game!['gameId'], info2['id']);
      expect(invited, isTrue, reason: 'Failed to invite friend after mutual requests');

      print('Mutual friend request auto-accept works correctly');
    });
  });
}
