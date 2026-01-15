import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> main() async {
  final smtpHost = Platform.environment['SMTP_HOST'] ?? 'smtp-relay.centroid.is';
  final smtpPort = int.parse(Platform.environment['SMTP_PORT'] ?? '465');
  final smtpUsername = Platform.environment['SMTP_USERNAME'];
  final smtpPassword = Platform.environment['SMTP_PASSWORD'];
  final fromAddress = Platform.environment['SMTP_FROM'] ?? 'noreply@fcrowns.centroid.is';
  final secure = Platform.environment['SMTP_SECURE']?.toLowerCase() == 'true';

  print('SMTP Configuration:');
  print('  Host: $smtpHost');
  print('  Port: $smtpPort');
  print('  Username: ${smtpUsername ?? "(none)"}');
  print('  Password: ${smtpPassword != null ? "(set)" : "(none)"}');
  print('  From: $fromAddress');
  print('  Secure (SSL): $secure');
  print('');

  final smtp = SmtpServer(
    smtpHost,
    port: smtpPort,
    username: smtpUsername,
    password: smtpPassword,
    ssl: secure,
    ignoreBadCertificate: false,
    allowInsecure: false,
  );

  final message = Message()
    ..from = Address(fromAddress, 'Five Crowns')
    ..recipients.add('jon@centroid.is')
    ..subject = 'Test Email from Five Crowns'
    ..html = '''
<!DOCTYPE html>
<html>
<body>
  <h1>Test Email</h1>
  <p>This is a test email sent at ${DateTime.now().toUtc().toIso8601String()}</p>
  <p>If you received this, SMTP is working correctly!</p>
</body>
</html>
''';

  print('Sending test email to jon@centroid.is...');

  try {
    final result = await send(message, smtp);
    print('SUCCESS! Email sent.');
    print('  Subject: ${result.mail.subject}');
  } catch (e, st) {
    print('FAILED to send email:');
    print('  Error: $e');
    print('  Stack trace: $st');
    exit(1);
  }
}
