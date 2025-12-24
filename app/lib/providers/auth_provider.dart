import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  final WebSocketService ws;

  AuthState _state = AuthState.unknown;
  AuthState get state => _state;

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  String? _userId;
  String? get userId => _userId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AuthProvider({required this.api, required this.ws}) {
    _checkAuth();
  }

  Future<void> _checkAuth({int retryCount = 0}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await api.accessToken;
      if (token != null) {
        final user = await api.getMe();
        if (user != null) {
          _currentUser = user;
          _userId = user['id'] as String;
          _state = AuthState.authenticated;
          _error = null;
          // Connect to WebSocket for real-time notifications
          _connectWebSocket(token);
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      debugPrint('[Auth] Error checking auth: $e');
      // Retry on network errors
      if (retryCount < 3) {
        await Future.delayed(Duration(seconds: retryCount + 1));
        _isLoading = false;
        notifyListeners();
        return _checkAuth(retryCount: retryCount + 1);
      }
      // After retries, set as unauthenticated but keep error
      _state = AuthState.unauthenticated;
      _error = 'Network error. Please check your connection.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Retry authentication check (useful after network recovery)
  Future<void> retryAuth() async {
    _error = null;
    await _checkAuth();
  }

  Future<void> _connectWebSocket(String token) async {
    try {
      await ws.connect(token);
    } catch (e) {
      // WebSocket connection failed, but don't block the app
      // It will auto-reconnect
      debugPrint('[Auth] WebSocket connection failed: $e');
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await api.signup(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );

    _isLoading = false;
    notifyListeners();

    return result != null;
  }

  Future<bool> verify(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await api.verify(token);

    _isLoading = false;
    notifyListeners();

    return result != null;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await api.login(email, password);

      if (success) {
        final user = await api.getMe();
        if (user != null) {
          _currentUser = user;
          _userId = user['id'] as String;
          _state = AuthState.authenticated;
          // Connect to WebSocket for real-time notifications
          final token = await api.accessToken;
          if (token != null) {
            _connectWebSocket(token);
          }
        }
      } else {
        _error = 'Invalid email or password';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[Auth] Login error: $e');
      _error = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ws.disconnect();
    await api.logout();
    _currentUser = null;
    _userId = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await api.requestPasswordReset(email);

    _isLoading = false;
    notifyListeners();

    return result != null;
  }

  Future<bool> confirmPasswordReset(String token, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await api.confirmPasswordReset(token, newPassword);

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<void> refreshUser() async {
    final user = await api.getMe();
    if (user != null) {
      _currentUser = user;
      _userId = user['id'] as String;
      notifyListeners();
    }
  }
}
