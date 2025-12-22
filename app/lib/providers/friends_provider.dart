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
      _friends = List<Map<String, dynamic>>.from(result['friends'] ?? []);
      _pendingIncoming = List<Map<String, dynamic>>.from(result['pendingIncoming'] ?? []);
      _pendingOutgoing = List<Map<String, dynamic>>.from(result['pendingOutgoing'] ?? []);
    }

    _isLoading = false;
    notifyListeners();
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
