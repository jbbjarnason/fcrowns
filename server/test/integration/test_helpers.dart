import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:fivecrowns_server/fivecrowns_server.dart';

/// Creates an in-memory SQLite database for testing.
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

/// Test harness that sets up all services for integration testing.
class TestHarness {
  late final AppDatabase db;
  late final AuthService authService;
  late final MockEmailService emailService;
  late final WsHub wsHub;
  late final Handler httpHandler;

  Future<void> setUp() async {
    db = createTestDatabase();

    authService = AuthService(
      db: db,
      jwtSecret: 'test-secret-key-for-testing',
      accessTokenTtlDays: 7,
    );

    emailService = MockEmailService();

    wsHub = WsHub(db: db, authService: authService);

    // Build HTTP handler
    final authRoutes = AuthRoutes(
      authService: authService,
      emailService: emailService,
    );
    final userRoutes = UserRoutes(db: db);
    final friendsRoutes = FriendsRoutes(db: db);
    final gamesRoutes = GamesRoutes(
      db: db,
      livekitUrl: 'wss://test.livekit.local',
      livekitApiKey: 'test-key',
      livekitApiSecret: 'test-secret',
    );

    final app = Router();
    app.mount('/auth', authRoutes.router.call);

    final protectedRouter = Router();
    protectedRouter.mount('/users', userRoutes.router.call);
    protectedRouter.mount('/friends', friendsRoutes.router.call);
    protectedRouter.mount('/games', gamesRoutes.router.call);

    app.mount('/', Pipeline()
        .addMiddleware(authMiddleware(authService))
        .addHandler(protectedRouter.call));

    httpHandler = app.call;
  }

  Future<void> tearDown() async {
    await db.close();
  }

  /// Makes an HTTP request to the test server.
  Future<Response> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    final uri = Uri.parse('http://localhost$path');
    final headers = <String, String>{
      'content-type': 'application/json',
    };
    if (authToken != null) {
      headers['authorization'] = 'Bearer $authToken';
    }

    final request = Request(
      method,
      uri,
      body: body != null ? jsonEncode(body) : null,
      headers: headers,
    );

    return await httpHandler(request);
  }

  /// Helper to parse JSON response.
  Future<Map<String, dynamic>> parseJson(Response response) async {
    final body = await response.readAsString();
    return jsonDecode(body) as Map<String, dynamic>;
  }
}

/// Mock email service that captures sent emails.
class MockEmailService extends EmailService {
  final List<SentEmail> sentEmails = [];

  MockEmailService()
      : super(
          smtpHost: 'localhost',
          smtpPort: 1025,
          fromAddress: 'test@test.com',
          baseUrl: 'http://localhost:8080',
        );

  @override
  Future<void> sendVerificationEmail({
    required String toEmail,
    required String username,
    required String token,
  }) async {
    sentEmails.add(SentEmail(
      type: 'verification',
      toEmail: toEmail,
      token: token,
    ));
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String toEmail,
    required String username,
    required String token,
  }) async {
    sentEmails.add(SentEmail(
      type: 'password_reset',
      toEmail: toEmail,
      token: token,
    ));
  }

  String? getLastVerificationToken() {
    final email = sentEmails.lastWhere(
      (e) => e.type == 'verification',
      orElse: () => SentEmail(type: '', toEmail: '', token: ''),
    );
    return email.token.isNotEmpty ? email.token : null;
  }

  String? getLastPasswordResetToken() {
    final email = sentEmails.lastWhere(
      (e) => e.type == 'password_reset',
      orElse: () => SentEmail(type: '', toEmail: '', token: ''),
    );
    return email.token.isNotEmpty ? email.token : null;
  }
}

class SentEmail {
  final String type;
  final String toEmail;
  final String token;

  SentEmail({
    required this.type,
    required this.toEmail,
    required this.token,
  });
}

/// Creates a test user and returns (userId, accessToken).
Future<(String, String)> createVerifiedUser(
  TestHarness harness, {
  required String email,
  required String username,
  String password = 'password123',
}) async {
  // Signup
  await harness.request('POST', '/auth/signup', body: {
    'email': email,
    'password': password,
    'username': username,
    'displayName': username.toUpperCase(),
  });

  // Verify email
  final token = harness.emailService.getLastVerificationToken()!;
  await harness.request('POST', '/auth/verify', body: {'token': token});

  // Login
  final loginResponse = await harness.request('POST', '/auth/login', body: {
    'email': email,
    'password': password,
  });

  final loginJson = await harness.parseJson(loginResponse);
  return (loginJson['accessJwt'] as String, loginJson['refreshToken'] as String);
}
