import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/auth_service.dart';

/// Middleware that validates JWT and adds userId to request context.
Middleware authMiddleware(AuthService authService) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
            body: jsonEncode({'error': 'unauthorized', 'message': 'Missing or invalid authorization header'}),
            headers: {'content-type': 'application/json'});
      }

      final token = authHeader.substring(7);
      final userId = await authService.validateAccessToken(token);

      if (userId == null) {
        return Response(401,
            body: jsonEncode({'error': 'unauthorized', 'message': 'Invalid or expired token'}),
            headers: {'content-type': 'application/json'});
      }

      final updatedRequest = request.change(context: {...request.context, 'userId': userId});
      return innerHandler(updatedRequest);
    };
  };
}

/// Middleware that optionally extracts userId but doesn't require auth.
Middleware optionalAuthMiddleware(AuthService authService) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final userId = await authService.validateAccessToken(token);
        if (userId != null) {
          final updatedRequest = request.change(context: {...request.context, 'userId': userId});
          return innerHandler(updatedRequest);
        }
      }
      return innerHandler(request);
    };
  };
}
