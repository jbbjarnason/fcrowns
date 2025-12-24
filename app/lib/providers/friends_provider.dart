import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class FriendsProvider extends ChangeNotifier {
  final ApiService api;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> get friends => _friends;

  List<Map<String, dynamic>> _pendingIncoming = [];
  List<Map<String, dynamic>> get pendingIncoming => _pendingIncoming;

  List<Map<String, dynamic>> _pendingOutgoing = [];
  List<Map<String, dynamic>> get pendingOutgoing => _pendingOutgoing;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FriendsProvider({required this.api});

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    final result = await api.getFriends();
    if (result != null) {
      // Extract user data from nested structure (FriendshipDto has 'user' object)
      _friends = _extractUsers(result['friends']);
      _pendingIncoming = _extractUsers(result['pendingIncoming']);
      _pendingOutgoing = _extractUsers(result['pendingOutgoing']);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Extracts user info from FriendshipDto list to flat list of user maps
  List<Map<String, dynamic>> _extractUsers(dynamic list) {
    if (list == null) return [];
    return List<Map<String, dynamic>>.from(
      (list as List).map((item) {
        // API returns { user: { id, username, displayName, avatarUrl }, status, ... }
        final user = item['user'] as Map<String, dynamic>?;
        if (user != null) {
          return Map<String, dynamic>.from(user);
        }
        // Fallback: item might already be flat user object
        return Map<String, dynamic>.from(item as Map);
      }),
    );
  }

  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchResults = await api.searchUsers(query);
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> sendFriendRequest(String userId) async {
    final success = await api.sendFriendRequest(userId);
    if (success) {
      await loadFriends();
    }
    return success;
  }

  Future<bool> acceptFriendRequest(String userId) async {
    final success = await api.acceptFriendRequest(userId);
    if (success) {
      await loadFriends();
    }
    return success;
  }

  Future<bool> declineFriendRequest(String userId) async {
    final success = await api.declineFriendRequest(userId);
    if (success) {
      await loadFriends();
    }
    return success;
  }

  Future<bool> blockUser(String userId) async {
    final success = await api.blockUser(userId);
    if (success) {
      await loadFriends();
    }
    return success;
  }

  Future<bool> removeFriend(String userId) async {
    final success = await api.removeFriend(userId);
    if (success) {
      await loadFriends();
    }
    return success;
  }
}
