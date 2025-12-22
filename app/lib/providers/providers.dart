import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'auth_provider.dart';
import 'friends_provider.dart';
import 'games_provider.dart';
import 'game_provider.dart';
import 'livekit_provider.dart';

// Re-export provider classes for type usage
export 'auth_provider.dart' show AuthProvider;
export 'friends_provider.dart' show FriendsProvider;
export 'games_provider.dart' show GamesProvider;
export 'game_provider.dart' show GameProvider;
export 'livekit_provider.dart' show LiveKitProvider;

// Configure these for your deployment
const String apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
const String wsBaseUrl = String.fromEnvironment('WS_URL', defaultValue: 'ws://localhost:8080/ws');

// Core services
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: apiBaseUrl);
});

final wsServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(wsUrl: wsBaseUrl);
});

// State providers
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthProvider(api: api);
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
