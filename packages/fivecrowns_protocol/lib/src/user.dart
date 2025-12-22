/// User-related DTOs.

class UserDto {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  UserDto({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}

class MeResponse {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool emailVerified;
  final DateTime createdAt;

  MeResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.emailVerified,
    required this.createdAt,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) => MeResponse(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        emailVerified: json['emailVerified'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'emailVerified': emailVerified,
        'createdAt': createdAt.toIso8601String(),
      };
}
