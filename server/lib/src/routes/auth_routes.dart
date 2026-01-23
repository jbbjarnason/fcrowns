import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

import '../services/auth_service.dart';
import '../services/email_service.dart';

class AuthRoutes {
  final AuthService authService;
  final EmailService emailService;
  final bool skipEmailVerification;

  AuthRoutes({
    required this.authService,
    required this.emailService,
    this.skipEmailVerification = false,
  });

  Router get router {
    final router = Router();

    router.get('/health', _health);
    router.post('/signup', _signup);
    router.post('/verify', _verify);
    router.get('/verify', _verifyGet);  // Handle email link clicks
    router.post('/login', _login);
    router.post('/refresh', _refresh);
    router.post('/password-reset/request', _passwordResetRequest);
    router.post('/password-reset/confirm', _passwordResetConfirm);
    router.get('/reset-password', _resetPasswordPage);

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

      // Create user (auto-verify if skip flag is set)
      final userId = await authService.createUser(
        email: req.email,
        password: req.password,
        username: req.username,
        displayName: sanitizedDisplayName,
        avatarUrl: req.avatarUrl,
        autoVerify: skipEmailVerification,
      );

      // Skip email if verification is disabled (for local dev)
      if (!skipEmailVerification) {
        try {
          final token = await authService.createVerificationToken(userId);
          await emailService.sendVerificationEmail(
            toEmail: req.email,
            username: req.username,
            token: token,
          );
        } catch (e) {
          // Log but don't fail signup - user can request resend later
          print('WARNING: Failed to send verification email: $e');
        }
      }

      final message = skipEmailVerification ? 'account_created' : 'verification_sent';
      return Response(201,
          body: jsonEncode(SignupResponse(message: message).toJson()),
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

  /// Handle GET requests from email verification links
  Future<Response> _verifyGet(Request request) async {
    final token = request.url.queryParameters['token'];
    if (token == null || token.isEmpty) {
      return Response(400,
          body: _htmlPage('Error', 'Missing verification token.', false),
          headers: {'content-type': 'text/html'});
    }

    final success = await authService.verifyEmail(token);
    if (!success) {
      return Response(400,
          body: _htmlPage('Verification Failed', 'Invalid or expired verification link.', false),
          headers: {'content-type': 'text/html'});
    }

    return Response(200,
        body: _htmlPage('Email Verified!', 'Your email has been verified. You can now log in to the app.', true),
        headers: {'content-type': 'text/html'});
  }

  String _htmlPage(String title, String message, bool success) {
    final color = success ? '#4CAF50' : '#f44336';
    final icon = success ? '&#10004;' : '&#10008;';
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title - Five Crowns</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
           display: flex; justify-content: center; align-items: center;
           min-height: 100vh; margin: 0; background: #f5f5f5; }
    .card { background: white; padding: 40px; border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1); text-align: center; max-width: 400px; }
    .icon { font-size: 64px; color: $color; }
    h1 { color: #333; margin: 20px 0 10px; }
    p { color: #666; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">$icon</div>
    <h1>$title</h1>
    <p>$message</p>
  </div>
</body>
</html>
''';
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

  Response _resetPasswordPage(Request request) {
    final token = request.url.queryParameters['token'] ?? '';

    if (token.isEmpty) {
      return Response(400,
          body: _htmlPage('Invalid Link', '<p>This password reset link is invalid or has expired.</p>'),
          headers: {'content-type': 'text/html'});
    }

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password - Five Suits Rummy</title>
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0;
      padding: 20px;
    }
    .container {
      background: #fff;
      padding: 40px;
      border-radius: 16px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.3);
      max-width: 400px;
      width: 100%;
    }
    h1 {
      color: #1a1a2e;
      margin: 0 0 8px 0;
      font-size: 24px;
    }
    .subtitle {
      color: #666;
      margin-bottom: 24px;
    }
    label {
      display: block;
      margin-bottom: 6px;
      font-weight: 500;
      color: #333;
    }
    input {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      font-size: 16px;
      margin-bottom: 16px;
      transition: border-color 0.2s;
    }
    input:focus {
      outline: none;
      border-color: #6366f1;
    }
    button {
      width: 100%;
      padding: 14px;
      background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    button:hover {
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(99,102,241,0.4);
    }
    button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none;
    }
    .message {
      padding: 12px 16px;
      border-radius: 8px;
      margin-bottom: 16px;
      display: none;
    }
    .error { background: #fee2e2; color: #dc2626; }
    .success { background: #d1fae5; color: #059669; }
    .show { display: block; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Reset Password</h1>
    <p class="subtitle">Enter your new password below.</p>

    <div id="message" class="message"></div>

    <form id="resetForm">
      <label for="password">New Password</label>
      <input type="password" id="password" name="password" required minlength="8" placeholder="At least 8 characters">

      <label for="confirmPassword">Confirm Password</label>
      <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Re-enter password">

      <button type="submit" id="submitBtn">Reset Password</button>
    </form>
  </div>

  <script>
    const form = document.getElementById('resetForm');
    const message = document.getElementById('message');
    const submitBtn = document.getElementById('submitBtn');
    const token = '$token';

    form.addEventListener('submit', async (e) => {
      e.preventDefault();

      const password = document.getElementById('password').value;
      const confirmPassword = document.getElementById('confirmPassword').value;

      if (password !== confirmPassword) {
        showMessage('Passwords do not match', 'error');
        return;
      }

      if (password.length < 8) {
        showMessage('Password must be at least 8 characters', 'error');
        return;
      }

      submitBtn.disabled = true;
      submitBtn.textContent = 'Resetting...';

      try {
        const response = await fetch('/auth/password-reset/confirm', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ token: token, newPassword: password })
        });

        const data = await response.json();

        if (response.ok) {
          showMessage('Password reset successfully! You can now log in with your new password.', 'success');
          form.style.display = 'none';
        } else {
          showMessage(data.message || 'Failed to reset password. The link may have expired.', 'error');
          submitBtn.disabled = false;
          submitBtn.textContent = 'Reset Password';
        }
      } catch (err) {
        showMessage('An error occurred. Please try again.', 'error');
        submitBtn.disabled = false;
        submitBtn.textContent = 'Reset Password';
      }
    });

    function showMessage(text, type) {
      message.textContent = text;
      message.className = 'message show ' + type;
    }
  </script>
</body>
</html>
''';

    return Response.ok(html, headers: {'content-type': 'text/html'});
  }

  String _htmlPage(String title, String content) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>\$title - Five Suits Rummy</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0;
      color: #333;
    }
    .container {
      background: #fff;
      padding: 40px;
      border-radius: 16px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.3);
      max-width: 400px;
      text-align: center;
    }
    h1 { color: #1a1a2e; margin-bottom: 16px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>\$title</h1>
    \$content
  </div>
</body>
</html>
''';
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
