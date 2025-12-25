/// WebSocket client -> server command DTOs.

abstract class WsCommand {
  String get type;
  int get clientSeq;

  Map<String, dynamic> toJson();

  static WsCommand fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'cmd.hello' => CmdHello.fromJson(json),
      'cmd.resync' => CmdResync.fromJson(json),
      'cmd.joinGame' => CmdJoinGame.fromJson(json),
      'cmd.startGame' => CmdStartGame.fromJson(json),
      'cmd.draw' => CmdDraw.fromJson(json),
      'cmd.discard' => CmdDiscard.fromJson(json),
      'cmd.layDown' => CmdLayDown.fromJson(json),
      'cmd.goOut' => CmdGoOut.fromJson(json),
      'cmd.layOff' => CmdLayOff.fromJson(json),
      'cmd.settings.videoAutoStart' => CmdVideoAutoStart.fromJson(json),
      _ => throw ArgumentError('Unknown command type: $type'),
    };
  }
}

class CmdHello implements WsCommand {
  @override
  String get type => 'cmd.hello';
  final String jwt;
  @override
  final int clientSeq;

  CmdHello({required this.jwt, required this.clientSeq});

  factory CmdHello.fromJson(Map<String, dynamic> json) => CmdHello(
        jwt: json['jwt'] as String,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'jwt': jwt,
        'clientSeq': clientSeq,
      };
}

class CmdResync implements WsCommand {
  @override
  String get type => 'cmd.resync';
  final String gameId;
  @override
  final int clientSeq;

  CmdResync({required this.gameId, required this.clientSeq});

  factory CmdResync.fromJson(Map<String, dynamic> json) => CmdResync(
        gameId: json['gameId'] as String,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'clientSeq': clientSeq,
      };
}

class CmdJoinGame implements WsCommand {
  @override
  String get type => 'cmd.joinGame';
  final String gameId;
  @override
  final int clientSeq;

  CmdJoinGame({required this.gameId, required this.clientSeq});

  factory CmdJoinGame.fromJson(Map<String, dynamic> json) => CmdJoinGame(
        gameId: json['gameId'] as String,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'clientSeq': clientSeq,
      };
}

class CmdStartGame implements WsCommand {
  @override
  String get type => 'cmd.startGame';
  final String gameId;
  @override
  final int clientSeq;

  CmdStartGame({required this.gameId, required this.clientSeq});

  factory CmdStartGame.fromJson(Map<String, dynamic> json) => CmdStartGame(
        gameId: json['gameId'] as String,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'clientSeq': clientSeq,
      };
}

enum DrawSource {
  stock,
  discard;

  static DrawSource fromString(String s) => switch (s) {
        'stock' => DrawSource.stock,
        'discard' => DrawSource.discard,
        _ => throw ArgumentError('Invalid draw source: $s'),
      };
}

class CmdDraw implements WsCommand {
  @override
  String get type => 'cmd.draw';
  final String gameId;
  final DrawSource from;
  @override
  final int clientSeq;

  CmdDraw({required this.gameId, required this.from, required this.clientSeq});

  factory CmdDraw.fromJson(Map<String, dynamic> json) => CmdDraw(
        gameId: json['gameId'] as String,
        from: DrawSource.fromString(json['from'] as String),
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'from': from.name,
        'clientSeq': clientSeq,
      };
}

class CmdDiscard implements WsCommand {
  @override
  String get type => 'cmd.discard';
  final String gameId;
  final String card;
  @override
  final int clientSeq;

  CmdDiscard({
    required this.gameId,
    required this.card,
    required this.clientSeq,
  });

  factory CmdDiscard.fromJson(Map<String, dynamic> json) => CmdDiscard(
        gameId: json['gameId'] as String,
        card: json['card'] as String,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'card': card,
        'clientSeq': clientSeq,
      };
}

class CmdLayDown implements WsCommand {
  @override
  String get type => 'cmd.layDown';
  final String gameId;
  final List<List<String>> melds;
  @override
  final int clientSeq;

  CmdLayDown({
    required this.gameId,
    required this.melds,
    required this.clientSeq,
  });

  factory CmdLayDown.fromJson(Map<String, dynamic> json) => CmdLayDown(
        gameId: json['gameId'] as String,
        melds: (json['melds'] as List)
            .map((m) => (m as List).cast<String>())
            .toList(),
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'melds': melds,
        'clientSeq': clientSeq,
      };
}

class CmdGoOut implements WsCommand {
  @override
  String get type => 'cmd.goOut';
  final String gameId;
  final List<List<String>> melds;
  final String discard;
  @override
  final int clientSeq;

  CmdGoOut({
    required this.gameId,
    required this.melds,
    required this.discard,
    required this.clientSeq,
  });

  factory CmdGoOut.fromJson(Map<String, dynamic> json) => CmdGoOut(
        gameId: json['gameId'] as String,
        melds: (json['melds'] as List)
            .map((m) => (m as List).cast<String>())
            .toList(),
        discard: json['discard'] as String,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'melds': melds,
        'discard': discard,
        'clientSeq': clientSeq,
      };
}

class CmdLayOff implements WsCommand {
  @override
  String get type => 'cmd.layOff';
  final String gameId;
  final int targetPlayerIndex;
  final int meldIndex;
  final List<String> cards;
  @override
  final int clientSeq;

  CmdLayOff({
    required this.gameId,
    required this.targetPlayerIndex,
    required this.meldIndex,
    required this.cards,
    required this.clientSeq,
  });

  factory CmdLayOff.fromJson(Map<String, dynamic> json) => CmdLayOff(
        gameId: json['gameId'] as String,
        targetPlayerIndex: json['targetPlayerIndex'] as int,
        meldIndex: json['meldIndex'] as int,
        cards: (json['cards'] as List).cast<String>(),
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'targetPlayerIndex': targetPlayerIndex,
        'meldIndex': meldIndex,
        'cards': cards,
        'clientSeq': clientSeq,
      };
}

class CmdVideoAutoStart implements WsCommand {
  @override
  String get type => 'cmd.settings.videoAutoStart';
  final String gameId;
  final bool enabled;
  @override
  final int clientSeq;

  CmdVideoAutoStart({
    required this.gameId,
    required this.enabled,
    required this.clientSeq,
  });

  factory CmdVideoAutoStart.fromJson(Map<String, dynamic> json) =>
      CmdVideoAutoStart(
        gameId: json['gameId'] as String,
        enabled: json['enabled'] as bool,
        clientSeq: json['clientSeq'] as int,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'gameId': gameId,
        'enabled': enabled,
        'clientSeq': clientSeq,
      };
}
