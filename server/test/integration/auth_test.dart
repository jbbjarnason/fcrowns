import 'package:test/test.dart';
import 'test_helpers.dart';

void main() {
  late TestHarness harness;

  setUp(() async {
    harness = TestHarness();
    await harness.setUp();
  });

  tearDown(() async {
    await harness.tearDown();
  });

  group('Auth Flow', () {
    test('full signup -> verify -> login flow', () async {
      // 1. Signup
      final signupResponse = await harness.request('POST', '/auth/signup', body: {
        'email': 'test@example.com',
        'password': 'securepassword123',
        'username': 'testuser',
        'displayName': 'Test User',
      });

      expect(signupResponse.statusCode, 201);
      final signupJson = await harness.parseJson(signupResponse);
      expect(signupJson['message'], 'verification_sent');

      // 2. Verify email was "sent"
      expect(harness.emailService.sentEmails.length, 1);
      expect(harness.emailService.sentEmails.first.type, 'verification');
      expect(harness.emailService.sentEmails.first.toEmail, 'test@example.com');

      // 3. Try login before verification - should fail
      final earlyLoginResponse = await harness.request('POST', '/auth/login', body: {
        'email': 'test@example.com',
        'password': 'securepassword123',
      });
      expect(earlyLoginResponse.statusCode, 401);

      // 4. Verify email
      final verifyToken = harness.emailService.getLastVerificationToken()!;
      final verifyResponse = await harness.request('POST', '/auth/verify', body: {
        'token': verifyToken,
      });
      expect(verifyResponse.statusCode, 200);

      // 5. Login after verification - should succeed
      final loginResponse = await harness.request('POST', '/auth/login', body: {
        'email': 'test@example.com',
        'password': 'securepassword123',
      });
      expect(loginResponse.statusCode, 200);

      final loginJson = await harness.parseJson(loginResponse);
      expect(loginJson['accessJwt'], isNotEmpty);
      expect(loginJson['refreshToken'], isNotEmpty);
    });

    test('signup with duplicate email fails', () async {
      // First signup
      await harness.request('POST', '/auth/signup', body: {
        'email': 'duplicate@example.com',
        'password': 'password123',
        'username': 'user1',
        'displayName': 'User 1',
      });

      // Second signup with same email
      final response = await harness.request('POST', '/auth/signup', body: {
        'email': 'duplicate@example.com',
        'password': 'password123',
        'username': 'user2',
        'displayName': 'User 2',
      });

      expect(response.statusCode, 409);
    });

    test('signup with duplicate username fails', () async {
      // First signup
      await harness.request('POST', '/auth/signup', body: {
        'email': 'user1@example.com',
        'password': 'password123',
        'username': 'sameusername',
        'displayName': 'User 1',
      });

      // Second signup with same username
      final response = await harness.request('POST', '/auth/signup', body: {
        'email': 'user2@example.com',
        'password': 'password123',
        'username': 'sameusername',
        'displayName': 'User 2',
      });

      expect(response.statusCode, 409);
    });

    test('login with wrong password fails', () async {
      final (_, _) = await createVerifiedUser(
        harness,
        email: 'user@example.com',
        username: 'testuser',
        password: 'correctpassword',
      );

      final response = await harness.request('POST', '/auth/login', body: {
        'email': 'user@example.com',
        'password': 'wrongpassword',
      });

      expect(response.statusCode, 401);
    });

    test('refresh token rotation works', () async {
      final (accessJwt, refreshToken) = await createVerifiedUser(
        harness,
        email: 'refresh@example.com',
        username: 'refreshuser',
      );

      // Use refresh token
      final refreshResponse = await harness.request('POST', '/auth/refresh', body: {
        'refreshToken': refreshToken,
      });

      expect(refreshResponse.statusCode, 200);
      final refreshJson = await harness.parseJson(refreshResponse);
      expect(refreshJson['accessJwt'], isNotEmpty);
      expect(refreshJson['refreshToken'], isNotEmpty);
      expect(refreshJson['refreshToken'], isNot(equals(refreshToken))); // Rotated

      // Old refresh token should no longer work
      final oldRefreshResponse = await harness.request('POST', '/auth/refresh', body: {
        'refreshToken': refreshToken,
      });
      expect(oldRefreshResponse.statusCode, 401);
    });

    test('password reset flow works', () async {
      final (_, _) = await createVerifiedUser(
        harness,
        email: 'reset@example.com',
        username: 'resetuser',
        password: 'oldpassword123',
      );

      // Request password reset
      final requestResponse = await harness.request('POST', '/auth/password-reset/request', body: {
        'email': 'reset@example.com',
      });
      expect(requestResponse.statusCode, 200);

      // Get reset token
      final resetToken = harness.emailService.getLastPasswordResetToken()!;

      // Confirm password reset
      final confirmResponse = await harness.request('POST', '/auth/password-reset/confirm', body: {
        'token': resetToken,
        'newPassword': 'newpassword456',
      });
      expect(confirmResponse.statusCode, 200);

      // Login with new password
      final loginResponse = await harness.request('POST', '/auth/login', body: {
        'email': 'reset@example.com',
        'password': 'newpassword456',
      });
      expect(loginResponse.statusCode, 200);

      // Old password should not work
      final oldLoginResponse = await harness.request('POST', '/auth/login', body: {
        'email': 'reset@example.com',
        'password': 'oldpassword123',
      });
      expect(oldLoginResponse.statusCode, 401);
    });

    test('password reset request for non-existent email returns 200 (no enumeration)', () async {
      final response = await harness.request('POST', '/auth/password-reset/request', body: {
        'email': 'nonexistent@example.com',
      });

      // Should return 200 to prevent user enumeration
      expect(response.statusCode, 200);
      // But no email should be sent
      expect(
        harness.emailService.sentEmails.where((e) => e.type == 'password_reset').length,
        0,
      );
    });

    test('access token validates correctly', () async {
      final (accessJwt, _) = await createVerifiedUser(
        harness,
        email: 'access@example.com',
        username: 'accessuser',
      );

      // Use access token to access protected endpoint
      final meResponse = await harness.request(
        'GET',
        '/users/me',
        authToken: accessJwt,
      );

      expect(meResponse.statusCode, 200);
      final meJson = await harness.parseJson(meResponse);
      expect(meJson['email'], 'access@example.com');
      expect(meJson['username'], 'accessuser');
      expect(meJson['emailVerified'], true);
    });

    test('invalid access token is rejected', () async {
      final response = await harness.request(
        'GET',
        '/users/me',
        authToken: 'invalid-token',
      );

      expect(response.statusCode, 401);
    });

    test('missing access token is rejected', () async {
      final response = await harness.request('GET', '/users/me');
      expect(response.statusCode, 401);
    });
  });
}
