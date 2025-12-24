import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiService api;
  final WebSocketService ws;

  StreamSubscription<WsEvent>? _wsSubscription;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Callback for when a real-time notification is received
  void Function(String message)? onNotificationReceived;

  /// Callback for when a game is deleted
  void Function(String gameId, String deletedBy)? onGameDeleted;

  /// Callback for when friend list changes (friend added/removed/accepted)
  void Function()? onFriendListChanged;

  /// Callback for when games list should be refreshed
  void Function()? onGamesListChanged;

  /// Callback for when a nudge is received (triggers shake animation)
  void Function()? onNudgeReceived;

  NotificationsProvider({required this.api, required this.ws}) {
    _subscribeToWebSocket();
  }

  void _subscribeToWebSocket() {
    _wsSubscription?.cancel();
    _wsSubscription = ws.events.listen(_handleWsEvent, onError: (e) {
      debugPrint('WebSocket error in NotificationsProvider: $e');
    });
  }

  /// Re-subscribe to WebSocket events (call after reconnection)
  void resubscribe() {
    _subscribeToWebSocket();
  }

  void _handleWsEvent(WsEvent event) {
    if (event is EvtNotification) {
      _handleNotification(event);
    } else if (event is EvtGameDeleted) {
      _handleGameDeleted(event);
    }
  }

  void _handleNotification(EvtNotification event) {
    debugPrint('Received WebSocket notification: ${event.notificationType}');

    // Nudge is ephemeral - don't add to notification list, just trigger animation
    if (event.notificationType == NotificationType.gameNudge) {
      final message = event.message ??
          _getDefaultMessage(event.notificationType, event.fromDisplayName ?? event.fromUsername);
      onNotificationReceived?.call(message);
      onNudgeReceived?.call();
      return;
    }

    // Add to local notifications list
    final notification = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      'type': event.notificationType.toJsonString(),
      'status': 'pending',
      'fromUser': {
        'id': event.fromUserId,
        'username': event.fromUsername,
        'displayName': event.fromDisplayName,
      },
      'gameId': event.gameId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();

    // Trigger callback if set
    final message = event.message ??
        _getDefaultMessage(event.notificationType, event.fromDisplayName ?? event.fromUsername);
    onNotificationReceived?.call(message);

    // Trigger specific callbacks based on notification type
    switch (event.notificationType) {
      case NotificationType.friendRequest:
      case NotificationType.friendAccepted:
      case NotificationType.friendBlocked:
        onFriendListChanged?.call();
        break;
      case NotificationType.gameInvitation:
        onGamesListChanged?.call();
        break;
      case NotificationType.gameDeleted:
        onGamesListChanged?.call();
        break;
      case NotificationType.gameNudge:
        onNudgeReceived?.call();
        break;
    }

    // Reload notifications from server to get accurate data
    loadNotifications();
  }

  String _getDefaultMessage(NotificationType type, String? fromName) {
    switch (type) {
      case NotificationType.gameInvitation:
        return '${fromName ?? 'Someone'} invited you to a game';
      case NotificationType.friendRequest:
        return '${fromName ?? 'Someone'} sent you a friend request';
      case NotificationType.friendAccepted:
        return '${fromName ?? 'Someone'} accepted your friend request';
      case NotificationType.friendBlocked:
        return 'You have been blocked';
      case NotificationType.gameDeleted:
        return 'A game was deleted';
      case NotificationType.gameNudge:
        return '${fromName ?? 'Someone'} wants you to start the game!';
    }
  }

  void _handleGameDeleted(EvtGameDeleted event) {
    debugPrint('Received WebSocket game deleted: ${event.gameId}');

    // Remove any notifications for this game
    _notifications.removeWhere((n) => n['gameId'] == event.gameId);
    _unreadCount = _notifications.where((n) => n['status'] == 'pending').length;
    notifyListeners();

    // Trigger callbacks
    onGameDeleted?.call(event.gameId, event.deletedByUsername);
    onGamesListChanged?.call();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    _notifications = await api.getNotifications();
    _unreadCount = _notifications.where((n) => n['status'] == 'pending').length;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    _unreadCount = await api.getUnreadNotificationCount();
    notifyListeners();
  }

  Future<bool> markAsRead(String notificationId) async {
    final success = await api.markNotificationAsRead(notificationId);
    if (success) {
      // Update local state
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['status'] = 'read';
        _notifications[index]['readAt'] = DateTime.now().toIso8601String();
        _unreadCount = _notifications.where((n) => n['status'] == 'pending').length;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> deleteNotification(String notificationId) async {
    final success = await api.deleteNotification(notificationId);
    if (success) {
      _notifications.removeWhere((n) => n['id'] == notificationId);
      _unreadCount = _notifications.where((n) => n['status'] == 'pending').length;
      notifyListeners();
    }
    return success;
  }

  Future<bool> clearAll() async {
    final success = await api.clearAllNotifications();
    if (success) {
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    }
    return success;
  }

  /// Get game invitations (pending)
  List<Map<String, dynamic>> get gameInvitations =>
      _notifications.where((n) =>
        n['type'] == 'game_invitation' && n['status'] == 'pending'
      ).toList();
}
