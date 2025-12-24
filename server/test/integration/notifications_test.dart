import 'package:test/test.dart';
import 'test_helpers.dart';

void main() {
  late TestHarness harness;
  late String user1Token;
  late String user2Token;
  late String user1Id;
  late String user2Id;

  setUp(() async {
    harness = TestHarness();
    await harness.setUp();

    final (token1, _) = await createVerifiedUser(harness, email: 'user1@test.com', username: 'user1');
    final (token2, _) = await createVerifiedUser(harness, email: 'user2@test.com', username: 'user2');

    user1Token = token1;
    user2Token = token2;

    final me1 = await harness.request('GET', '/users/me', authToken: user1Token);
    final me2 = await harness.request('GET', '/users/me', authToken: user2Token);

    user1Id = (await harness.parseJson(me1))['id'] as String;
    user2Id = (await harness.parseJson(me2))['id'] as String;
  });

  tearDown(() async {
    await harness.tearDown();
  });

  group('Notifications', () {
    test('list notifications returns empty initially', () async {
      final response = await harness.request(
        'GET',
        '/notifications/',
        authToken: user1Token,
      );

      expect(response.statusCode, 200);
      final json = await harness.parseJson(response);
      expect(json['notifications'], isEmpty);
    });

    test('unread count is zero initially', () async {
      final response = await harness.request(
        'GET',
        '/notifications/count',
        authToken: user1Token,
      );

      expect(response.statusCode, 200);
      final json = await harness.parseJson(response);
      expect(json['count'], 0);
    });

    test('friend request creates notification', () async {
      // User1 sends friend request to User2
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // User2 should have a notification
      final response = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );

      expect(response.statusCode, 200);
      final json = await harness.parseJson(response);
      final notifications = json['notifications'] as List;
      expect(notifications.length, 1);
      expect(notifications[0]['type'], 'friend_request');
      expect(notifications[0]['status'], 'pending');
      expect(notifications[0]['fromUser']['id'], user1Id);
    });

    test('friend accepted creates notification', () async {
      // User1 sends friend request to User2
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // User2 accepts
      await harness.request(
        'POST',
        '/friends/accept',
        body: {'userId': user1Id},
        authToken: user2Token,
      );

      // User1 should have a friend_accepted notification
      final response = await harness.request(
        'GET',
        '/notifications/',
        authToken: user1Token,
      );

      expect(response.statusCode, 200);
      final json = await harness.parseJson(response);
      final notifications = json['notifications'] as List;
      expect(notifications.length, 1);
      expect(notifications[0]['type'], 'friend_accepted');
      expect(notifications[0]['fromUser']['id'], user2Id);
    });

    test('game invitation creates notification', () async {
      // First become friends
      await harness.request('POST', '/friends/request', body: {'userId': user2Id}, authToken: user1Token);
      await harness.request('POST', '/friends/accept', body: {'userId': user1Id}, authToken: user2Token);

      // User1 creates a game
      final createResponse = await harness.request(
        'POST',
        '/games/',
        body: {'maxPlayers': 4},
        authToken: user1Token,
      );
      final gameId = (await harness.parseJson(createResponse))['gameId'] as String;

      // User1 invites User2
      await harness.request(
        'POST',
        '/games/$gameId/invite',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // User2 should have a game_invitation notification
      final response = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );

      expect(response.statusCode, 200);
      final json = await harness.parseJson(response);
      final notifications = json['notifications'] as List;
      // User2 has friend_request from setup + game_invitation
      final gameNotification = notifications.firstWhere((n) => n['type'] == 'game_invitation');
      expect(gameNotification['fromUser']['id'], user1Id);
      expect(gameNotification['game']['id'], gameId);
    });

    test('mark notification as read', () async {
      // Create a notification
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // Get notification ID
      final listResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final notifications = (await harness.parseJson(listResponse))['notifications'] as List;
      final notificationId = notifications[0]['id'] as String;

      // Mark as read
      final readResponse = await harness.request(
        'POST',
        '/notifications/$notificationId/read',
        authToken: user2Token,
      );

      expect(readResponse.statusCode, 200);

      // Verify it's read
      final verifyResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final verifiedNotifications = (await harness.parseJson(verifyResponse))['notifications'] as List;
      expect(verifiedNotifications[0]['status'], 'read');
    });

    test('delete notification', () async {
      // Create a notification
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // Get notification ID
      final listResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final notifications = (await harness.parseJson(listResponse))['notifications'] as List;
      final notificationId = notifications[0]['id'] as String;

      // Delete notification
      final deleteResponse = await harness.request(
        'DELETE',
        '/notifications/$notificationId',
        authToken: user2Token,
      );

      expect(deleteResponse.statusCode, 200);

      // Verify it's gone
      final verifyResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final verifiedNotifications = (await harness.parseJson(verifyResponse))['notifications'] as List;
      expect(verifiedNotifications, isEmpty);
    });

    test('clear all notifications', () async {
      // Create multiple notifications
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // Become friends to create another notification
      await harness.request(
        'POST',
        '/friends/accept',
        body: {'userId': user1Id},
        authToken: user2Token,
      );

      // User1 should have friend_accepted notification, User2 should have friend_request
      // Let's verify User2 has at least 1 notification
      final beforeResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final beforeNotifications = (await harness.parseJson(beforeResponse))['notifications'] as List;
      expect(beforeNotifications.isNotEmpty, true);

      // Clear all
      final clearResponse = await harness.request(
        'DELETE',
        '/notifications/',
        authToken: user2Token,
      );

      expect(clearResponse.statusCode, 200);

      // Verify all are gone
      final afterResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final afterNotifications = (await harness.parseJson(afterResponse))['notifications'] as List;
      expect(afterNotifications, isEmpty);
    });

    test('unread count updates correctly', () async {
      // Create a notification
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // Check unread count
      final countResponse1 = await harness.request(
        'GET',
        '/notifications/count',
        authToken: user2Token,
      );
      expect((await harness.parseJson(countResponse1))['count'], 1);

      // Get notification ID and mark as read
      final listResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final notifications = (await harness.parseJson(listResponse))['notifications'] as List;
      final notificationId = notifications[0]['id'] as String;

      await harness.request(
        'POST',
        '/notifications/$notificationId/read',
        authToken: user2Token,
      );

      // Check unread count is now 0
      final countResponse2 = await harness.request(
        'GET',
        '/notifications/count',
        authToken: user2Token,
      );
      expect((await harness.parseJson(countResponse2))['count'], 0);
    });

    test('cannot access other user notifications', () async {
      // Create a notification for user2
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // Get notification ID as user2
      final listResponse = await harness.request(
        'GET',
        '/notifications/',
        authToken: user2Token,
      );
      final notifications = (await harness.parseJson(listResponse))['notifications'] as List;
      final notificationId = notifications[0]['id'] as String;

      // User1 tries to mark user2's notification as read
      final readResponse = await harness.request(
        'POST',
        '/notifications/$notificationId/read',
        authToken: user1Token,
      );

      expect(readResponse.statusCode, 404);

      // User1 tries to delete user2's notification
      final deleteResponse = await harness.request(
        'DELETE',
        '/notifications/$notificationId',
        authToken: user1Token,
      );

      expect(deleteResponse.statusCode, 404);
    });
  });
}
