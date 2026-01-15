import 'package:test/test.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

void main() {
  group('PlayerStateDto', () {
    test('includes isConnected field', () {
      final dto = PlayerStateDto(
        id: 'user1',
        seat: 0,
        score: 0,
        handCount: 5,
        melds: [],
        isConnected: true,
      );

      expect(dto.isConnected, true);

      final json = dto.toJson();
      expect(json['isConnected'], true);

      final parsed = PlayerStateDto.fromJson(json);
      expect(parsed.isConnected, true);
    });

    test('isConnected defaults to false when not provided', () {
      final json = {
        'id': 'user1',
        'seat': 0,
        'score': 0,
        'handCount': 5,
        'melds': <List<String>>[],
      };

      final dto = PlayerStateDto.fromJson(json);
      expect(dto.isConnected, false);
    });
  });

  group('EvtPlayerConnected', () {
    test('serialization roundtrip', () {
      final evt = EvtPlayerConnected(
        gameId: 'game123',
        odooUserId: 'user456',
        displayName: 'John',
      );

      expect(evt.type, 'evt.player_connected');
      expect(evt.gameId, 'game123');
      expect(evt.odooUserId, 'user456');
      expect(evt.displayName, 'John');

      final json = evt.toJson();
      expect(json['type'], 'evt.player_connected');

      final parsed = WsEvent.fromJson(json) as EvtPlayerConnected;
      expect(parsed.gameId, 'game123');
      expect(parsed.odooUserId, 'user456');
      expect(parsed.displayName, 'John');
    });
  });

  group('EvtPlayerDisconnected', () {
    test('serialization roundtrip', () {
      final evt = EvtPlayerDisconnected(
        gameId: 'game123',
        odooUserId: 'user456',
        displayName: 'John',
      );

      expect(evt.type, 'evt.player_disconnected');

      final json = evt.toJson();
      final parsed = WsEvent.fromJson(json) as EvtPlayerDisconnected;
      expect(parsed.gameId, 'game123');
      expect(parsed.odooUserId, 'user456');
    });
  });

  group('EvtKickVoteStarted', () {
    test('serialization roundtrip', () {
      final expiresAt = DateTime.now().add(Duration(seconds: 60));
      final evt = EvtKickVoteStarted(
        gameId: 'game123',
        voteId: 'vote789',
        targetUserId: 'targetUser',
        targetDisplayName: 'Target Player',
        initiatorUserId: 'initiator',
        initiatorDisplayName: 'Initiator Player',
        expiresAt: expiresAt,
        votesNeeded: 2,
      );

      expect(evt.type, 'evt.kick_vote_started');

      final json = evt.toJson();
      final parsed = WsEvent.fromJson(json) as EvtKickVoteStarted;
      expect(parsed.voteId, 'vote789');
      expect(parsed.targetUserId, 'targetUser');
      expect(parsed.votesNeeded, 2);
    });
  });

  group('EvtKickVoteUpdate', () {
    test('serialization roundtrip', () {
      final evt = EvtKickVoteUpdate(
        gameId: 'game123',
        voteId: 'vote789',
        votesFor: 1,
        votesAgainst: 0,
        votesNeeded: 2,
      );

      expect(evt.type, 'evt.kick_vote_update');

      final json = evt.toJson();
      final parsed = WsEvent.fromJson(json) as EvtKickVoteUpdate;
      expect(parsed.votesFor, 1);
      expect(parsed.votesNeeded, 2);
    });
  });

  group('EvtKickVoteResult', () {
    test('serialization roundtrip - passed', () {
      final evt = EvtKickVoteResult(
        gameId: 'game123',
        voteId: 'vote789',
        passed: true,
        targetUserId: 'targetUser',
        targetDisplayName: 'Target Player',
      );

      expect(evt.type, 'evt.kick_vote_result');

      final json = evt.toJson();
      final parsed = WsEvent.fromJson(json) as EvtKickVoteResult;
      expect(parsed.passed, true);
      expect(parsed.targetUserId, 'targetUser');
    });

    test('serialization roundtrip - failed', () {
      final evt = EvtKickVoteResult(
        gameId: 'game123',
        voteId: 'vote789',
        passed: false,
        targetUserId: 'targetUser',
        targetDisplayName: 'Target Player',
      );

      final json = evt.toJson();
      final parsed = WsEvent.fromJson(json) as EvtKickVoteResult;
      expect(parsed.passed, false);
    });
  });

  group('EvtPlayerKicked', () {
    test('serialization roundtrip', () {
      final evt = EvtPlayerKicked(
        gameId: 'game123',
        odooUserId: 'kickedUser',
        displayName: 'Kicked Player',
        reason: 'Voted out by other players',
      );

      expect(evt.type, 'evt.player_kicked');

      final json = evt.toJson();
      final parsed = WsEvent.fromJson(json) as EvtPlayerKicked;
      expect(parsed.odooUserId, 'kickedUser');
      expect(parsed.reason, 'Voted out by other players');
    });
  });
}
