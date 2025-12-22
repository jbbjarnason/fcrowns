/// Auth-related DTOs for REST endpoints.

class SignupRequest {
  final String email;
  final String password;
  final String username;
  final String displayName;
  final String? avatarUrl;

  SignupRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) => SignupRequest(
        email: json['email'] as String,
        password: json['password'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'username': username,
        'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}

class SignupResponse {
  final String message;

  SignupResponse({required this.message});

  factory SignupResponse.fromJson(Map<String, dynamic> json) =>
      SignupResponse(message: json['message'] as String);

  Map<String, dynamic> toJson() => {'message': message};
}

class VerifyRequest {
  final String token;

  VerifyRequest({required this.token});

  factory VerifyRequest.fromJson(Map<String, dynamic> json) =>
      VerifyRequest(token: json['token'] as String);

  Map<String, dynamic> toJson() => {'token': token};
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        password: json['password'] as String,
      );

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String accessJwt;
  final String refreshToken;

  LoginResponse({required this.accessJwt, required this.refreshToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessJwt: json['accessJwt'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  Map<String, dynamic> toJson() => {
        'accessJwt': accessJwt,
        'refreshToken': refreshToken,
      };
}

class RefreshRequest {
  final String refreshToken;

  RefreshRequest({required this.refreshToken});

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      RefreshRequest(refreshToken: json['refreshToken'] as String);

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class PasswordResetRequestDto {
  final String email;

  PasswordResetRequestDto({required this.email});

  factory PasswordResetRequestDto.fromJson(Map<String, dynamic> json) =>
      PasswordResetRequestDto(email: json['email'] as String);

  Map<String, dynamic> toJson() => {'email': email};
}

class PasswordResetConfirmRequest {
  final String token;
  final String newPassword;

  PasswordResetConfirmRequest({required this.token, required this.newPassword});

  factory PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) =>
      PasswordResetConfirmRequest(
        token: json['token'] as String,
        newPassword: json['newPassword'] as String,
      );

  Map<String, dynamic> toJson() => {'token': token, 'newPassword': newPassword};
}
