/// Friends-related DTOs.
import 'user.dart';

enum FriendshipStatus {
  pending,
  accepted,
  blocked;

  static FriendshipStatus fromString(String s) => switch (s) {
        'pending' => FriendshipStatus.pending,
        'accepted' => FriendshipStatus.accepted,
        'blocked' => FriendshipStatus.blocked,
        _ => throw ArgumentError('Invalid friendship status: $s'),
      };
}

class FriendRequest {
  final String userId;

  FriendRequest({required this.userId});

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      FriendRequest(userId: json['userId'] as String);

  Map<String, dynamic> toJson() => {'userId': userId};
}

class FriendshipDto {
  final UserDto user;
  final FriendshipStatus status;
  final bool incomingRequest;
  final DateTime createdAt;

  FriendshipDto({
    required this.user,
    required this.status,
    required this.incomingRequest,
    required this.createdAt,
  });

  factory FriendshipDto.fromJson(Map<String, dynamic> json) => FriendshipDto(
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
        status: FriendshipStatus.fromString(json['status'] as String),
        incomingRequest: json['incomingRequest'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'status': status.name,
        'incomingRequest': incomingRequest,
        'createdAt': createdAt.toIso8601String(),
      };
}

class FriendsListResponse {
  final List<FriendshipDto> friends;
  final List<FriendshipDto> pendingIncoming;
  final List<FriendshipDto> pendingOutgoing;

  FriendsListResponse({
    required this.friends,
    required this.pendingIncoming,
    required this.pendingOutgoing,
  });

  factory FriendsListResponse.fromJson(Map<String, dynamic> json) =>
      FriendsListResponse(
        friends: (json['friends'] as List)
            .map((f) => FriendshipDto.fromJson(f as Map<String, dynamic>))
            .toList(),
        pendingIncoming: (json['pendingIncoming'] as List)
            .map((f) => FriendshipDto.fromJson(f as Map<String, dynamic>))
            .toList(),
        pendingOutgoing: (json['pendingOutgoing'] as List)
            .map((f) => FriendshipDto.fromJson(f as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'friends': friends.map((f) => f.toJson()).toList(),
        'pendingIncoming': pendingIncoming.map((f) => f.toJson()).toList(),
        'pendingOutgoing': pendingOutgoing.map((f) => f.toJson()).toList(),
      };
}
