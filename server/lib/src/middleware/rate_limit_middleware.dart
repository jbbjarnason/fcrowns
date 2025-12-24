import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

/// Rate limiting middleware to prevent brute force and DoS attacks
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final bool trustProxy;
  final Map<String, _RateLimit> _limits = {};

  /// Check if rate limiting is disabled (for testing)
  static bool get isDisabled =>
      Platform.environment['DISABLE_RATE_LIMIT'] == 'true';

  RateLimiter({
    this.maxRequests = 60,
    this.window = const Duration(minutes: 1),
    this.trustProxy = false,
  });

  /// Middleware for general API rate limiting
  Middleware middleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Skip rate limiting if disabled (for testing)
        if (isDisabled) {
          return innerHandler(request);
        }

        final clientIp = _getClientIp(request);

        if (!_checkLimit(clientIp)) {
          return Response(429,
              body: jsonEncode({
                'error': 'rate_limit_exceeded',
                'message': 'Too many requests. Please try again later.',
              }),
              headers: {'content-type': 'application/json'});
        }

        return innerHandler(request);
      };
    };
  }

  /// Stricter middleware for auth endpoints
  Middleware authMiddleware() {
    final authLimiter = RateLimiter(maxRequests: 10, window: const Duration(minutes: 5), trustProxy: trustProxy);
    return (Handler innerHandler) {
      return (Request request) async {
        // Skip rate limiting if disabled (for testing)
        if (isDisabled) {
          return innerHandler(request);
        }

        final clientIp = authLimiter._getClientIp(request);

        if (!authLimiter._checkLimit(clientIp)) {
          return Response(429,
              body: jsonEncode({
                'error': 'rate_limit_exceeded',
                'message': 'Too many authentication attempts. Please try again in 5 minutes.',
              }),
              headers: {'content-type': 'application/json'});
        }

        return innerHandler(request);
      };
    };
  }

  bool _checkLimit(String key) {
    final now = DateTime.now();
    _cleanupOldEntries(now);

    final limit = _limits.putIfAbsent(key, () => _RateLimit(now, 0));

    if (now.difference(limit.windowStart) > window) {
      // Reset window
      limit.windowStart = now;
      limit.count = 1;
      return true;
    }

    limit.count++;
    return limit.count <= maxRequests;
  }

  void _cleanupOldEntries(DateTime now) {
    _limits.removeWhere((_, limit) =>
        now.difference(limit.windowStart) > window * 2);
  }

  String _getClientIp(Request request) {
    // Only trust proxy headers if explicitly configured
    // This prevents IP spoofing when not behind a trusted proxy
    if (trustProxy) {
      final forwarded = request.headers['x-forwarded-for'];
      if (forwarded != null && forwarded.isNotEmpty) {
        // Take the first IP (client IP) from the chain
        return forwarded.split(',').first.trim();
      }

      final realIp = request.headers['x-real-ip'];
      if (realIp != null && realIp.isNotEmpty) {
        return realIp;
      }
    }

    // Use connection info or fallback
    // Note: shelf doesn't expose connection info directly,
    // so we hash the request to create a semi-unique identifier
    // In production behind a proxy, trustProxy should be true
    return 'direct-${request.headers['user-agent']?.hashCode ?? 'unknown'}';
  }
}

class _RateLimit {
  DateTime windowStart;
  int count;

  _RateLimit(this.windowStart, this.count);
}
