import 'dart:async';
import 'dart:convert';
import 'package:fivecrowns_core/fivecrowns_core.dart' as core;
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../db/database.dart';
import '../services/auth_service.dart';

final _log = Logger('WsHub');

/// Manages WebSocket connections and game rooms.
class WsHub {
  final AppDatabase db;
  final AuthService authService;

  /// Active connections: userId -> connection
  final Map<String, WsConnection> _connections = {};

  /// Game rooms: gameId -> set of userIds
  final Map<String, Set<String>> _rooms = {};

  /// In-memory game states: gameId -> GameState
  final Map<String, core.GameState> _gameStates = {};

  /// Server sequence counters: gameId -> serverSeq
  final Map<String, int> _serverSeqs = {};

  WsHub({required this.db, required this.authService});

  /// Handles a new WebSocket connection.
  void handleConnection(WebSocketChannel channel) {
    final connection = WsConnection(channel: channel);

    channel.stream.listen(
      (data) => _handleMessage(connection, data as String),
      onDone: () => _handleDisconnect(connection),
      onError: (_) => _handleDisconnect(connection),
    );
  }

  Future<void> _handleMessage(WsConnection conn, String data) async {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final command = WsCommand.fromJson(json);

      switch (command) {
        case CmdHello cmd:
          await _handleHello(conn, cmd);
        case CmdResync cmd:
          await _handleResync(conn, cmd);
        case CmdJoinGame cmd:
          await _handleJoinGame(conn, cmd);
        case CmdStartGame cmd:
          await _handleStartGame(conn, cmd);
        case CmdDraw cmd:
          await _handleDraw(conn, cmd);
        case CmdDiscard cmd:
          await _handleDiscard(conn, cmd);
        case CmdLayDown cmd:
          await _handleLayDown(conn, cmd);
        case CmdGoOut cmd:
          await _handleGoOut(conn, cmd);
        case CmdLayOff cmd:
          await _handleLayOff(conn, cmd);
        default:
          _sendError(conn, command.clientSeq, 'unknown_command', 'Unknown command type');
      }
    } catch (e) {
      _sendError(conn, null, 'parse_error', 'Failed to parse command');
    }
  }

  void _handleDisconnect(WsConnection conn) {
    if (conn.userId != null) {
      _log.info('User disconnected: ${conn.userId}');
      _connections.remove(conn.userId);
      // Don't remove from rooms - allow reconnect
    }
  }

  Future<void> _handleHello(WsConnection conn, CmdHello cmd) async {
    final userId = await authService.validateAccessToken(cmd.jwt);
    if (userId == null) {
      _sendError(conn, cmd.clientSeq, 'invalid_token', 'Invalid or expired JWT');
      return;
    }

    final user = await authService.findUserById(userId);
    if (user == null) {
      _sendError(conn, cmd.clientSeq, 'user_not_found', 'User not found');
      return;
    }

    conn.userId = userId;
    _connections[userId] = conn;

    _log.info('User connected: $userId (${user.username})');

    conn.send(EvtHello(userId: userId, username: user.username).toJson());
  }

  Future<void> _handleResync(WsConnection conn, CmdResync cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    // Join room
    _rooms.putIfAbsent(cmd.gameId, () => {});
    _rooms[cmd.gameId]!.add(conn.userId!);

    // Send state
    await _sendState(conn, cmd.gameId, gameState);
  }

  Future<void> _handleJoinGame(WsConnection conn, CmdJoinGame cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    // Verify user is in game in database
    final player = await (db.select(db.gamePlayers)
      ..where((gp) => gp.gameId.equals(cmd.gameId) & gp.userId.equals(conn.userId!)))
        .getSingleOrNull();

    if (player == null) {
      _sendError(conn, cmd.clientSeq, 'not_in_game', 'You are not in this game');
      return;
    }

    // Join room
    _rooms.putIfAbsent(cmd.gameId, () => {});
    _rooms[cmd.gameId]!.add(conn.userId!);

    // Load and send state
    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState != null) {
      await _sendState(conn, cmd.gameId, gameState);
    }
  }

  Future<void> _handleStartGame(WsConnection conn, CmdStartGame cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final game = await (db.select(db.games)..where((g) => g.id.equals(cmd.gameId))).getSingleOrNull();
    if (game == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    if (game.createdBy != conn.userId) {
      _sendError(conn, cmd.clientSeq, 'not_owner', 'Only the game creator can start the game');
      return;
    }

    if (game.status != 'lobby') {
      _sendError(conn, cmd.clientSeq, 'already_started', 'Game already started');
      return;
    }

    // Get players
    final players = await (db.select(db.gamePlayers)
      ..where((gp) => gp.gameId.equals(cmd.gameId))
      ..orderBy([(gp) => OrderingTerm.asc(gp.seat)]))
        .get();

    if (players.length < 2) {
      _sendError(conn, cmd.clientSeq, 'not_enough_players', 'Need at least 2 players');
      return;
    }

    // Create game state
    final gameState = core.GameState.create(
      gameId: cmd.gameId,
      playerIds: players.map((p) => p.userId).toList(),
    );
    gameState.startGame();

    _gameStates[cmd.gameId] = gameState;
    _serverSeqs[cmd.gameId] = 1;

    // Update database
    await (db.update(db.games)..where((g) => g.id.equals(cmd.gameId)))
        .write(const GamesCompanion(status: Value('active')));

    // Save initial snapshot
    await _saveSnapshot(cmd.gameId, gameState);

    // Broadcast state to all players
    await _broadcastState(cmd.gameId, gameState);
  }

  Future<void> _handleDraw(WsConnection conn, CmdDraw cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    if (gameState.currentPlayer.id != conn.userId) {
      _sendError(conn, cmd.clientSeq, 'not_your_turn', 'Not your turn');
      return;
    }

    try {
      final core.Card card;
      if (cmd.from == DrawSource.stock) {
        card = gameState.drawFromStock();
      } else {
        card = gameState.drawFromDiscard();
      }

      await _persistEvent(cmd.gameId, 'cardDrawn', {'from': cmd.from.name, 'card': card.encode()});
      await _broadcastState(cmd.gameId, gameState);
    } catch (e) {
      _sendError(conn, cmd.clientSeq, 'invalid_move', e.toString());
    }
  }

  Future<void> _handleDiscard(WsConnection conn, CmdDiscard cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    if (gameState.currentPlayer.id != conn.userId) {
      _sendError(conn, cmd.clientSeq, 'not_your_turn', 'Not your turn');
      return;
    }

    try {
      final card = core.Card.decode(cmd.card);
      gameState.discard(card);

      await _persistEvent(cmd.gameId, 'cardDiscarded', {'card': cmd.card});
      await _checkGameEnd(cmd.gameId, gameState);
      await _broadcastState(cmd.gameId, gameState);
    } catch (e) {
      _sendError(conn, cmd.clientSeq, 'invalid_move', e.toString());
    }
  }

  Future<void> _handleLayDown(WsConnection conn, CmdLayDown cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    if (gameState.currentPlayer.id != conn.userId) {
      _sendError(conn, cmd.clientSeq, 'not_your_turn', 'Not your turn');
      return;
    }

    try {
      final melds = cmd.melds.map((m) => m.map((c) => core.Card.decode(c)).toList()).toList();
      gameState.layMelds(melds);

      await _persistEvent(cmd.gameId, 'meldsLaid', {'melds': cmd.melds});
      await _broadcastState(cmd.gameId, gameState);
    } catch (e) {
      _sendError(conn, cmd.clientSeq, 'invalid_move', e.toString());
    }
  }

  Future<void> _handleGoOut(WsConnection conn, CmdGoOut cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    if (gameState.currentPlayer.id != conn.userId) {
      _sendError(conn, cmd.clientSeq, 'not_your_turn', 'Not your turn');
      return;
    }

    try {
      final melds = cmd.melds.map((m) => m.map((c) => core.Card.decode(c)).toList()).toList();
      final discard = core.Card.decode(cmd.discard);
      gameState.goOut(melds, discard);

      await _persistEvent(cmd.gameId, 'playerWentOut', {
        'melds': cmd.melds,
        'discard': cmd.discard,
      });
      await _checkGameEnd(cmd.gameId, gameState);
      await _broadcastState(cmd.gameId, gameState);
    } catch (e) {
      _sendError(conn, cmd.clientSeq, 'invalid_move', e.toString());
    }
  }

  Future<void> _handleLayOff(WsConnection conn, CmdLayOff cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final gameState = await _loadOrGetGameState(cmd.gameId);
    if (gameState == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }

    if (gameState.currentPlayer.id != conn.userId) {
      _sendError(conn, cmd.clientSeq, 'not_your_turn', 'Not your turn');
      return;
    }

    try {
      final cards = cmd.cards.map((c) => core.Card.decode(c)).toList();
      gameState.layOff(cmd.targetPlayerIndex, cmd.meldIndex, cards);

      await _persistEvent(cmd.gameId, 'cardsLaidOff', {
        'targetPlayerIndex': cmd.targetPlayerIndex,
        'meldIndex': cmd.meldIndex,
        'cards': cmd.cards,
      });
      await _broadcastState(cmd.gameId, gameState);
    } catch (e) {
      _sendError(conn, cmd.clientSeq, 'invalid_move', e.toString());
    }
  }

  Future<core.GameState?> _loadOrGetGameState(String gameId) async {
    if (_gameStates.containsKey(gameId)) {
      return _gameStates[gameId];
    }

    // Load from snapshot
    final snapshot = await (db.select(db.gameSnapshots)
      ..where((s) => s.gameId.equals(gameId)))
        .getSingleOrNull();

    if (snapshot == null) return null;

    final stateJson = jsonDecode(snapshot.stateJson) as Map<String, dynamic>;
    final gameState = core.GameState.fromFullSnapshot(stateJson);
    _gameStates[gameId] = gameState;
    _serverSeqs[gameId] = snapshot.serverSeq;

    return gameState;
  }

  Future<void> _persistEvent(String gameId, String type, Map<String, dynamic> payload) async {
    final seq = (_serverSeqs[gameId] ?? 0) + 1;
    _serverSeqs[gameId] = seq;

    await db.into(db.gameEvents).insert(GameEventsCompanion.insert(
      gameId: gameId,
      serverSeq: seq,
      type: type,
      payloadJson: Value(jsonEncode(payload)),
    ));

    // Save snapshot after every event to prevent data loss on server crash
    final gameState = _gameStates[gameId];
    if (gameState != null) {
      await _saveSnapshot(gameId, gameState);
    }
  }

  Future<void> _saveSnapshot(String gameId, core.GameState gameState) async {
    final seq = _serverSeqs[gameId] ?? 1;
    final stateJson = jsonEncode(gameState.toFullSnapshot());

    await db.into(db.gameSnapshots).insertOnConflictUpdate(
      GameSnapshotsCompanion.insert(
        gameId: gameId,
        serverSeq: seq,
        stateJson: stateJson,
      ),
    );
  }

  Future<void> _checkGameEnd(String gameId, core.GameState gameState) async {
    if (gameState.status == core.GameStatus.finished) {
      // Update game status
      await (db.update(db.games)..where((g) => g.id.equals(gameId)))
          .write(GamesCompanion(
            status: const Value('finished'),
            finishedAt: Value(DateTime.now().toUtc()),
          ));

      // Save final snapshot
      await _saveSnapshot(gameId, gameState);

      // Record results
      final winners = gameState.winners;
      final winnerId = winners.isNotEmpty ? winners.first.id : null;
      final scores = <String, int>{};
      for (final p in gameState.players) {
        scores[p.id] = p.score;
      }

      await db.into(db.gameResults).insert(GameResultsCompanion.insert(
        gameId: gameId,
        winnerUserId: Value(winnerId),
        scoresJson: jsonEncode(scores),
      ));

      // Update user stats for all players
      for (final player in gameState.players) {
        final existingStats = await (db.select(db.userStats)
              ..where((s) => s.userId.equals(player.id)))
            .getSingleOrNull();

        if (existingStats != null) {
          await (db.update(db.userStats)
                ..where((s) => s.userId.equals(player.id)))
              .write(UserStatsCompanion(
            gamesPlayed: Value(existingStats.gamesPlayed + 1),
            gamesWon: Value(existingStats.gamesWon + (player.id == winnerId ? 1 : 0)),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
        } else {
          await db.into(db.userStats).insert(UserStatsCompanion.insert(
            userId: player.id,
            gamesPlayed: const Value(1),
            gamesWon: Value(player.id == winnerId ? 1 : 0),
          ));
        }
      }
    }
  }

  Future<void> _broadcastState(String gameId, core.GameState gameState) async {
    final room = _rooms[gameId];
    if (room == null) return;

    for (final userId in room) {
      final conn = _connections[userId];
      if (conn != null) {
        await _sendState(conn, gameId, gameState);
      }
    }
  }

  Future<void> _sendState(WsConnection conn, String gameId, core.GameState gameState) async {
    final seq = _serverSeqs[gameId] ?? 1;
    final stateJson = gameState.toPlayerView(conn.userId!);

    // Enrich player data with username/displayName from database
    final players = stateJson['players'] as List<dynamic>;
    for (final player in players) {
      final playerMap = player as Map<String, dynamic>;
      final userId = playerMap['id'] as String;
      final user = await (db.select(db.users)..where((u) => u.id.equals(userId))).getSingleOrNull();
      if (user != null) {
        playerMap['username'] = user.username;
        playerMap['displayName'] = user.displayName;
      }
    }

    final state = GameStateDto.fromJson(stateJson);

    conn.send(EvtState(
      serverSeq: seq,
      gameId: gameId,
      state: state,
    ).toJson());
  }

  void _sendError(WsConnection conn, int? clientSeq, String code, String message) {
    conn.send(EvtError(
      clientSeq: clientSeq,
      code: code,
      message: message,
    ).toJson());
  }

  bool _requireAuth(WsConnection conn, int clientSeq) {
    if (conn.userId == null) {
      _sendError(conn, clientSeq, 'not_authenticated', 'Must send cmd.hello first');
      return false;
    }
    return true;
  }

  // ========== Public notification methods ==========

  /// Send a notification to a specific user (if connected)
  void sendNotificationToUser(String userId, EvtNotification notification) {
    final conn = _connections[userId];
    if (conn != null) {
      conn.send(notification.toJson());
      _log.fine('Notification sent to $userId: ${notification.notificationType}');
    }
  }

  /// Get the current player ID for an active game (null if game not found or not active)
  Future<String?> getCurrentPlayerId(String gameId) async {
    final gameState = await _loadOrGetGameState(gameId);
    if (gameState == null) return null;
    return gameState.currentPlayer.id;
  }

  /// Send a game deleted event to all players in a game
  void sendGameDeletedToPlayers(List<String> playerIds, EvtGameDeleted event) {
    for (final userId in playerIds) {
      final conn = _connections[userId];
      if (conn != null) {
        conn.send(event.toJson());
      }
    }
    // Clean up room if exists
    _rooms.remove(event.gameId);
    _gameStates.remove(event.gameId);
    _serverSeqs.remove(event.gameId);
  }
}

class WsConnection {
  final WebSocketChannel channel;
  String? userId;

  WsConnection({required this.channel});

  void send(Map<String, dynamic> message) {
    channel.sink.add(jsonEncode(message));
  }
}
