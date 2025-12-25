import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'auth_provider.dart';
import 'friends_provider.dart';
import 'games_provider.dart';
import 'game_provider.dart';
import 'livekit_provider.dart';
import 'notifications_provider.dart';

// Re-export provider classes for type usage
export 'auth_provider.dart' show AuthProvider;
export 'friends_provider.dart' show FriendsProvider;
export 'games_provider.dart' show GamesProvider;
export 'game_provider.dart' show GameProvider;
export 'livekit_provider.dart' show LiveKitProvider;
export 'notifications_provider.dart' show NotificationsProvider;

// Configure these via --dart-define at build time:
//   flutter run --dart-define=API_URL=https://api.example.com
//   flutter build --dart-define=API_URL=https://api.example.com
//
// Defaults to production server. Override for local development:
//   --dart-define=API_URL=http://localhost:8080 --dart-define=WS_URL=ws://localhost:8080/ws
const String apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://fcrowns.centroid.is');
const String wsBaseUrl = String.fromEnvironment('WS_URL', defaultValue: 'wss://fcrowns.centroid.is/ws');

// Validate URLs at startup - will fail fast if not configured
void _validateConfig() {
  if (apiBaseUrl.isEmpty) {
    throw StateError(
      'API_URL not configured. Build with: --dart-define=API_URL=https://your-api.com',
    );
  }
  if (wsBaseUrl.isEmpty) {
    throw StateError(
      'WS_URL not configured. Build with: --dart-define=WS_URL=wss://your-api.com/ws',
    );
  }
}

// Core services
final apiServiceProvider = Provider<ApiService>((ref) {
  _validateConfig();
  return ApiService(baseUrl: apiBaseUrl);
});

final wsServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(wsUrl: wsBaseUrl);
});

// State providers
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final api = ref.watch(apiServiceProvider);
  final ws = ref.watch(wsServiceProvider);
  return AuthProvider(api: api, ws: ws);
});

final friendsProvider = ChangeNotifierProvider<FriendsProvider>((ref) {
  final api = ref.watch(apiServiceProvider);
  return FriendsProvider(api: api);
});

final gamesProvider = ChangeNotifierProvider<GamesProvider>((ref) {
  final api = ref.watch(apiServiceProvider);
  return GamesProvider(api: api);
});

final gameProvider = ChangeNotifierProvider<GameProvider>((ref) {
  final ws = ref.watch(wsServiceProvider);
  final api = ref.watch(apiServiceProvider);
  return GameProvider(ws: ws, api: api);
});

final liveKitProvider = ChangeNotifierProvider<LiveKitProvider>((ref) {
  return LiveKitProvider();
});

final notificationsProvider = ChangeNotifierProvider<NotificationsProvider>((ref) {
  final api = ref.watch(apiServiceProvider);
  final ws = ref.watch(wsServiceProvider);
  return NotificationsProvider(api: api, ws: ws);
});
