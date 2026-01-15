import 'dart:async';
import 'dart:convert';
import 'package:fivecrowns_core/fivecrowns_core.dart' as core;
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../db/database.dart';
import '../services/auth_service.dart';

final _log = Logger('WsHub');
const _uuidGen = Uuid();
const _kickVoteTimeout = Duration(seconds: 60);

/// In-memory kick vote state
class ActiveKickVote {
  final String voteId;
  final String gameId;
  final String targetUserId;
  final String initiatorUserId;
  final DateTime expiresAt;
  final Set<String> votedFor = {};
  final Set<String> votedAgainst = {};
  Timer? expirationTimer;

  ActiveKickVote({
    required this.voteId,
    required this.gameId,
    required this.targetUserId,
    required this.initiatorUserId,
    required this.expiresAt,
  });
}

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

  /// Active kick votes: gameId -> vote (only one per game at a time)
  final Map<String, ActiveKickVote> _activeKickVotes = {};

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
        case CmdVideoAutoStart _:
          // TODO: Handle video auto-start setting
          break;
        case CmdInitiateKick cmd:
          await _handleInitiateKick(conn, cmd);
        case CmdVoteKick cmd:
          await _handleVoteKick(conn, cmd);
        default:
          _sendError(conn, command.clientSeq, 'unknown_command', 'Unknown command type');
      }
    } catch (e) {
      _sendError(conn, null, 'parse_error', 'Failed to parse command');
    }
  }

  void _handleDisconnect(WsConnection conn) {
    if (conn.userId != null) {
      final userId = conn.userId!;
      _log.info('User disconnected: $userId');
      _connections.remove(userId);
      // Don't remove from rooms - allow reconnect

      // Run async disconnect tasks without blocking
      _processDisconnect(userId);
    }
  }

  Future<void> _processDisconnect(String userId) async {
    try {
      // Get display name for notification
      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();
      final displayName = user?.displayName ?? 'Unknown';

      // Broadcast disconnect to all games user is in
      for (final entry in _rooms.entries) {
        if (entry.value.contains(userId)) {
          final gameId = entry.key;
          _broadcastToRoom(
            gameId,
            EvtPlayerDisconnected(
              gameId: gameId,
              odooUserId: userId,
              displayName: displayName,
            ).toJson(),
          );
        }
      }
    } catch (e) {
      _log.warning('Error processing disconnect for $userId: $e');
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

    final userId = conn.userId!;
    final wasInRoom = _rooms[cmd.gameId]?.contains(userId) ?? false;

    // Join room
    _rooms.putIfAbsent(cmd.gameId, () => {});
    _rooms[cmd.gameId]!.add(userId);

    // Broadcast connect event if newly joining
    if (!wasInRoom || !_connections.containsKey(userId)) {
      await _broadcastPlayerConnected(cmd.gameId, userId);
    }

    // Send state
    await _sendState(conn, cmd.gameId, gameState);
  }

  Future<void> _handleJoinGame(WsConnection conn, CmdJoinGame cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final userId = conn.userId!;

    // Verify user is in game in database
    final player = await (db.select(db.gamePlayers)
      ..where((gp) => gp.gameId.equals(cmd.gameId) & gp.userId.equals(userId)))
        .getSingleOrNull();

    if (player == null) {
      _sendError(conn, cmd.clientSeq, 'not_in_game', 'You are not in this game');
      return;
    }

    final wasInRoom = _rooms[cmd.gameId]?.contains(userId) ?? false;

    // Join room
    _rooms.putIfAbsent(cmd.gameId, () => {});
    _rooms[cmd.gameId]!.add(userId);

    // Broadcast connect event if newly joining
    if (!wasInRoom) {
      await _broadcastPlayerConnected(cmd.gameId, userId);
    }

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

    // Enrich player data with username/displayName and isConnected from database
    final players = stateJson['players'] as List<dynamic>;
    for (final player in players) {
      final playerMap = player as Map<String, dynamic>;
      final userId = playerMap['id'] as String;
      final user = await (db.select(db.users)..where((u) => u.id.equals(userId))).getSingleOrNull();
      if (user != null) {
        playerMap['username'] = user.username;
        playerMap['displayName'] = user.displayName;
      }
      // Check if player is currently connected
      playerMap['isConnected'] = _connections.containsKey(userId);
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

  // ========== Connection status helpers ==========

  /// Broadcast a message to all connected users in a game room
  void _broadcastToRoom(String gameId, Map<String, dynamic> message) {
    final room = _rooms[gameId];
    if (room == null) return;

    for (final userId in room) {
      final conn = _connections[userId];
      if (conn != null) {
        conn.send(message);
      }
    }
  }

  /// Broadcast player connected event to all users in a game
  Future<void> _broadcastPlayerConnected(String gameId, String userId) async {
    final user = await (db.select(db.users)
          ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
    final displayName = user?.displayName ?? 'Unknown';

    _broadcastToRoom(
      gameId,
      EvtPlayerConnected(
        gameId: gameId,
        odooUserId: userId,
        displayName: displayName,
      ).toJson(),
    );
  }

  // ========== Kick vote handlers ==========

  Future<void> _handleInitiateKick(WsConnection conn, CmdInitiateKick cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final initiatorId = conn.userId!;

    // Can't kick yourself
    if (cmd.targetUserId == initiatorId) {
      _sendError(conn, cmd.clientSeq, 'cannot_kick_self', 'Cannot kick yourself');
      return;
    }

    // Check game exists and is active (can only kick during active games)
    final game = await (db.select(db.games)..where((g) => g.id.equals(cmd.gameId))).getSingleOrNull();
    if (game == null) {
      _sendError(conn, cmd.clientSeq, 'game_not_found', 'Game not found');
      return;
    }
    if (game.status != 'active') {
      _sendError(conn, cmd.clientSeq, 'game_not_active', 'Can only kick players during an active game');
      return;
    }

    // Check if there's already an active vote for this game
    if (_activeKickVotes.containsKey(cmd.gameId)) {
      _sendError(conn, cmd.clientSeq, 'vote_in_progress', 'A kick vote is already in progress');
      return;
    }

    // Verify both users are in the game
    final players = await (db.select(db.gamePlayers)
          ..where((gp) => gp.gameId.equals(cmd.gameId)))
        .get();

    final playerIds = players.map((p) => p.userId).toSet();
    if (!playerIds.contains(initiatorId)) {
      _sendError(conn, cmd.clientSeq, 'not_in_game', 'You are not in this game');
      return;
    }
    if (!playerIds.contains(cmd.targetUserId)) {
      _sendError(conn, cmd.clientSeq, 'target_not_in_game', 'Target player is not in this game');
      return;
    }

    // Need at least 3 players for a vote (initiator + target + at least 1 voter)
    if (players.length < 3) {
      _sendError(conn, cmd.clientSeq, 'not_enough_players', 'Need at least 3 players for kick vote');
      return;
    }

    // Create vote
    final voteId = _uuidGen.v4();
    final expiresAt = DateTime.now().toUtc().add(_kickVoteTimeout);

    final vote = ActiveKickVote(
      voteId: voteId,
      gameId: cmd.gameId,
      targetUserId: cmd.targetUserId,
      initiatorUserId: initiatorId,
      expiresAt: expiresAt,
    );

    // Initiator automatically votes "for"
    vote.votedFor.add(initiatorId);

    _activeKickVotes[cmd.gameId] = vote;

    // Save to database
    await db.into(db.kickVotes).insert(KickVotesCompanion.insert(
      id: Value(voteId),
      gameId: cmd.gameId,
      targetUserId: cmd.targetUserId,
      initiatorUserId: initiatorId,
      expiresAt: expiresAt,
    ));

    await db.into(db.kickVoteResponses).insert(KickVoteResponsesCompanion.insert(
      voteId: voteId,
      odooUserId: initiatorId,
      approve: 1, // 1 = true, 0 = false
    ));

    // Set expiration timer
    vote.expirationTimer = Timer(_kickVoteTimeout, () => _expireKickVote(cmd.gameId, voteId));

    // Get display names
    final initiator = await (db.select(db.users)
          ..where((u) => u.id.equals(initiatorId)))
        .getSingleOrNull();
    final target = await (db.select(db.users)
          ..where((u) => u.id.equals(cmd.targetUserId)))
        .getSingleOrNull();

    // Calculate votes needed (all other players except target)
    final votesNeeded = players.length - 1; // Everyone except target must vote yes

    // Broadcast vote started to all players
    _broadcastToRoom(
      cmd.gameId,
      EvtKickVoteStarted(
        gameId: cmd.gameId,
        voteId: voteId,
        targetUserId: cmd.targetUserId,
        targetDisplayName: target?.displayName ?? 'Unknown',
        initiatorUserId: initiatorId,
        initiatorDisplayName: initiator?.displayName ?? 'Unknown',
        expiresAt: expiresAt,
        votesNeeded: votesNeeded,
      ).toJson(),
    );

    _log.info('Kick vote started: $voteId for target ${cmd.targetUserId} in game ${cmd.gameId}');
  }

  Future<void> _handleVoteKick(WsConnection conn, CmdVoteKick cmd) async {
    if (!_requireAuth(conn, cmd.clientSeq)) return;

    final voterId = conn.userId!;
    final vote = _activeKickVotes[cmd.gameId];

    if (vote == null || vote.voteId != cmd.voteId) {
      _sendError(conn, cmd.clientSeq, 'vote_not_found', 'Vote not found or expired');
      return;
    }

    // Can't be the target
    if (voterId == vote.targetUserId) {
      _sendError(conn, cmd.clientSeq, 'cannot_vote', 'Target cannot vote on their own kick');
      return;
    }

    // Can't vote twice
    if (vote.votedFor.contains(voterId) || vote.votedAgainst.contains(voterId)) {
      _sendError(conn, cmd.clientSeq, 'already_voted', 'You have already voted');
      return;
    }

    // Record vote
    if (cmd.approve) {
      vote.votedFor.add(voterId);
    } else {
      vote.votedAgainst.add(voterId);
    }

    // Save to database
    await db.into(db.kickVoteResponses).insert(KickVoteResponsesCompanion.insert(
      voteId: cmd.voteId,
      odooUserId: voterId,
      approve: cmd.approve ? 1 : 0, // Convert bool to int
    ));

    // Get player count for this game
    final players = await (db.select(db.gamePlayers)
          ..where((gp) => gp.gameId.equals(cmd.gameId)))
        .get();
    final votesNeeded = players.length - 1; // Everyone except target

    // Broadcast update
    _broadcastToRoom(
      cmd.gameId,
      EvtKickVoteUpdate(
        gameId: cmd.gameId,
        voteId: cmd.voteId,
        votesFor: vote.votedFor.length,
        votesAgainst: vote.votedAgainst.length,
        votesNeeded: votesNeeded,
      ).toJson(),
    );

    // Check if vote is complete
    // If anyone votes against, the vote fails immediately
    if (vote.votedAgainst.isNotEmpty) {
      await _completeKickVote(cmd.gameId, vote, passed: false);
      return;
    }

    // If all required players have voted yes, the vote passes
    if (vote.votedFor.length >= votesNeeded) {
      await _completeKickVote(cmd.gameId, vote, passed: true);
    }
  }

  Future<void> _completeKickVote(String gameId, ActiveKickVote vote, {required bool passed}) async {
    // Cancel timer
    vote.expirationTimer?.cancel();

    // Remove from active votes
    _activeKickVotes.remove(gameId);

    // Update database
    await (db.update(db.kickVotes)..where((kv) => kv.id.equals(vote.voteId)))
        .write(KickVotesCompanion(status: Value(passed ? 'passed' : 'failed')));

    // Get target display name
    final target = await (db.select(db.users)
          ..where((u) => u.id.equals(vote.targetUserId)))
        .getSingleOrNull();
    final targetDisplayName = target?.displayName ?? 'Unknown';

    // Broadcast result
    _broadcastToRoom(
      gameId,
      EvtKickVoteResult(
        gameId: gameId,
        voteId: vote.voteId,
        passed: passed,
        targetUserId: vote.targetUserId,
        targetDisplayName: targetDisplayName,
      ).toJson(),
    );

    if (passed) {
      await _kickPlayer(gameId, vote.targetUserId, targetDisplayName);
    }

    _log.info('Kick vote ${vote.voteId} completed: ${passed ? 'PASSED' : 'FAILED'}');
  }

  void _expireKickVote(String gameId, String voteId) async {
    final vote = _activeKickVotes[gameId];
    if (vote == null || vote.voteId != voteId) return;

    // Vote expired without consensus = failed
    await _completeKickVote(gameId, vote, passed: false);
    _log.info('Kick vote $voteId expired');
  }

  Future<void> _kickPlayer(String gameId, String userId, String displayName) async {
    // Remove player from database
    await (db.delete(db.gamePlayers)
          ..where((gp) => gp.gameId.equals(gameId) & gp.userId.equals(userId)))
        .go();

    // Remove from room
    _rooms[gameId]?.remove(userId);

    // Handle the player's cards - shuffle back into deck
    final gameState = _gameStates[gameId];
    if (gameState != null) {
      gameState.removePlayer(userId);
      await _saveSnapshot(gameId, gameState);
      await _broadcastState(gameId, gameState);
    }

    // Send kicked event to the kicked player
    final conn = _connections[userId];
    if (conn != null) {
      conn.send(EvtPlayerKicked(
        gameId: gameId,
        odooUserId: userId,
        displayName: displayName,
        reason: 'Voted out by other players',
      ).toJson());
    }

    _log.info('Player $userId kicked from game $gameId');
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
