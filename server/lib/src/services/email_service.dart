import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final SmtpServer _smtp;
  final String _fromAddress;
  final String _baseUrl;

  EmailService({
    required String smtpHost,
    required int smtpPort,
    required String fromAddress,
    required String baseUrl,
    String? smtpUsername,
    String? smtpPassword,
  })  : _smtp = SmtpServer(
          smtpHost,
          port: smtpPort,
          username: smtpUsername,
          password: smtpPassword,
          ignoreBadCertificate: true,
          allowInsecure: true,
        ),
        _fromAddress = fromAddress,
        _baseUrl = baseUrl;

  /// Sends a verification email.
  Future<void> sendVerificationEmail({
    required String toEmail,
    required String username,
    required String token,
  }) async {
    final verifyUrl = '$_baseUrl/auth/verify?token=$token';

    final message = Message()
      ..from = Address(_fromAddress, 'Five Crowns')
      ..recipients.add(toEmail)
      ..subject = 'Verify your Five Crowns account'
      ..html = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .button { display: inline-block; padding: 12px 24px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px; }
    .footer { margin-top: 30px; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Welcome to Five Crowns!</h1>
    <p>Hi $username,</p>
    <p>Thanks for signing up! Please verify your email address by clicking the button below:</p>
    <p><a href="$verifyUrl" class="button">Verify Email</a></p>
    <p>Or copy and paste this link into your browser:</p>
    <p><a href="$verifyUrl">$verifyUrl</a></p>
    <p>This link will expire in 24 hours.</p>
    <div class="footer">
      <p>If you didn't create an account, you can safely ignore this email.</p>
    </div>
  </div>
</body>
</html>
''';

    await send(message, _smtp);
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail({
    required String toEmail,
    required String username,
    required String token,
  }) async {
    final resetUrl = '$_baseUrl/auth/reset-password?token=$token';

    final message = Message()
      ..from = Address(_fromAddress, 'Five Crowns')
      ..recipients.add(toEmail)
      ..subject = 'Reset your Five Crowns password'
      ..html = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .button { display: inline-block; padding: 12px 24px; background-color: #2196F3; color: white; text-decoration: none; border-radius: 4px; }
    .footer { margin-top: 30px; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Password Reset Request</h1>
    <p>Hi $username,</p>
    <p>We received a request to reset your password. Click the button below to choose a new password:</p>
    <p><a href="$resetUrl" class="button">Reset Password</a></p>
    <p>Or copy and paste this link into your browser:</p>
    <p><a href="$resetUrl">$resetUrl</a></p>
    <p>This link will expire in 1 hour.</p>
    <div class="footer">
      <p>If you didn't request a password reset, you can safely ignore this email.</p>
    </div>
  </div>
</body>
</html>
''';

    await send(message, _smtp);
  }
}
