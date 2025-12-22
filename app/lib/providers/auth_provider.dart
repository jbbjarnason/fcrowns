import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService api;

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

  AuthProvider({required this.api}) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final token = await api.accessToken;
    if (token != null) {
      final user = await api.getMe();
      if (user != null) {
        _currentUser = user;
        _userId = user['id'] as String;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }

    _isLoading = false;
    notifyListeners();
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

    final success = await api.login(email, password);

    if (success) {
      final user = await api.getMe();
      if (user != null) {
        _currentUser = user;
        _userId = user['id'] as String;
        _state = AuthState.authenticated;
      }
    } else {
      _error = 'Invalid email or password';
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<void> logout() async {
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
