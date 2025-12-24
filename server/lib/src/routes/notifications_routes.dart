import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';

class NotificationsRoutes {
  final AppDatabase db;

  NotificationsRoutes({required this.db});

  Router get router {
    final router = Router();

    router.get('/', _listNotifications);
    router.get('/count', _getUnreadCount);
    router.post('/<notificationId>/read', _markAsRead);
    router.delete('/<notificationId>', _deleteNotification);
    router.delete('/', _clearAll);

    return router;
  }

  Future<Response> _listNotifications(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    final notifications = await (db.select(db.notifications)
      ..where((n) => n.userId.equals(userId))
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();

    final result = <Map<String, dynamic>>[];
    for (final notification in notifications) {
      // Get the sender info if available
      Map<String, dynamic>? fromUser;
      if (notification.fromUserId != null) {
        final user = await (db.select(db.users)
          ..where((u) => u.id.equals(notification.fromUserId!)))
            .getSingleOrNull();
        if (user != null) {
          fromUser = {
            'id': user.id,
            'username': user.username,
            'displayName': user.displayName,
            'avatarUrl': user.avatarUrl,
          };
        }
      }

      // Get game info if available
      Map<String, dynamic>? game;
      if (notification.gameId != null) {
        final gameData = await (db.select(db.games)
          ..where((g) => g.id.equals(notification.gameId!)))
            .getSingleOrNull();
        if (gameData != null) {
          game = {
            'id': gameData.id,
            'status': gameData.status,
          };
        }
      }

      result.add({
        'id': notification.id,
        'type': notification.type,
        'status': notification.status,
        'fromUser': fromUser,
        'game': game,
        'createdAt': notification.createdAt.toIso8601String(),
        'readAt': notification.readAt?.toIso8601String(),
      });
    }

    return Response(200,
        body: jsonEncode({'notifications': result}),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _getUnreadCount(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    final unreadNotifications = await (db.select(db.notifications)
      ..where((n) => n.userId.equals(userId) & n.status.equals('pending')))
        .get();

    return Response(200,
        body: jsonEncode({'count': unreadNotifications.length}),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _markAsRead(Request request, String notificationId) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    // Verify notification belongs to user
    final notification = await (db.select(db.notifications)
      ..where((n) => n.id.equals(notificationId) & n.userId.equals(userId)))
        .getSingleOrNull();

    if (notification == null) {
      return _error(404, 'not_found', 'Notification not found');
    }

    await (db.update(db.notifications)
      ..where((n) => n.id.equals(notificationId)))
        .write(NotificationsCompanion(
          status: const Value('read'),
          readAt: Value(DateTime.now().toUtc()),
        ));

    return Response(200,
        body: jsonEncode({'status': 'read'}),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _deleteNotification(Request request, String notificationId) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    // Verify notification belongs to user
    final notification = await (db.select(db.notifications)
      ..where((n) => n.id.equals(notificationId) & n.userId.equals(userId)))
        .getSingleOrNull();

    if (notification == null) {
      return _error(404, 'not_found', 'Notification not found');
    }

    await (db.delete(db.notifications)
      ..where((n) => n.id.equals(notificationId)))
        .go();

    return Response(200,
        body: jsonEncode({'status': 'deleted'}),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _clearAll(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) return _unauthorized();

    final deleted = await (db.delete(db.notifications)
      ..where((n) => n.userId.equals(userId)))
        .go();

    return Response(200,
        body: jsonEncode({'status': 'cleared', 'count': deleted}),
        headers: {'content-type': 'application/json'});
  }

  Response _unauthorized() {
    return Response(401,
        body: jsonEncode({'error': 'unauthorized'}),
        headers: {'content-type': 'application/json'});
  }

  Response _error(int status, String code, String message) {
    return Response(status,
        body: jsonEncode({'error': code, 'message': message}),
        headers: {'content-type': 'application/json'});
  }
}
