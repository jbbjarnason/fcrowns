import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:logging/logging.dart';
import 'package:dotenv/dotenv.dart';

import 'package:fivecrowns_server/src/db/database.dart';
import 'package:fivecrowns_server/src/services/auth_service.dart';
import 'package:fivecrowns_server/src/services/email_service.dart';
import 'package:fivecrowns_server/src/routes/auth_routes.dart';
import 'package:fivecrowns_server/src/routes/user_routes.dart';
import 'package:fivecrowns_server/src/routes/friends_routes.dart';
import 'package:fivecrowns_server/src/routes/games_routes.dart';
import 'package:fivecrowns_server/src/routes/notifications_routes.dart';
import 'package:fivecrowns_server/src/middleware/auth_middleware.dart';
import 'package:fivecrowns_server/src/middleware/rate_limit_middleware.dart';
import 'package:fivecrowns_server/src/ws/ws_hub.dart';

void main() async {
  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final log = Logger('Server');

  // Load environment (if .env file exists)
  final env = DotEnv();
  try {
    env.load();
  } catch (_) {
    // .env file doesn't exist, which is fine in CI
    log.info('No .env file found, using system environment variables');
  }

  // Configuration (system env takes precedence over .env file)
  String getEnv(String key, [String? defaultValue]) =>
      Platform.environment[key] ?? env[key] ?? defaultValue ?? '';

  final databaseUrl = getEnv('DATABASE_URL');
  final jwtSecret = getEnv('JWT_SECRET', 'change-me-in-production');
  final jwtAccessTtlDays = int.tryParse(getEnv('JWT_ACCESS_TTL_DAYS', '7')) ?? 7;
  final smtpHost = getEnv('SMTP_HOST', 'localhost');
  final smtpPort = int.tryParse(getEnv('SMTP_PORT', '1025')) ?? 1025;
  final smtpFrom = getEnv('SMTP_FROM', 'no-reply@example.com');
  final smtpUsername = getEnv('SMTP_USERNAME');
  final smtpPassword = getEnv('SMTP_PASSWORD');
  final smtpSecure = getEnv('SMTP_SECURE', 'false') == 'true';
  final skipEmailVerification = getEnv('SKIP_EMAIL_VERIFICATION', 'false') == 'true';
  final baseUrl = getEnv('BASE_URL', 'http://localhost:8080');
  final livekitUrl = getEnv('LIVEKIT_URL', 'wss://localhost:7880');
  final livekitApiKey = getEnv('LIVEKIT_API_KEY', 'devkey');
  final livekitApiSecret = getEnv('LIVEKIT_API_SECRET', 'devsecret');
  final port = int.tryParse(getEnv('PORT', '8080')) ?? 8080;
  final allowedOrigins = getEnv('ALLOWED_ORIGINS', '*'); // Comma-separated list or '*' for dev
  final trustProxy = getEnv('TRUST_PROXY', 'false') == 'true';
  final isProduction = getEnv('ENVIRONMENT', 'development') == 'production';

  if (databaseUrl.isEmpty) {
    log.severe('DATABASE_URL not set');
    exit(1);
  }

  // Security checks for production
  if (isProduction) {
    if (jwtSecret == 'change-me-in-production' || jwtSecret.length < 32) {
      log.severe('JWT_SECRET must be set to a secure value (32+ chars) in production');
      exit(1);
    }
    if (allowedOrigins == '*') {
      log.severe('ALLOWED_ORIGINS cannot be "*" in production - set to specific domain(s)');
      exit(1);
    }
    if (RateLimiter.isDisabled) {
      log.severe('DISABLE_RATE_LIMIT cannot be true in production');
      exit(1);
    }
    if (skipEmailVerification) {
      log.severe('SKIP_EMAIL_VERIFICATION cannot be true in production');
      exit(1);
    }
  }

  log.info('Connecting to database...');
  final db = await AppDatabase.connectFromUrl(databaseUrl);
  log.info('Database connected');

  // Note: Migrations are handled automatically by Drift on first connection

  // Create services
  final authService = AuthService(
    db: db,
    jwtSecret: jwtSecret,
    accessTokenTtlDays: jwtAccessTtlDays,
  );

  final emailService = EmailService(
    smtpHost: smtpHost,
    smtpPort: smtpPort,
    fromAddress: smtpFrom,
    baseUrl: baseUrl,
    smtpUsername: smtpUsername.isNotEmpty ? smtpUsername : null,
    smtpPassword: smtpPassword.isNotEmpty ? smtpPassword : null,
    secure: smtpSecure,
  );

  // Create WebSocket hub
  final wsHub = WsHub(db: db, authService: authService);

  // Log if email verification is skipped
  if (skipEmailVerification) {
    log.warning('SKIP_EMAIL_VERIFICATION is enabled - users will be auto-verified');
  }

  // Create routers
  final authRoutes = AuthRoutes(
    authService: authService,
    emailService: emailService,
    skipEmailVerification: skipEmailVerification,
  );
  final userRoutes = UserRoutes(db: db);
  final friendsRoutes = FriendsRoutes(db: db, wsHub: wsHub);
  final gamesRoutes = GamesRoutes(
    db: db,
    wsHub: wsHub,
    livekitUrl: livekitUrl,
    livekitApiKey: livekitApiKey,
    livekitApiSecret: livekitApiSecret,
  );
  final notificationsRoutes = NotificationsRoutes(db: db);

  // Rate limiters
  final rateLimiter = RateLimiter(maxRequests: 100, window: const Duration(minutes: 1), trustProxy: trustProxy);
  final authRateLimiter = RateLimiter(maxRequests: 10, window: const Duration(minutes: 5), trustProxy: trustProxy);

  // Build main router
  final app = Router();

  // Public routes with stricter rate limiting for auth
  app.mount('/auth', Pipeline()
      .addMiddleware(authRateLimiter.middleware())
      .addHandler(authRoutes.router.call));

  // Protected routes
  final protectedRouter = Router();
  protectedRouter.mount('/users', userRoutes.router.call);
  protectedRouter.mount('/friends', friendsRoutes.router.call);
  protectedRouter.mount('/games', gamesRoutes.router.call);
  protectedRouter.mount('/notifications', notificationsRoutes.router.call);

  app.mount('/', Pipeline()
      .addMiddleware(authMiddleware(authService))
      .addHandler(protectedRouter.call));

  // WebSocket endpoint
  final wsHandler = webSocketHandler((channel, _) {
    wsHub.handleConnection(channel);
  });

  // Combine HTTP and WebSocket
  Handler handler = (Request request) {
    if (request.url.path == 'ws') {
      return wsHandler(request);
    }
    return app.call(request);
  };

  // Add CORS, rate limiting, and logging middleware
  handler = Pipeline()
      .addMiddleware(_corsMiddleware(allowedOrigins))
      .addMiddleware(rateLimiter.middleware())
      .addMiddleware(logRequests())
      .addHandler(handler);

  // Start server
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  log.info('Server running on http://${server.address.host}:${server.port}');
  if (isProduction) {
    log.info('Running in PRODUCTION mode');
  }
}

Middleware _corsMiddleware(String allowedOrigins) {
  final origins = allowedOrigins == '*' ? null : allowedOrigins.split(',').map((o) => o.trim()).toSet();

  return (Handler innerHandler) {
    return (Request request) async {
      final requestOrigin = request.headers['origin'];
      String allowOrigin;

      if (origins == null) {
        // Allow all origins (dev mode)
        allowOrigin = '*';
      } else if (requestOrigin != null && origins.contains(requestOrigin)) {
        // Origin is in allowed list
        allowOrigin = requestOrigin;
      } else {
        // Origin not allowed - still process request but don't set CORS header
        // Browser will block the response
        allowOrigin = origins.first; // Default to first allowed origin
      }

      final corsHeaders = {
        'Access-Control-Allow-Origin': allowOrigin,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        'Access-Control-Allow-Credentials': 'true',
      };

      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: {...response.headers, ...corsHeaders});
    };
  };
}
