import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

const _uuid = Uuid();

class GamesRoutes {
  final AppDatabase db;
  final String livekitUrl;
  final String livekitApiKey;
  final String livekitApiSecret;

  GamesRoutes({
    required this.db,
    required this.livekitUrl,
    required this.livekitApiKey,
    required this.livekitApiSecret,
  });

  Router get router {
    final router = Router();

    router.get('/', _listGames);
    router.post('/', _createGame);
    router.get('/<gameId>', _getGame);
    router.post('/<gameId>/invite', _invitePlayer);
    router.post('/<gameId>/livekit-token', _getLivekitToken);

    return router;
  }

  Future<Response> _listGames(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    // Get games the user is part of
    final playerGames = await (db.select(db.gamePlayers)
      ..where((gp) => gp.userId.equals(userId)))
        .get();

    final gameIds = playerGames.map((gp) => gp.gameId).toSet();

    if (gameIds.isEmpty) {
      return Response(200,
          body: jsonEncode({'games': []}),
          headers: {'content-type': 'application/json'});
    }

    final games = await (db.select(db.games)
      ..where((g) => g.id.isIn(gameIds))
      ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
        .get();

    final gameSummaries = <Map<String, dynamic>>[];

    for (final game in games) {
      final players = await _getGamePlayers(game.id);
      gameSummaries.add(GameSummaryDto(
        id: game.id,
        status: GameStatus.fromString(game.status),
        players: players,
        createdBy: game.createdBy,
        createdAt: game.createdAt,
        finishedAt: game.finishedAt,
      ).toJson());
    }

    return Response(200,
        body: jsonEncode({'games': gameSummaries}),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _createGame(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Validate maxPlayers is an integer
      final maxPlayersValue = json['maxPlayers'];
      if (maxPlayersValue != null && maxPlayersValue is! int) {
        return _error(400, 'invalid_max_players', 'Max players must be an integer');
      }

      final req = CreateGameRequest.fromJson(json);

      if (req.maxPlayers < 2 || req.maxPlayers > 7) {
        return _error(400, 'invalid_max_players', 'Max players must be between 2 and 7');
      }

      final gameId = _uuid.v4();

      // Create game
      await db.into(db.games).insert(GamesCompanion.insert(
        id: Value(gameId),
        status: 'lobby',
        createdBy: userId,
        maxPlayers: Value(req.maxPlayers),
      ));

      // Add creator as first player
      await db.into(db.gamePlayers).insert(GamePlayersCompanion.insert(
        gameId: gameId,
        userId: userId,
        seat: 0,
      ));

      return Response(201,
          body: jsonEncode(CreateGameResponse(gameId: gameId).toJson()),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _error(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Future<Response> _getGame(Request request, String gameId) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    final game = await (db.select(db.games)
      ..where((g) => g.id.equals(gameId)))
        .getSingleOrNull();

    if (game == null) {
      return _error(404, 'not_found', 'Game not found');
    }

    // Verify user is a player in this game
    final player = await (db.select(db.gamePlayers)
      ..where((gp) => gp.gameId.equals(gameId) & gp.userId.equals(userId)))
        .getSingleOrNull();

    if (player == null) {
      return _error(403, 'not_in_game', 'You are not a player in this game');
    }

    final players = await _getGamePlayers(gameId);

    return Response(200,
        body: jsonEncode(GameSummaryDto(
          id: game.id,
          status: GameStatus.fromString(game.status),
          players: players,
          createdBy: game.createdBy,
          createdAt: game.createdAt,
          finishedAt: game.finishedAt,
        ).toJson()),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _invitePlayer(Request request, String gameId) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = InviteRequest.fromJson(json);

      final game = await (db.select(db.games)
        ..where((g) => g.id.equals(gameId)))
          .getSingleOrNull();

      if (game == null) {
        return _error(404, 'not_found', 'Game not found');
      }

      if (game.status != 'lobby') {
        return _error(400, 'game_started', 'Cannot invite players to a started game');
      }

      // Verify inviter is in game
      final inviter = await (db.select(db.gamePlayers)
        ..where((gp) => gp.gameId.equals(gameId) & gp.userId.equals(userId)))
          .getSingleOrNull();

      if (inviter == null) {
        return _error(403, 'not_in_game', 'You are not in this game');
      }

      // Check if already in game
      final existing = await (db.select(db.gamePlayers)
        ..where((gp) => gp.gameId.equals(gameId) & gp.userId.equals(req.userId)))
          .getSingleOrNull();

      if (existing != null) {
        return _error(409, 'already_in_game', 'Player is already in the game');
      }

      // Check max players
      final playerCount = await (db.select(db.gamePlayers)
        ..where((gp) => gp.gameId.equals(gameId)))
          .get();

      if (playerCount.length >= game.maxPlayers) {
        return _error(400, 'game_full', 'Game is full');
      }

      // Add player with next seat
      final nextSeat = playerCount.length;
      await db.into(db.gamePlayers).insert(GamePlayersCompanion.insert(
        gameId: gameId,
        userId: req.userId,
        seat: nextSeat,
      ));

      return Response(200,
          body: jsonEncode({'status': 'invited'}),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _error(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Future<Response> _getLivekitToken(Request request, String gameId) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    // Verify user is in game
    final player = await (db.select(db.gamePlayers)
      ..where((gp) => gp.gameId.equals(gameId) & gp.userId.equals(userId)))
        .getSingleOrNull();

    if (player == null) {
      return _error(403, 'not_in_game', 'You are not in this game');
    }

    final roomName = 'game-$gameId';

    // Generate LiveKit JWT
    final token = _createLivekitToken(
      roomName: roomName,
      participantIdentity: userId,
    );

    return Response(200,
        body: jsonEncode(LiveKitTokenResponse(
          url: livekitUrl,
          room: roomName,
          token: token,
        ).toJson()),
        headers: {'content-type': 'application/json'});
  }

  String _createLivekitToken({
    required String roomName,
    required String participantIdentity,
  }) {
    final now = DateTime.now().toUtc();
    final expiry = now.add(const Duration(hours: 24));

    final jwt = JWT(
      {
        'video': {
          'room': roomName,
          'roomJoin': true,
          'canPublish': true,
          'canSubscribe': true,
        },
        'iat': now.millisecondsSinceEpoch ~/ 1000,
      },
      issuer: livekitApiKey,
      subject: participantIdentity,
    );

    return jwt.sign(
      SecretKey(livekitApiSecret),
      expiresIn: expiry.difference(now),
    );
  }

  Future<List<GamePlayerDto>> _getGamePlayers(String gameId) async {
    final players = await (db.select(db.gamePlayers)
      ..where((gp) => gp.gameId.equals(gameId))
      ..orderBy([(gp) => OrderingTerm.asc(gp.seat)]))
        .get();

    final result = <GamePlayerDto>[];
    for (final p in players) {
      final user = await (db.select(db.users)..where((u) => u.id.equals(p.userId))).getSingleOrNull();
      if (user != null) {
        result.add(GamePlayerDto(
          user: UserDto(
            id: user.id,
            username: user.username,
            displayName: user.displayName,
            avatarUrl: user.avatarUrl,
          ),
          seat: p.seat,
          joinedAt: p.joinedAt,
        ));
      }
    }
    return result;
  }

  Response _unauthorized() {
    return Response(401,
        body: jsonEncode({'error': 'unauthorized'}),
        headers: {'content-type': 'application/json'});
  }

  Response _error(int status, String code, String message) {
    return Response(status,
        body: jsonEncode({'error': code, 'message': message}),
        headers: {'content-type': 'application/json'});
  }
}
