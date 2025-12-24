/// WebSocket server -> client event DTOs.

abstract class WsEvent {
  String get type;
  int? get serverSeq;
  String? get gameId;

  Map<String, dynamic> toJson();

  static WsEvent fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'evt.hello' => EvtHello.fromJson(json),
      'evt.state' => EvtState.fromJson(json),
      'evt.event' => EvtEvent.fromJson(json),
      'evt.error' => EvtError.fromJson(json),
      'evt.notification' => EvtNotification.fromJson(json),
      'evt.game_deleted' => EvtGameDeleted.fromJson(json),
      _ => throw ArgumentError('Unknown event type: $type'),
    };
  }
}

class EvtHello implements WsEvent {
  @override
  String get type => 'evt.hello';
  @override
  int? get serverSeq => null;
  @override
  String? get gameId => null;

  final String userId;
  final String username;

  EvtHello({required this.userId, required this.username});

  factory EvtHello.fromJson(Map<String, dynamic> json) => EvtHello(
        userId: json['userId'] as String,
        username: json['username'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'userId': userId,
        'username': username,
      };
}

class PlayerStateDto {
  final String id;
  final int seat;
  final int score;
  final int handCount;
  final List<List<String>> melds;
  final List<String>? hand;
  final String? username;
  final String? displayName;

  PlayerStateDto({
    required this.id,
    required this.seat,
    required this.score,
    required this.handCount,
    required this.melds,
    this.hand,
    this.username,
    this.displayName,
  });

  factory PlayerStateDto.fromJson(Map<String, dynamic> json) => PlayerStateDto(
        id: json['id'] as String,
        seat: json['seat'] as int,
        score: json['score'] as int,
        handCount: json['handCount'] as int,
        melds: (json['melds'] as List)
            .map((m) => (m as List).cast<String>())
            .toList(),
        hand: json['hand'] != null
            ? (json['hand'] as List).cast<String>()
            : null,
        username: json['username'] as String?,
        displayName: json['displayName'] as String?,
      );

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id': id,
      'seat': seat,
      'score': score,
      'handCount': handCount,
      'melds': melds,
    };
    if (hand != null) {
      result['hand'] = hand;
    }
    if (username != null) {
      result['username'] = username;
    }
    if (displayName != null) {
      result['displayName'] = displayName;
    }
    return result;
  }
}

class GameStateDto {
  final String gameId;
  final String status;
  final int roundNumber;
  final int cardsPerHand;
  final String wildRank;
  final int currentPlayerIndex;
  final String turnPhase;
  final bool isFinalTurnPhase;
  final int stockCount;
  final String? topDiscard;
  final List<PlayerStateDto> players;
  final List<String> yourHand;

  GameStateDto({
    required this.gameId,
    required this.status,
    required this.roundNumber,
    required this.cardsPerHand,
    required this.wildRank,
    required this.currentPlayerIndex,
    required this.turnPhase,
    required this.isFinalTurnPhase,
    required this.stockCount,
    this.topDiscard,
    required this.players,
    required this.yourHand,
  });

  factory GameStateDto.fromJson(Map<String, dynamic> json) => GameStateDto(
        gameId: json['gameId'] as String,
        status: json['status'] as String,
        roundNumber: json['roundNumber'] as int,
        cardsPerHand: json['cardsPerHand'] as int,
        wildRank: json['wildRank'] as String,
        currentPlayerIndex: json['currentPlayerIndex'] as int,
        turnPhase: json['turnPhase'] as String,
        isFinalTurnPhase: json['isFinalTurnPhase'] as bool,
        stockCount: json['stockCount'] as int,
        topDiscard: json['topDiscard'] as String?,
        players: (json['players'] as List)
            .map((p) => PlayerStateDto.fromJson(p as Map<String, dynamic>))
            .toList(),
        yourHand: (json['yourHand'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'gameId': gameId,
      'status': status,
      'roundNumber': roundNumber,
      'cardsPerHand': cardsPerHand,
      'wildRank': wildRank,
      'currentPlayerIndex': currentPlayerIndex,
      'turnPhase': turnPhase,
      'isFinalTurnPhase': isFinalTurnPhase,
      'stockCount': stockCount,
      'players': players.map((p) => p.toJson()).toList(),
      'yourHand': yourHand,
    };
    if (topDiscard != null) {
      result['topDiscard'] = topDiscard;
    }
    return result;
  }
}

class EvtState implements WsEvent {
  @override
  String get type => 'evt.state';
  @override
  final int serverSeq;
  @override
  final String gameId;

  final GameStateDto state;

  EvtState({
    required this.serverSeq,
    required this.gameId,
    required this.state,
  });

  factory EvtState.fromJson(Map<String, dynamic> json) => EvtState(
        serverSeq: json['serverSeq'] as int,
        gameId: json['gameId'] as String,
        state: GameStateDto.fromJson(json['state'] as Map<String, dynamic>),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'serverSeq': serverSeq,
        'gameId': gameId,
        'state': state.toJson(),
      };
}

enum GameEventType {
  turnChanged,
  cardDrawn,
  cardDiscarded,
  meldsLaid,
  playerWentOut,
  roundStarted,
  roundEnded,
  gameFinished;

  static GameEventType fromString(String s) => switch (s) {
        'turnChanged' => GameEventType.turnChanged,
        'cardDrawn' => GameEventType.cardDrawn,
        'cardDiscarded' => GameEventType.cardDiscarded,
        'meldsLaid' => GameEventType.meldsLaid,
        'playerWentOut' => GameEventType.playerWentOut,
        'roundStarted' => GameEventType.roundStarted,
        'roundEnded' => GameEventType.roundEnded,
        'gameFinished' => GameEventType.gameFinished,
        _ => throw ArgumentError('Invalid game event type: $s'),
      };
}

class EvtEvent implements WsEvent {
  @override
  String get type => 'evt.event';
  @override
  final int serverSeq;
  @override
  final String gameId;

  final GameEventType eventType;
  final Map<String, dynamic> data;

  EvtEvent({
    required this.serverSeq,
    required this.gameId,
    required this.eventType,
    required this.data,
  });

  factory EvtEvent.fromJson(Map<String, dynamic> json) => EvtEvent(
        serverSeq: json['serverSeq'] as int,
        gameId: json['gameId'] as String,
        eventType: GameEventType.fromString(json['eventType'] as String),
        data: json['data'] as Map<String, dynamic>? ?? {},
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'serverSeq': serverSeq,
        'gameId': gameId,
        'eventType': eventType.name,
        'data': data,
      };
}

class EvtError implements WsEvent {
  @override
  String get type => 'evt.error';
  @override
  int? get serverSeq => null;
  @override
  String? get gameId => _gameId;

  final String? _gameId;
  final int? clientSeq;
  final String code;
  final String message;

  EvtError({
    String? gameId,
    this.clientSeq,
    required this.code,
    required this.message,
  }) : _gameId = gameId;

  factory EvtError.fromJson(Map<String, dynamic> json) => EvtError(
        gameId: json['gameId'] as String?,
        clientSeq: json['clientSeq'] as int?,
        code: json['code'] as String,
        message: json['message'] as String,
      );

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'type': type,
      'code': code,
      'message': message,
    };
    if (_gameId != null) result['gameId'] = _gameId;
    if (clientSeq != null) result['clientSeq'] = clientSeq;
    return result;
  }
}

/// Notification event types
enum NotificationType {
  gameInvitation,
  friendRequest,
  friendAccepted,
  friendBlocked,
  gameDeleted,
  gameNudge;

  static NotificationType fromString(String s) => switch (s) {
        'game_invitation' => NotificationType.gameInvitation,
        'friend_request' => NotificationType.friendRequest,
        'friend_accepted' => NotificationType.friendAccepted,
        'friend_blocked' => NotificationType.friendBlocked,
        'game_deleted' => NotificationType.gameDeleted,
        'game_nudge' => NotificationType.gameNudge,
        _ => throw ArgumentError('Invalid notification type: $s'),
      };

  String toJsonString() => switch (this) {
        NotificationType.gameInvitation => 'game_invitation',
        NotificationType.friendRequest => 'friend_request',
        NotificationType.friendAccepted => 'friend_accepted',
        NotificationType.friendBlocked => 'friend_blocked',
        NotificationType.gameDeleted => 'game_deleted',
        NotificationType.gameNudge => 'game_nudge',
      };
}

/// Real-time notification event
class EvtNotification implements WsEvent {
  @override
  String get type => 'evt.notification';
  @override
  int? get serverSeq => null;
  @override
  String? get gameId => _gameId;

  final String? _gameId;
  final NotificationType notificationType;
  final String? fromUserId;
  final String? fromUsername;
  final String? fromDisplayName;
  final String? message;

  EvtNotification({
    String? gameId,
    required this.notificationType,
    this.fromUserId,
    this.fromUsername,
    this.fromDisplayName,
    this.message,
  }) : _gameId = gameId;

  factory EvtNotification.fromJson(Map<String, dynamic> json) => EvtNotification(
        gameId: json['gameId'] as String?,
        notificationType: NotificationType.fromString(json['notificationType'] as String),
        fromUserId: json['fromUserId'] as String?,
        fromUsername: json['fromUsername'] as String?,
        fromDisplayName: json['fromDisplayName'] as String?,
        message: json['message'] as String?,
      );

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'type': type,
      'notificationType': notificationType.toJsonString(),
    };
    if (_gameId != null) result['gameId'] = _gameId;
    if (fromUserId != null) result['fromUserId'] = fromUserId;
    if (fromUsername != null) result['fromUsername'] = fromUsername;
    if (fromDisplayName != null) result['fromDisplayName'] = fromDisplayName;
    if (message != null) result['message'] = message;
    return result;
  }
}

/// Game deleted event - sent to all players when host deletes a game
class EvtGameDeleted implements WsEvent {
  @override
  String get type => 'evt.game_deleted';
  @override
  int? get serverSeq => null;
  @override
  final String gameId;

  final String deletedByUserId;
  final String deletedByUsername;

  EvtGameDeleted({
    required this.gameId,
    required this.deletedByUserId,
    required this.deletedByUsername,
  });

  factory EvtGameDeleted.fromJson(Map<String, dynamic> json) => EvtGameDeleted(
        gameId: json['gameId'] as String,
        deletedByUserId: json['deletedByUserId'] as String,
        deletedByUsername: json['deletedByUsername'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'deletedByUserId': deletedByUserId,
        'deletedByUsername': deletedByUsername,
      };
}
