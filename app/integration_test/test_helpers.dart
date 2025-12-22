import 'dart:convert';
import 'package:http/http.dart' as http;

// Use environment variable or default to localhost
// For iOS simulator, use host machine IP (e.g., 10.50.10.30)
// Can be overridden via --dart-define=API_HOST=...
const _defaultApiHost = String.fromEnvironment('API_HOST', defaultValue: '10.50.10.30');
const _defaultMailpitHost = String.fromEnvironment('MAILPIT_HOST', defaultValue: '10.50.10.30');

String get apiUrl => 'http://$_defaultApiHost:8080';
String get mailpitUrl => 'http://$_defaultMailpitHost:8025';

/// Generates a unique test user with random ID
Map<String, String> generateTestUser() {
  final id = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  return {
    'email': 'test-$id@test.local',
    'username': 'user$id',
    'displayName': 'Test User $id',
    'password': 'SecurePass123!',
  };
}

/// Gets verification token from Mailpit for a given email
Future<String?> getVerificationToken(String email, {int retries = 5}) async {
  for (var i = 0; i < retries; i++) {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final messagesRes = await http.get(
        Uri.parse('$mailpitUrl/api/v1/search?query=to:$email'),
      );

      if (messagesRes.statusCode == 200) {
        final messages = jsonDecode(messagesRes.body);
        if (messages['messages'] != null &&
            (messages['messages'] as List).isNotEmpty) {
          final messageId = messages['messages'][0]['ID'];
          final messageRes = await http.get(
            Uri.parse('$mailpitUrl/api/v1/message/$messageId'),
          );

          if (messageRes.statusCode == 200) {
            final message = jsonDecode(messageRes.body);
            final text = message['Text'] ?? message['HTML'] ?? '';
            final match = RegExp(r'token=([a-zA-Z0-9-]+)').firstMatch(text);
            if (match != null) {
              return match.group(1);
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching verification token: $e');
    }
  }
  return null;
}

/// Gets password reset token from Mailpit for a given email
Future<String?> getPasswordResetToken(String email, {int retries = 5}) async {
  for (var i = 0; i < retries; i++) {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final messagesRes = await http.get(
        Uri.parse('$mailpitUrl/api/v1/search?query=to:$email'),
      );

      if (messagesRes.statusCode == 200) {
        final messages = jsonDecode(messagesRes.body);
        final messageList = messages['messages'] as List? ?? [];

        // Look for the password reset email (should be the most recent)
        for (final msg in messageList) {
          final messageId = msg['ID'];
          final messageRes = await http.get(
            Uri.parse('$mailpitUrl/api/v1/message/$messageId'),
          );

          if (messageRes.statusCode == 200) {
            final message = jsonDecode(messageRes.body);
            final text = message['Text'] ?? message['HTML'] ?? '';

            // Look for password reset token pattern
            if (text.contains('password') || text.contains('reset')) {
              final match = RegExp(r'token=([a-zA-Z0-9-]+)').firstMatch(text);
              if (match != null) {
                return match.group(1);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching password reset token: $e');
    }
  }
  return null;
}

/// Registers a new user via API
Future<bool> registerUser(Map<String, String> user) async {
  final response = await http.post(
    Uri.parse('$apiUrl/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user),
  );
  return response.statusCode == 201;
}

/// Verifies a user's email via API
Future<bool> verifyEmail(String token) async {
  final response = await http.post(
    Uri.parse('$apiUrl/auth/verify'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'token': token}),
  );
  return response.statusCode == 200;
}

/// Logs in a user via API and returns tokens
Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('$apiUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

/// Creates and verifies a test user, returning their credentials
Future<Map<String, dynamic>?> createVerifiedUser() async {
  final user = generateTestUser();

  // Register
  final registered = await registerUser(user);
  if (!registered) {
    print('Failed to register user');
    return null;
  }

  // Get verification token
  final token = await getVerificationToken(user['email']!);
  if (token == null) {
    print('Failed to get verification token');
    return null;
  }

  // Verify
  final verified = await verifyEmail(token);
  if (!verified) {
    print('Failed to verify email');
    return null;
  }

  return user;
}

/// Requests password reset via API
Future<bool> requestPasswordReset(String email) async {
  final response = await http.post(
    Uri.parse('$apiUrl/auth/password-reset/request'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );
  return response.statusCode == 200;
}

/// Confirms password reset via API
Future<bool> confirmPasswordReset(String token, String newPassword) async {
  final response = await http.post(
    Uri.parse('$apiUrl/auth/password-reset/confirm'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'token': token, 'newPassword': newPassword}),
  );
  return response.statusCode == 200;
}

/// Clears all Mailpit messages (useful for test cleanup)
Future<void> clearMailpit() async {
  try {
    await http.delete(Uri.parse('$mailpitUrl/api/v1/messages'));
  } catch (e) {
    print('Error clearing Mailpit: $e');
  }
}

/// Sends a friend request via API
Future<bool> sendFriendRequest(String accessToken, String userId) async {
  final response = await http.post(
    Uri.parse('$apiUrl/friends/request'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({'userId': userId}),
  );
  return response.statusCode == 201 || response.statusCode == 200;
}

/// Accepts a friend request via API
Future<bool> acceptFriendRequest(String accessToken, String userId) async {
  final response = await http.post(
    Uri.parse('$apiUrl/friends/accept'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({'userId': userId}),
  );
  return response.statusCode == 200;
}

/// Gets current user info via API
Future<Map<String, dynamic>?> getMe(String accessToken) async {
  final response = await http.get(
    Uri.parse('$apiUrl/users/me'),
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

/// Creates a game via API
Future<Map<String, dynamic>?> createGame(String accessToken, {int maxPlayers = 4}) async {
  final response = await http.post(
    Uri.parse('$apiUrl/games/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({'maxPlayers': maxPlayers}),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  }
  return null;
}

/// Invites a player to a game via API
Future<bool> invitePlayer(String accessToken, String gameId, String userId) async {
  final response = await http.post(
    Uri.parse('$apiUrl/games/$gameId/invite'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({'userId': userId}),
  );
  return response.statusCode == 200;
}
