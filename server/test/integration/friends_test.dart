import 'package:test/test.dart';
import 'test_helpers.dart';

void main() {
  late TestHarness harness;
  late String user1Token;
  late String user2Token;
  late String user3Token;
  late String user1Id;
  late String user2Id;
  late String user3Id;

  setUp(() async {
    harness = TestHarness();
    await harness.setUp();

    // Create three test users
    final (token1, _) = await createVerifiedUser(harness, email: 'user1@test.com', username: 'user1');
    final (token2, _) = await createVerifiedUser(harness, email: 'user2@test.com', username: 'user2');
    final (token3, _) = await createVerifiedUser(harness, email: 'user3@test.com', username: 'user3');

    user1Token = token1;
    user2Token = token2;
    user3Token = token3;

    // Get user IDs
    final me1 = await harness.request('GET', '/users/me', authToken: user1Token);
    final me2 = await harness.request('GET', '/users/me', authToken: user2Token);
    final me3 = await harness.request('GET', '/users/me', authToken: user3Token);

    user1Id = (await harness.parseJson(me1))['id'] as String;
    user2Id = (await harness.parseJson(me2))['id'] as String;
    user3Id = (await harness.parseJson(me3))['id'] as String;
  });

  tearDown(() async {
    await harness.tearDown();
  });

  group('Friends Flow', () {
    test('search users by username prefix', () async {
      final response = await harness.request(
        'GET',
        '/users/search?username=user',
        authToken: user1Token,
      );

      expect(response.statusCode, 200);
      final json = await harness.parseJson(response);
      final users = json['users'] as List;
      expect(users.length, 3);
    });

    test('send friend request', () async {
      final response = await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      expect(response.statusCode, 201);
      final json = await harness.parseJson(response);
      expect(json['status'], 'pending');

      // Check user1's friend list shows pending outgoing
      final friendsResponse = await harness.request(
        'GET',
        '/friends/',
        authToken: user1Token,
      );
      final friendsJson = await harness.parseJson(friendsResponse);
      expect((friendsJson['pendingOutgoing'] as List).length, 1);
      expect((friendsJson['friends'] as List).length, 0);
    });

    test('accept friend request', () async {
      // User1 sends request to User2
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // User2 sees pending incoming
      final pendingResponse = await harness.request(
        'GET',
        '/friends/',
        authToken: user2Token,
      );
      final pendingJson = await harness.parseJson(pendingResponse);
      expect((pendingJson['pendingIncoming'] as List).length, 1);

      // User2 accepts
      final acceptResponse = await harness.request(
        'POST',
        '/friends/accept',
        body: {'userId': user1Id},
        authToken: user2Token,
      );
      expect(acceptResponse.statusCode, 200);

      // Both users should now be friends
      final user1Friends = await harness.request('GET', '/friends/', authToken: user1Token);
      final user2Friends = await harness.request('GET', '/friends/', authToken: user2Token);

      final user1Json = await harness.parseJson(user1Friends);
      final user2Json = await harness.parseJson(user2Friends);

      expect((user1Json['friends'] as List).length, 1);
      expect((user2Json['friends'] as List).length, 1);
      expect((user1Json['pendingOutgoing'] as List).length, 0);
      expect((user2Json['pendingIncoming'] as List).length, 0);
    });

    test('decline friend request', () async {
      // User1 sends request to User2
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // User2 declines
      final declineResponse = await harness.request(
        'POST',
        '/friends/decline',
        body: {'userId': user1Id},
        authToken: user2Token,
      );
      expect(declineResponse.statusCode, 200);

      // No friendship should exist
      final user1Friends = await harness.request('GET', '/friends/', authToken: user1Token);
      final user1Json = await harness.parseJson(user1Friends);
      expect((user1Json['friends'] as List).length, 0);
      expect((user1Json['pendingOutgoing'] as List).length, 0);
    });

    test('mutual friend request auto-accepts', () async {
      // User1 sends request to User2
      await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user2Id},
        authToken: user1Token,
      );

      // User2 also sends request to User1 (before accepting)
      final mutualResponse = await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user1Id},
        authToken: user2Token,
      );

      expect(mutualResponse.statusCode, 200);
      final json = await harness.parseJson(mutualResponse);
      expect(json['status'], 'accepted'); // Auto-accepted

      // Both should be friends now
      final user1Friends = await harness.request('GET', '/friends/', authToken: user1Token);
      final user1Json = await harness.parseJson(user1Friends);
      expect((user1Json['friends'] as List).length, 1);
    });

    test('block user removes friendship', () async {
      // First become friends
      await harness.request('POST', '/friends/request', body: {'userId': user2Id}, authToken: user1Token);
      await harness.request('POST', '/friends/accept', body: {'userId': user1Id}, authToken: user2Token);

      // User1 blocks User2
      final blockResponse = await harness.request(
        'POST',
        '/friends/block',
        body: {'userId': user2Id},
        authToken: user1Token,
      );
      expect(blockResponse.statusCode, 200);

      // No longer friends
      final user1Friends = await harness.request('GET', '/friends/', authToken: user1Token);
      final user1Json = await harness.parseJson(user1Friends);
      expect((user1Json['friends'] as List).length, 0);
    });

    test('blocked user cannot send friend request', () async {
      // User1 blocks User2
      await harness.request('POST', '/friends/block', body: {'userId': user2Id}, authToken: user1Token);

      // User2 tries to send request to User1
      final requestResponse = await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user1Id},
        authToken: user2Token,
      );

      expect(requestResponse.statusCode, 403);
    });

    test('remove friend', () async {
      // Become friends
      await harness.request('POST', '/friends/request', body: {'userId': user2Id}, authToken: user1Token);
      await harness.request('POST', '/friends/accept', body: {'userId': user1Id}, authToken: user2Token);

      // User1 removes User2
      final removeResponse = await harness.request(
        'DELETE',
        '/friends/$user2Id',
        authToken: user1Token,
      );
      expect(removeResponse.statusCode, 200);

      // Both should have no friends
      final user1Friends = await harness.request('GET', '/friends/', authToken: user1Token);
      final user2Friends = await harness.request('GET', '/friends/', authToken: user2Token);

      expect((await harness.parseJson(user1Friends))['friends'] as List, isEmpty);
      expect((await harness.parseJson(user2Friends))['friends'] as List, isEmpty);
    });

    test('cannot send friend request to self', () async {
      final response = await harness.request(
        'POST',
        '/friends/request',
        body: {'userId': user1Id},
        authToken: user1Token,
      );

      expect(response.statusCode, 400);
    });
  });
}
