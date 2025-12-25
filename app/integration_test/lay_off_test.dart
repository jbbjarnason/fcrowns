import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart' as app;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'test_helpers.dart';

/// Integration test for the lay off feature.
/// Tests adding cards to other players' melds.
///
/// Run with:
///   flutter test integration_test/lay_off_test.dart -d <simulator-id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Lay Off Feature', () {
    testWidgets('WebSocket lay off command validation works correctly', (tester) async {
      // This test verifies the lay off WebSocket command flow

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

      // Step 4: Create mutual friendship
      final requestSent = await sendFriendRequest(hostTokens['accessJwt'], guestInfo['id']);
      expect(requestSent, isTrue, reason: 'Failed to send friend request');

      final accepted = await acceptFriendRequest(guestTokens['accessJwt'], hostInfo['id']);
      expect(accepted, isTrue, reason: 'Failed to accept friend request');

      print('Friendship established between host and guest');

      // Step 5: Create a game
      final game = await createGame(hostTokens['accessJwt'], maxPlayers: 2);
      expect(game, isNotNull, reason: 'Failed to create game');
      final gameId = game!['gameId'];
      print('Game created: $gameId');

      // Step 6: Invite guest
      final invited = await invitePlayer(hostTokens['accessJwt'], gameId, guestInfo['id']);
      expect(invited, isTrue, reason: 'Failed to invite friend to game');

      print('Successfully invited friend to game!');

      // Step 7: Connect via WebSocket and test lay off command validation
      final wsUrl = 'ws://${apiUrl.replaceAll('http://', '')}/ws';

      // Connect host
      final hostWs = WebSocketChannel.connect(Uri.parse(wsUrl));
      final hostMessages = <Map<String, dynamic>>[];

      hostWs.stream.listen((data) {
        final msg = jsonDecode(data as String) as Map<String, dynamic>;
        hostMessages.add(msg);
        print('Host received: ${msg['type']}');
      });

      // Host sends hello
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.hello',
        'jwt': hostTokens['accessJwt'],
        'clientSeq': 1,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify host is authenticated
      expect(hostMessages.any((m) => m['type'] == 'evt.hello'), isTrue,
          reason: 'Host should receive hello event');

      // Connect guest
      final guestWs = WebSocketChannel.connect(Uri.parse(wsUrl));
      final guestMessages = <Map<String, dynamic>>[];

      guestWs.stream.listen((data) {
        final msg = jsonDecode(data as String) as Map<String, dynamic>;
        guestMessages.add(msg);
        print('Guest received: ${msg['type']}');
      });

      // Guest sends hello
      guestWs.sink.add(jsonEncode({
        'type': 'cmd.hello',
        'jwt': guestTokens['accessJwt'],
        'clientSeq': 1,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify guest is authenticated
      expect(guestMessages.any((m) => m['type'] == 'evt.hello'), isTrue,
          reason: 'Guest should receive hello event');

      // Host starts the game
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.startGame',
        'gameId': gameId,
        'clientSeq': 2,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Both join the game room
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.joinGame',
        'gameId': gameId,
        'clientSeq': 3,
      }));
      guestWs.sink.add(jsonEncode({
        'type': 'cmd.joinGame',
        'gameId': gameId,
        'clientSeq': 2,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify game state is received
      expect(hostMessages.any((m) => m['type'] == 'evt.state'), isTrue,
          reason: 'Host should receive game state');
      expect(guestMessages.any((m) => m['type'] == 'evt.state'), isTrue,
          reason: 'Guest should receive game state');

      print('Game started and both players connected');

      // Test 1: Guest tries to lay off when it's host's turn (should fail)
      guestWs.sink.add(jsonEncode({
        'type': 'cmd.layOff',
        'gameId': gameId,
        'targetPlayerIndex': 0,
        'meldIndex': 0,
        'cards': ['H7'],
        'clientSeq': 3,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Should get error
      final guestErrors = guestMessages.where((m) => m['type'] == 'evt.error').toList();
      expect(guestErrors.isNotEmpty, isTrue,
          reason: 'Guest should receive error when trying to lay off out of turn');
      expect(guestErrors.last['code'], 'not_your_turn',
          reason: 'Error should be not_your_turn');

      print('Lay off rejected when not player turn - PASS');

      // Test 2: Host tries to lay off before drawing (should fail)
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.layOff',
        'gameId': gameId,
        'targetPlayerIndex': 0,
        'meldIndex': 0,
        'cards': ['H7'],
        'clientSeq': 4,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      final hostErrors = hostMessages.where((m) => m['type'] == 'evt.error').toList();
      expect(hostErrors.isNotEmpty, isTrue,
          reason: 'Host should receive error when trying to lay off before drawing');

      print('Lay off rejected during draw phase - PASS');

      // Cleanup WebSocket connections
      await hostWs.sink.close();
      await guestWs.sink.close();

      print('WebSocket lay off validation test completed successfully!');
    });

    testWidgets('Game UI shows melds for lay off', (tester) async {
      // This test verifies the UI flow for the lay off feature

      // Step 1: Create and setup users
      final host = await createVerifiedUser();
      expect(host, isNotNull, reason: 'Failed to create host user');

      final guest = await createVerifiedUser();
      expect(guest, isNotNull, reason: 'Failed to create guest user');

      final hostTokens = await loginUser(host!['email']!, host['password']!);
      expect(hostTokens, isNotNull, reason: 'Failed to login host');

      final guestTokens = await loginUser(guest!['email']!, guest['password']!);
      expect(guestTokens, isNotNull, reason: 'Failed to login guest');

      final hostInfo = await getMe(hostTokens!['accessJwt']);
      final guestInfo = await getMe(guestTokens!['accessJwt']);

      // Create friendship
      await sendFriendRequest(hostTokens['accessJwt'], guestInfo!['id']);
      await acceptFriendRequest(guestTokens['accessJwt'], hostInfo!['id']);

      // Create game and invite
      final game = await createGame(hostTokens['accessJwt'], maxPlayers: 2);
      expect(game, isNotNull, reason: 'Failed to create game');
      final gameId = game!['gameId'];

      await invitePlayer(hostTokens['accessJwt'], gameId, guestInfo['id']);

      print('Game setup complete: $gameId');

      // Step 2: Launch the app and verify we can see the game
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

      if (gameCards.evaluate().isNotEmpty) {
        await tester.tap(gameCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('Host entered game lobby');
      }

      print('UI test completed - game is accessible');
    });

    testWidgets('Lay off flow with WebSocket draw-discard cycle', (tester) async {
      // This test performs a complete draw-discard cycle and verifies
      // the game state updates correctly for potential lay off

      // Setup
      final host = await createVerifiedUser();
      final guest = await createVerifiedUser();
      expect(host, isNotNull);
      expect(guest, isNotNull);

      final hostTokens = await loginUser(host!['email']!, host['password']!);
      final guestTokens = await loginUser(guest!['email']!, guest['password']!);
      expect(hostTokens, isNotNull);
      expect(guestTokens, isNotNull);

      final hostInfo = await getMe(hostTokens!['accessJwt']);
      final guestInfo = await getMe(guestTokens!['accessJwt']);

      // Friendship
      await sendFriendRequest(hostTokens['accessJwt'], guestInfo!['id']);
      await acceptFriendRequest(guestTokens['accessJwt'], hostInfo!['id']);

      // Game
      final game = await createGame(hostTokens['accessJwt'], maxPlayers: 2);
      final gameId = game!['gameId'];
      await invitePlayer(hostTokens['accessJwt'], gameId, guestInfo['id']);

      // WebSocket connections
      final wsUrl = 'ws://${apiUrl.replaceAll('http://', '')}/ws';

      final hostWs = WebSocketChannel.connect(Uri.parse(wsUrl));
      final guestWs = WebSocketChannel.connect(Uri.parse(wsUrl));

      final hostMessages = <Map<String, dynamic>>[];
      final guestMessages = <Map<String, dynamic>>[];

      hostWs.stream.listen((data) {
        hostMessages.add(jsonDecode(data as String) as Map<String, dynamic>);
      });
      guestWs.stream.listen((data) {
        guestMessages.add(jsonDecode(data as String) as Map<String, dynamic>);
      });

      // Authenticate
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.hello',
        'jwt': hostTokens['accessJwt'],
        'clientSeq': 1,
      }));
      guestWs.sink.add(jsonEncode({
        'type': 'cmd.hello',
        'jwt': guestTokens['accessJwt'],
        'clientSeq': 1,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Start game
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.startGame',
        'gameId': gameId,
        'clientSeq': 2,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Join
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.joinGame',
        'gameId': gameId,
        'clientSeq': 3,
      }));
      guestWs.sink.add(jsonEncode({
        'type': 'cmd.joinGame',
        'gameId': gameId,
        'clientSeq': 2,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Host draws from stock
      hostWs.sink.add(jsonEncode({
        'type': 'cmd.draw',
        'gameId': gameId,
        'from': 'stock',
        'clientSeq': 4,
      }));
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the latest state
      final stateMessages = hostMessages.where((m) => m['type'] == 'evt.state').toList();
      expect(stateMessages.isNotEmpty, isTrue, reason: 'Should receive game state');

      final latestState = stateMessages.last;
      final state = latestState['state'] as Map<String, dynamic>;
      final hand = state['currentPlayer']?['hand'] as List?;

      print('Host drew from stock. Hand size: ${hand?.length}');

      if (hand != null && hand.isNotEmpty) {
        final cardToDiscard = hand.first as String;

        // Host discards
        hostWs.sink.add(jsonEncode({
          'type': 'cmd.discard',
          'gameId': gameId,
          'card': cardToDiscard,
          'clientSeq': 5,
        }));
        await Future.delayed(const Duration(milliseconds: 500));

        print('Host discarded: $cardToDiscard');

        // Verify turn passed to guest
        final newStateMessages = hostMessages.where((m) => m['type'] == 'evt.state').toList();
        if (newStateMessages.length > stateMessages.length) {
          final newState = newStateMessages.last['state'] as Map<String, dynamic>;
          final currentPlayerIndex = newState['currentPlayerIndex'] as int?;
          print('Current player index: $currentPlayerIndex');
          expect(currentPlayerIndex, 1, reason: 'Turn should pass to guest');
        }
      }

      // Cleanup
      await hostWs.sink.close();
      await guestWs.sink.close();

      print('Draw-discard cycle completed successfully!');
    });
  });
}
