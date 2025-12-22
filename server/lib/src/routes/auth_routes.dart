import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

import '../services/auth_service.dart';
import '../services/email_service.dart';

class AuthRoutes {
  final AuthService authService;
  final EmailService emailService;

  AuthRoutes({
    required this.authService,
    required this.emailService,
  });

  Router get router {
    final router = Router();

    router.get('/health', _health);
    router.post('/signup', _signup);
    router.post('/verify', _verify);
    router.post('/login', _login);
    router.post('/refresh', _refresh);
    router.post('/password-reset/request', _passwordResetRequest);
    router.post('/password-reset/confirm', _passwordResetConfirm);

    return router;
  }

  Response _health(Request request) {
    return Response.ok(
      jsonEncode({'status': 'ok'}),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _signup(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = SignupRequest.fromJson(json);

      // Validate input - reject null bytes and control characters
      if (_containsControlChars(req.email) || _containsControlChars(req.username)) {
        return _errorResponse(400, 'invalid_input', 'Input contains invalid characters');
      }

      if (req.email.isEmpty || !req.email.contains('@') || req.email.length > 254) {
        return _errorResponse(400, 'invalid_email', 'Invalid email address');
      }
      if (req.password.length < 8 || req.password.length > 128) {
        return _errorResponse(400, 'weak_password', 'Password must be 8-128 characters');
      }
      if (req.password.trim().isEmpty) {
        return _errorResponse(400, 'weak_password', 'Password cannot be only whitespace');
      }
      if (req.username.length < 3 || req.username.length > 30) {
        return _errorResponse(400, 'invalid_username', 'Username must be 3-30 characters');
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(req.username)) {
        return _errorResponse(400, 'invalid_username', 'Username can only contain letters, numbers, and underscores');
      }
      if (req.displayName.length > 50) {
        return _errorResponse(400, 'invalid_display_name', 'Display name must be 50 characters or less');
      }

      // Sanitize HTML from displayName to prevent XSS
      final sanitizedDisplayName = _sanitizeHtml(req.displayName);

      // Create user
      final userId = await authService.createUser(
        email: req.email,
        password: req.password,
        username: req.username,
        displayName: sanitizedDisplayName,
        avatarUrl: req.avatarUrl,
      );

      // Create verification token and send email
      final token = await authService.createVerificationToken(userId);
      await emailService.sendVerificationEmail(
        toEmail: req.email,
        username: req.username,
        token: token,
      );

      return Response(201,
          body: jsonEncode(SignupResponse(message: 'verification_sent').toJson()),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _errorResponse(400, 'invalid_json', 'Invalid JSON');
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unique') || errorStr.contains('duplicate') || errorStr.contains('constraint')) {
        return _errorResponse(409, 'already_exists', 'Email or username already exists');
      }
      return _errorResponse(500, 'internal_error', 'Internal server error');
    }
  }

  Future<Response> _verify(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = VerifyRequest.fromJson(json);

      final success = await authService.verifyEmail(req.token);
      if (!success) {
        return _errorResponse(400, 'invalid_token', 'Invalid or expired token');
      }

      return Response(200,
          body: jsonEncode({'message': 'email_verified'}),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _errorResponse(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = LoginRequest.fromJson(json);

      final result = await authService.login(req.email, req.password);
      if (result == null) {
        return _errorResponse(401, 'invalid_credentials', 'Invalid email or password');
      }

      final (accessJwt, refreshToken) = result;
      return Response(200,
          body: jsonEncode(LoginResponse(
            accessJwt: accessJwt,
            refreshToken: refreshToken,
          ).toJson()),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _errorResponse(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Future<Response> _refresh(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = RefreshRequest.fromJson(json);

      final result = await authService.refreshTokens(req.refreshToken);
      if (result == null) {
        return _errorResponse(401, 'invalid_token', 'Invalid or expired refresh token');
      }

      final (accessJwt, refreshToken) = result;
      return Response(200,
          body: jsonEncode(LoginResponse(
            accessJwt: accessJwt,
            refreshToken: refreshToken,
          ).toJson()),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _errorResponse(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Future<Response> _passwordResetRequest(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = PasswordResetRequestDto.fromJson(json);

      // Always return 200 to prevent user enumeration
      final user = await authService.findUserByEmail(req.email);
      if (user != null) {
        final token = await authService.createPasswordResetToken(user.id);
        await emailService.sendPasswordResetEmail(
          toEmail: req.email,
          username: user.username,
          token: token,
        );
      }

      return Response(200,
          body: jsonEncode({'message': 'reset_email_sent'}),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _errorResponse(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Future<Response> _passwordResetConfirm(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = PasswordResetConfirmRequest.fromJson(json);

      if (req.newPassword.length < 8 || req.newPassword.length > 128) {
        return _errorResponse(400, 'weak_password', 'Password must be 8-128 characters');
      }
      if (req.newPassword.trim().isEmpty) {
        return _errorResponse(400, 'weak_password', 'Password cannot be only whitespace');
      }

      final success = await authService.confirmPasswordReset(req.token, req.newPassword);
      if (!success) {
        return _errorResponse(400, 'invalid_token', 'Invalid or expired token');
      }

      return Response(200,
          body: jsonEncode({'message': 'password_reset'}),
          headers: {'content-type': 'application/json'});
    } on FormatException {
      return _errorResponse(400, 'invalid_json', 'Invalid JSON');
    }
  }

  Response _errorResponse(int statusCode, String code, String message) {
    return Response(statusCode,
        body: jsonEncode({'error': code, 'message': message}),
        headers: {'content-type': 'application/json'});
  }

  /// Checks if a string contains null bytes or control characters (ASCII 0-31)
  bool _containsControlChars(String input) {
    for (var i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      if (code < 32 || code == 127) return true;
    }
    return false;
  }

  /// Sanitizes HTML to prevent XSS attacks and strips control characters
  String _sanitizeHtml(String input) {
    // First remove control characters
    final cleaned = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    // Then escape HTML entities
    return cleaned
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
