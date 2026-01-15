import 'package:test/test.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

void main() {
  group('CmdInitiateKick', () {
    test('serialization roundtrip', () {
      final cmd = CmdInitiateKick(
        gameId: 'game123',
        targetUserId: 'userToKick',
        clientSeq: 42,
      );

      expect(cmd.type, 'cmd.initiate_kick');
      expect(cmd.gameId, 'game123');
      expect(cmd.targetUserId, 'userToKick');
      expect(cmd.clientSeq, 42);

      final json = cmd.toJson();
      expect(json['type'], 'cmd.initiate_kick');
      expect(json['gameId'], 'game123');
      expect(json['targetUserId'], 'userToKick');
      expect(json['clientSeq'], 42);

      final parsed = WsCommand.fromJson(json) as CmdInitiateKick;
      expect(parsed.gameId, 'game123');
      expect(parsed.targetUserId, 'userToKick');
      expect(parsed.clientSeq, 42);
    });
  });

  group('CmdVoteKick', () {
    test('serialization roundtrip - approve', () {
      final cmd = CmdVoteKick(
        gameId: 'game123',
        voteId: 'vote789',
        approve: true,
        clientSeq: 43,
      );

      expect(cmd.type, 'cmd.vote_kick');
      expect(cmd.approve, true);

      final json = cmd.toJson();
      final parsed = WsCommand.fromJson(json) as CmdVoteKick;
      expect(parsed.voteId, 'vote789');
      expect(parsed.approve, true);
    });

    test('serialization roundtrip - reject', () {
      final cmd = CmdVoteKick(
        gameId: 'game123',
        voteId: 'vote789',
        approve: false,
        clientSeq: 44,
      );

      final json = cmd.toJson();
      final parsed = WsCommand.fromJson(json) as CmdVoteKick;
      expect(parsed.approve, false);
    });
  });
}
