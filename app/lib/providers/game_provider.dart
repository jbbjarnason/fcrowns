import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fivecrowns_core/fivecrowns_core.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';
import '../services/websocket_service.dart' show WebSocketService, WsConnectionState;
import '../services/api_service.dart';

/// Tracks the state of an active kick vote
class KickVoteState {
  final String voteId;
  final String targetUserId;
  final String targetDisplayName;
  final String initiatorUserId;
  final String initiatorDisplayName;
  final DateTime expiresAt;
  final int votesNeeded;
  int votesFor;
  int votesAgainst;

  KickVoteState({
    required this.voteId,
    required this.targetUserId,
    required this.targetDisplayName,
    required this.initiatorUserId,
    required this.initiatorDisplayName,
    required this.expiresAt,
    required this.votesNeeded,
    this.votesFor = 0,
    this.votesAgainst = 0,
  });

  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class GameProvider extends ChangeNotifier {
  final WebSocketService ws;
  final ApiService api;
  bool _disposed = false;

  String? _gameId;
  String? get gameId => _gameId;

  String? _userId;

  // Game state from server
  int _roundNumber = 1;
  int get roundNumber => _roundNumber;

  String? _currentPlayerId;
  String? get currentPlayerId => _currentPlayerId;

  String? _turnPhase;
  String? get turnPhase => _turnPhase;

  bool _isMyTurn = false;
  bool get isMyTurn => _isMyTurn;

  List<String> _hand = [];
  List<String> get hand => _hand;

  String? _discardTop;
  String? get discardTop => _discardTop;

  int _stockCount = 0;
  int get stockCount => _stockCount;

  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> get players => _players;

  List<List<String>> _myMelds = [];
  List<List<String>> get myMelds => _myMelds;

  Map<String, int> _scores = {};
  Map<String, int> get scores => _scores;

  bool _isFinalTurnPhase = false;
  bool get isFinalTurnPhase => _isFinalTurnPhase;

  String? _goOutPlayerId;
  String? get goOutPlayerId => _goOutPlayerId;

  String? _gameStatus;
  String? get gameStatus => _gameStatus;

  String? _error;
  String? get error => _error;

  // Player connection status
  final Map<String, bool> _playerConnected = {};
  Map<String, bool> get playerConnected => Map.unmodifiable(_playerConnected);

  // Active kick vote
  KickVoteState? _activeKickVote;
  KickVoteState? get activeKickVote => _activeKickVote;

  // Was this player kicked?
  bool _wasKicked = false;
  bool get wasKicked => _wasKicked;
  String? _kickReason;
  String? get kickReason => _kickReason;

  // Game log - stores recent actions
  final List<String> _gameLog = [];
  List<String> get gameLog => _gameLog;

  String? _lastAction;
  String? get lastAction => _lastAction;

  StreamSubscription? _eventSubscription;

  GameProvider({required this.ws, required this.api});

  void setUserId(String userId) {
    _userId = userId;
  }

  StreamSubscription? _connectionSubscription;

  Future<void> joinGame(String gameId) async {
    _gameId = gameId;
    _error = null;

    final token = await api.accessToken;
    if (token != null) {
      await ws.connect(token);
      ws.joinGame(gameId);

      _eventSubscription = ws.events.listen(_handleEvent, onError: (e) {
        _error = e.toString();
        notifyListeners();
      });

      // Listen for reconnection to auto-resync (skip initial connection)
      _connectionSubscription?.cancel();
      var isInitialConnection = true;
      _connectionSubscription = ws.connectionStateStream.listen((state) {
        if (state == WsConnectionState.connected && _gameId != null) {
          if (isInitialConnection) {
            isInitialConnection = false;
            return; // Skip resync on initial connect - joinGame already sent
          }
          // Connection restored after disconnect - resync game state
          ws.resync(_gameId!);
        }
      });
    }
  }

  /// Force a resync with the server
  void resync() {
    if (_gameId != null) {
      ws.resync(_gameId!);
    }
  }

  void _handleEvent(WsEvent event) {
    if (event is EvtState) {
      _updateFromGameState(event.state);
    } else if (event is EvtEvent) {
      _handleGameEvent(event);
    } else if (event is EvtError) {
      _error = '${event.code}: ${event.message}';
      notifyListeners();
    } else if (event is EvtPlayerConnected) {
      _handlePlayerConnected(event);
    } else if (event is EvtPlayerDisconnected) {
      _handlePlayerDisconnected(event);
    } else if (event is EvtKickVoteStarted) {
      _handleKickVoteStarted(event);
    } else if (event is EvtKickVoteUpdate) {
      _handleKickVoteUpdate(event);
    } else if (event is EvtKickVoteResult) {
      _handleKickVoteResult(event);
    } else if (event is EvtPlayerKicked) {
      _handlePlayerKicked(event);
    }
  }

  String _getPlayerName(String? playerId) {
    if (playerId == null) return 'Unknown';
    if (playerId == _userId) return 'You';
    final player = _players.where((p) => p['id'] == playerId).firstOrNull;
    if (player != null) {
      return 'Player ${player['seat'] + 1}';
    }
    return 'Player';
  }

  void _addLogEntry(String message) {
    _lastAction = message;
    _gameLog.add(message);
    // Keep only last 20 entries
    if (_gameLog.length > 20) {
      _gameLog.removeAt(0);
    }
  }

  void _handleGameEvent(EvtEvent event) {
    switch (event.eventType) {
      case GameEventType.turnChanged:
        final playerId = event.data['playerId'] as String?;
        final phase = event.data['phase'] as String?;
        if (playerId != null) {
          _currentPlayerId = playerId;
          _turnPhase = phase ?? 'mustDraw';
          _isMyTurn = playerId == _userId;
          _addLogEntry("${_getPlayerName(playerId)}'s turn");
        }
        break;
      case GameEventType.cardDrawn:
        final playerId = event.data['playerId'] as String?;
        final card = event.data['card'] as String?;
        final source = event.data['source'] as String?;
        if (playerId == _userId && card != null) {
          _hand.add(card);
        }
        _turnPhase = 'mustDiscard';
        final sourceText = source == 'discard' ? 'discard pile' : 'stock';
        _addLogEntry("${_getPlayerName(playerId)} drew from $sourceText");
        break;
      case GameEventType.cardDiscarded:
        final playerId = event.data['playerId'] as String?;
        final card = event.data['card'] as String?;
        if (playerId == _userId && card != null) {
          _hand.remove(card);
        }
        _discardTop = card;
        if (card != null) {
          _addLogEntry("${_getPlayerName(playerId)} discarded ${_formatCard(card)}");
        }
        break;
      case GameEventType.meldsLaid:
        final playerId = event.data['playerId'] as String?;
        final melds = (event.data['melds'] as List?)
            ?.map((m) => (m as List).cast<String>())
            .toList();
        if (playerId == _userId && melds != null) {
          for (final meld in melds) {
            for (final card in meld) {
              _hand.remove(card);
            }
            _myMelds.add(meld);
          }
        }
        if (melds != null) {
          _addLogEntry("${_getPlayerName(playerId)} laid ${melds.length} meld(s)");
        }
        break;
      case GameEventType.playerWentOut:
        _goOutPlayerId = event.data['playerId'] as String?;
        _isFinalTurnPhase = true;
        _addLogEntry("${_getPlayerName(_goOutPlayerId)} went out! Final turns.");
        break;
      case GameEventType.roundStarted:
        _roundNumber = (event.data['roundNumber'] as num?)?.toInt() ?? _roundNumber;
        _hand.clear();
        _myMelds.clear();
        _isFinalTurnPhase = false;
        _goOutPlayerId = null;
        _gameLog.clear();
        _addLogEntry("Round $_roundNumber started (wild: ${_roundNumber + 2}s)");
        break;
      case GameEventType.roundEnded:
        final roundScores = event.data['scores'] as Map<String, dynamic>?;
        if (roundScores != null) {
          for (final entry in roundScores.entries) {
            _scores[entry.key] = (_scores[entry.key] ?? 0) + (entry.value as num).toInt();
          }
        }
        _addLogEntry("Round $_roundNumber ended");
        break;
      case GameEventType.gameFinished:
        _gameStatus = 'finished';
        _addLogEntry("Game finished!");
        break;
    }
    notifyListeners();
  }

  String _formatCard(String cardCode) {
    // Format card code like "5h" to "5♥"
    if (cardCode.isEmpty) return cardCode;
    final rank = cardCode.substring(0, cardCode.length - 1);
    final suit = cardCode[cardCode.length - 1];
    final suitSymbol = switch (suit) {
      'h' => '♥',
      'd' => '♦',
      'c' => '♣',
      's' => '♠',
      _ => suit,
    };
    return '$rank$suitSymbol';
  }

  void _updateFromGameState(GameStateDto state) {
    _gameStatus = state.status;
    _roundNumber = state.roundNumber;
    _turnPhase = state.turnPhase;
    _isFinalTurnPhase = state.isFinalTurnPhase;
    _hand = List<String>.from(state.yourHand);
    _discardTop = state.topDiscard;
    _stockCount = state.stockCount;

    // Find current player by index
    if (state.currentPlayerIndex >= 0 && state.currentPlayerIndex < state.players.length) {
      _currentPlayerId = state.players[state.currentPlayerIndex].id;
      _isMyTurn = _currentPlayerId == _userId;
    }

    _players = state.players.map((p) => {
      'id': p.id,
      'seat': p.seat,
      'score': p.score,
      'handCount': p.handCount,
      'melds': p.melds,
      'username': p.username,
      'displayName': p.displayName,
      'isConnected': p.isConnected,
    }).toList();

    // Update connection status map
    for (final player in state.players) {
      _playerConnected[player.id] = player.isConnected;
    }

    // Find my melds from player list
    final myPlayer = state.players.where((p) => p.id == _userId).firstOrNull;
    if (myPlayer != null) {
      _myMelds = myPlayer.melds.map((m) => List<String>.from(m)).toList();
    }

    // Build scores map
    _scores = {};
    for (final player in state.players) {
      _scores[player.id] = player.score;
    }

    notifyListeners();
  }

  void startGame() {
    if (_gameId != null) {
      ws.startGame(_gameId!);
    }
  }

  void drawFromStock() {
    if (_gameId != null && _isMyTurn && _turnPhase == 'mustDraw') {
      ws.draw(_gameId!, DrawSource.stock);
    }
  }

  void drawFromDiscard() {
    if (_gameId != null && _isMyTurn && _turnPhase == 'mustDraw') {
      ws.draw(_gameId!, DrawSource.discard);
    }
  }

  void discard(String card) {
    if (_gameId != null && _isMyTurn && _turnPhase == 'mustDiscard') {
      ws.discard(_gameId!, card);
    }
  }

  void layMelds(List<List<String>> melds) {
    if (_gameId != null && _isMyTurn && _turnPhase == 'mustDiscard') {
      ws.layDown(_gameId!, melds);
    }
  }

  void goOut(List<List<String>> melds, String discard) {
    if (_gameId != null && _isMyTurn && _turnPhase == 'mustDiscard') {
      ws.goOut(_gameId!, melds, discard);
    }
  }

  /// Lay off cards to an existing meld (own or another player's).
  /// Not allowed during final turn phase.
  void layOff(int targetPlayerIndex, int meldIndex, List<String> cards) {
    if (_gameId != null && _isMyTurn && _turnPhase == 'mustDiscard' && !_isFinalTurnPhase) {
      ws.layOff(_gameId!, targetPlayerIndex, meldIndex, cards);
    }
  }

  /// Check if the given cards can extend an existing meld
  bool canExtendMeld(List<String> existingMeldCards, List<String> newCards, MeldType meldType) {
    if (newCards.isEmpty) return false;

    final existingCards = existingMeldCards.map((c) => Card.decode(c)).toList();
    final cardsToAdd = newCards.map((c) => Card.decode(c)).toList();

    final existingMeld = meldType == MeldType.run
        ? Meld.run(existingCards)
        : Meld.book(existingCards);

    return MeldValidator.canExtendMeld(existingMeld, cardsToAdd, _roundNumber);
  }

  /// Check if the given card codes form a valid meld
  bool isValidMeld(List<String> cardCodes) {
    if (cardCodes.length < 3) return false;
    final cards = cardCodes.map((c) => Card.decode(c)).toList();
    return MeldValidator.isValidMeld(cards, _roundNumber);
  }

  bool canGoOut(List<List<String>> melds, String discard) {
    // Create temporary hand without cards in melds
    final remainingHand = List<String>.from(_hand);
    for (final meld in melds) {
      for (final card in meld) {
        remainingHand.remove(card);
      }
    }
    remainingHand.remove(discard);

    // Validate melds
    for (final meld in melds) {
      final cards = meld.map((c) => Card.decode(c)).toList();
      if (!MeldValidator.isValidRun(cards, _roundNumber) &&
          !MeldValidator.isValidBook(cards, _roundNumber)) {
        return false;
      }
    }

    // All cards must be in melds (except discard)
    return remainingHand.isEmpty;
  }

  // ========== Connection status handlers ==========

  void _handlePlayerConnected(EvtPlayerConnected event) {
    _playerConnected[event.odooUserId] = true;
    // Update player in list
    for (var i = 0; i < _players.length; i++) {
      if (_players[i]['id'] == event.odooUserId) {
        _players[i] = Map<String, dynamic>.from(_players[i]);
        _players[i]['isConnected'] = true;
      }
    }
    _addLogEntry('${event.displayName} connected');
    notifyListeners();
  }

  void _handlePlayerDisconnected(EvtPlayerDisconnected event) {
    _playerConnected[event.odooUserId] = false;
    // Update player in list
    for (var i = 0; i < _players.length; i++) {
      if (_players[i]['id'] == event.odooUserId) {
        _players[i] = Map<String, dynamic>.from(_players[i]);
        _players[i]['isConnected'] = false;
      }
    }
    _addLogEntry('${event.displayName} disconnected');
    notifyListeners();
  }

  // ========== Kick vote handlers ==========

  void _handleKickVoteStarted(EvtKickVoteStarted event) {
    _activeKickVote = KickVoteState(
      voteId: event.voteId,
      targetUserId: event.targetUserId,
      targetDisplayName: event.targetDisplayName,
      initiatorUserId: event.initiatorUserId,
      initiatorDisplayName: event.initiatorDisplayName,
      expiresAt: event.expiresAt,
      votesNeeded: event.votesNeeded,
      votesFor: 1, // Initiator's vote
    );
    _addLogEntry('${event.initiatorDisplayName} started vote to kick ${event.targetDisplayName}');
    notifyListeners();
  }

  void _handleKickVoteUpdate(EvtKickVoteUpdate event) {
    if (_activeKickVote?.voteId == event.voteId) {
      _activeKickVote!.votesFor = event.votesFor;
      _activeKickVote!.votesAgainst = event.votesAgainst;
      notifyListeners();
    }
  }

  void _handleKickVoteResult(EvtKickVoteResult event) {
    if (event.passed) {
      _addLogEntry('Vote passed: ${event.targetDisplayName} has been kicked');
    } else {
      _addLogEntry('Vote failed: ${event.targetDisplayName} stays in the game');
    }
    _activeKickVote = null;
    notifyListeners();
  }

  void _handlePlayerKicked(EvtPlayerKicked event) {
    if (event.odooUserId == _userId) {
      _wasKicked = true;
      _kickReason = event.reason;
      _addLogEntry('You have been kicked from the game');
    } else {
      _addLogEntry('${event.displayName} was kicked from the game');
      // Remove player from list
      _players.removeWhere((p) => p['id'] == event.odooUserId);
      _playerConnected.remove(event.odooUserId);
    }
    notifyListeners();
  }

  // ========== Kick vote actions ==========

  /// Initiate a kick vote against another player
  void initiateKickVote(String targetUserId) {
    if (_gameId != null) {
      ws.initiateKick(_gameId!, targetUserId);
    }
  }

  /// Vote on an active kick vote
  void voteOnKick(bool approve) {
    if (_gameId != null && _activeKickVote != null) {
      ws.voteKick(_gameId!, _activeKickVote!.voteId, approve);
    }
  }

  /// Can this user initiate a kick vote?
  bool canInitiateKickVote(String targetUserId) {
    // Can't kick yourself
    if (targetUserId == _userId) return false;
    // Can't kick if there's an active vote
    if (_activeKickVote != null) return false;
    // Need at least 3 players
    if (_players.length < 3) return false;
    // Can only kick during active games (not in lobby or finished)
    if (_gameStatus != 'active') return false;
    return true;
  }

  /// Should this user see the kick vote dialog?
  bool get shouldShowKickVoteDialog {
    if (_activeKickVote == null) return false;
    // Target can't vote
    if (_activeKickVote!.targetUserId == _userId) return false;
    // Initiator already voted
    if (_activeKickVote!.initiatorUserId == _userId) return false;
    return true;
  }

  /// Clear kicked status (for navigation purposes)
  void clearKickedStatus() {
    _wasKicked = false;
    _kickReason = null;
    notifyListeners();
  }

  Future<void> leaveGame() async {
    if (_disposed) return;
    await _eventSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await ws.disconnect();
    _gameId = null;
    _hand.clear();
    _myMelds.clear();
    _players.clear();
    _scores.clear();
    _playerConnected.clear();
    _activeKickVote = null;
    _wasKicked = false;
    _kickReason = null;
    if (!_disposed) notifyListeners();
  }

  void clearError() {
    _error = null;
    if (!_disposed) notifyListeners();
  }

  /// Nudge the active player (when they're taking too long)
  Future<bool> nudgePlayer(String gameId) async {
    return await api.nudgePlayer(gameId);
  }

  @override
  void dispose() {
    _disposed = true;
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
