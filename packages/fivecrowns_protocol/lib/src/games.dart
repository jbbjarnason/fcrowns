/// Game-related REST DTOs.
import 'user.dart';

enum GameStatus {
  lobby,
  active,
  finished;

  static GameStatus fromString(String s) => switch (s) {
        'lobby' => GameStatus.lobby,
        'active' => GameStatus.active,
        'finished' => GameStatus.finished,
        _ => throw ArgumentError('Invalid game status: $s'),
      };
}

class CreateGameRequest {
  final int maxPlayers;

  CreateGameRequest({this.maxPlayers = 7});

  factory CreateGameRequest.fromJson(Map<String, dynamic> json) =>
      CreateGameRequest(maxPlayers: json['maxPlayers'] as int? ?? 7);

  Map<String, dynamic> toJson() => {'maxPlayers': maxPlayers};
}

class CreateGameResponse {
  final String gameId;

  CreateGameResponse({required this.gameId});

  factory CreateGameResponse.fromJson(Map<String, dynamic> json) =>
      CreateGameResponse(gameId: json['gameId'] as String);

  Map<String, dynamic> toJson() => {'gameId': gameId};
}

class InviteRequest {
  final String userId;

  InviteRequest({required this.userId});

  factory InviteRequest.fromJson(Map<String, dynamic> json) =>
      InviteRequest(userId: json['userId'] as String);

  Map<String, dynamic> toJson() => {'userId': userId};
}

class GamePlayerDto {
  final UserDto user;
  final int seat;
  final DateTime joinedAt;

  GamePlayerDto({
    required this.user,
    required this.seat,
    required this.joinedAt,
  });

  factory GamePlayerDto.fromJson(Map<String, dynamic> json) => GamePlayerDto(
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
        seat: json['seat'] as int,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'seat': seat,
        'joinedAt': joinedAt.toIso8601String(),
      };
}

class GameSummaryDto {
  final String id;
  final GameStatus status;
  final List<GamePlayerDto> players;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? finishedAt;

  GameSummaryDto({
    required this.id,
    required this.status,
    required this.players,
    required this.createdBy,
    required this.createdAt,
    this.finishedAt,
  });

  factory GameSummaryDto.fromJson(Map<String, dynamic> json) => GameSummaryDto(
        id: json['id'] as String,
        status: GameStatus.fromString(json['status'] as String),
        players: (json['players'] as List)
            .map((p) => GamePlayerDto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdBy: json['createdBy'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        finishedAt: json['finishedAt'] != null
            ? DateTime.parse(json['finishedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'players': players.map((p) => p.toJson()).toList(),
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      };
}

class LiveKitTokenResponse {
  final String url;
  final String room;
  final String token;

  LiveKitTokenResponse({
    required this.url,
    required this.room,
    required this.token,
  });

  factory LiveKitTokenResponse.fromJson(Map<String, dynamic> json) =>
      LiveKitTokenResponse(
        url: json['url'] as String,
        room: json['room'] as String,
        token: json['token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'room': room,
        'token': token,
      };
}
