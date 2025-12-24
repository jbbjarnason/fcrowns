import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:jose/jose.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

const _uuid = Uuid();

class AuthService {
  final AppDatabase db;
  final String jwtSecret;
  final int accessTokenTtlDays;

  late final JsonWebKey _jwk;

  AuthService({
    required this.db,
    required this.jwtSecret,
    this.accessTokenTtlDays = 7,
  }) {
    _jwk = JsonWebKey.fromJson({
      'kty': 'oct',
      'k': base64Url.encode(utf8.encode(jwtSecret)),
    });
  }

  /// Hashes a password using bcrypt.
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  /// Verifies a password against a hash.
  bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }

  /// Hashes a token for storage.
  String hashToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }

  /// Creates a new user. Returns user ID.
  /// Throws if email or username already exists.
  /// If [autoVerify] is true, user is immediately marked as verified.
  Future<String> createUser({
    required String email,
    required String password,
    required String username,
    required String displayName,
    String? avatarUrl,
    bool autoVerify = false,
  }) async {
    final passwordHash = hashPassword(password);
    final userId = _uuid.v4();

    await db.into(db.users).insert(UsersCompanion.insert(
      id: Value(userId),
      email: email.toLowerCase(),
      passwordHash: passwordHash,
      username: username.toLowerCase(),
      displayName: displayName,
      avatarUrl: Value(avatarUrl),
      emailVerifiedAt: autoVerify ? Value(DateTime.now().toUtc()) : const Value.absent(),
    ));

    return userId;
  }

  /// Creates an email verification token.
  Future<String> createVerificationToken(String userId) async {
    final token = _uuid.v4();
    final tokenHash = hashToken(token);

    await db.into(db.emailTokens).insert(EmailTokensCompanion.insert(
      userId: userId,
      type: 'verify',
      tokenHash: tokenHash,
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
    ));

    return token;
  }

  /// Verifies an email token.
  Future<bool> verifyEmail(String token) async {
    final tokenHash = hashToken(token);

    final emailToken = await (db.select(db.emailTokens)
      ..where((t) => t.tokenHash.equals(tokenHash))
      ..where((t) => t.type.equals('verify'))
      ..where((t) => t.usedAt.isNull())
      ..where((t) => t.expiresAt.isBiggerThanValue(DateTime.now().toUtc())))
        .getSingleOrNull();

    if (emailToken == null) return false;

    // Mark token as used
    await (db.update(db.emailTokens)..where((t) => t.id.equals(emailToken.id)))
        .write(EmailTokensCompanion(usedAt: Value(DateTime.now().toUtc())));

    // Mark user as verified
    await (db.update(db.users)..where((u) => u.id.equals(emailToken.userId)))
        .write(UsersCompanion(emailVerifiedAt: Value(DateTime.now().toUtc())));

    return true;
  }

  /// Finds a user by email.
  Future<User?> findUserByEmail(String email) async {
    return await (db.select(db.users)
      ..where((u) => u.email.equals(email.toLowerCase())))
        .getSingleOrNull();
  }

  /// Finds a user by ID.
  Future<User?> findUserById(String userId) async {
    return await (db.select(db.users)
      ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Attempts login. Returns (accessJwt, refreshToken) on success.
  Future<(String, String)?> login(String email, String password) async {
    final user = await findUserByEmail(email);
    if (user == null) return null;

    if (!verifyPassword(password, user.passwordHash)) return null;
    if (user.emailVerifiedAt == null) return null;

    return await _createTokenPair(user.id);
  }

  /// Creates a new access/refresh token pair.
  Future<(String, String)> _createTokenPair(String userId) async {
    final now = DateTime.now().toUtc();
    final expiry = now.add(Duration(days: accessTokenTtlDays));

    // Create access JWT
    final claims = JsonWebTokenClaims.fromJson({
      'sub': userId,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
    });

    final builder = JsonWebSignatureBuilder()
      ..jsonContent = claims.toJson()
      ..addRecipient(_jwk, algorithm: 'HS256');

    final accessJwt = builder.build().toCompactSerialization();

    // Create refresh token
    final refreshToken = _uuid.v4();
    final refreshTokenHash = hashToken(refreshToken);

    await db.into(db.refreshTokens).insert(RefreshTokensCompanion.insert(
      userId: userId,
      tokenHash: refreshTokenHash,
      expiresAt: now.add(const Duration(days: 30)),
    ));

    return (accessJwt, refreshToken);
  }

  /// Validates a JWT and returns the user ID.
  Future<String?> validateAccessToken(String jwt) async {
    try {
      final jws = JsonWebSignature.fromCompactSerialization(jwt);
      final keyStore = JsonWebKeyStore()..addKey(_jwk);
      final verified = await jws.verify(keyStore);
      if (!verified) return null;

      final payload = jws.unverifiedPayload;
      final claims = JsonWebTokenClaims.fromJson(payload.jsonContent as Map<String, dynamic>);

      // Check expiry
      final exp = claims.expiry;
      if (exp != null && exp.isBefore(DateTime.now().toUtc())) {
        return null;
      }

      return claims.subject;
    } catch (e) {
      return null;
    }
  }

  /// Refreshes tokens. Returns new (accessJwt, refreshToken).
  Future<(String, String)?> refreshTokens(String refreshToken) async {
    final tokenHash = hashToken(refreshToken);

    final token = await (db.select(db.refreshTokens)
      ..where((t) => t.tokenHash.equals(tokenHash))
      ..where((t) => t.revokedAt.isNull())
      ..where((t) => t.expiresAt.isBiggerThanValue(DateTime.now().toUtc())))
        .getSingleOrNull();

    if (token == null) return null;

    // Revoke old token
    await (db.update(db.refreshTokens)..where((t) => t.id.equals(token.id)))
        .write(RefreshTokensCompanion(revokedAt: Value(DateTime.now().toUtc())));

    // Create new pair
    return await _createTokenPair(token.userId);
  }

  /// Creates a password reset token.
  Future<String> createPasswordResetToken(String userId) async {
    final token = _uuid.v4();
    final tokenHash = hashToken(token);

    await db.into(db.emailTokens).insert(EmailTokensCompanion.insert(
      userId: userId,
      type: 'reset',
      tokenHash: tokenHash,
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    ));

    return token;
  }

  /// Confirms password reset.
  Future<bool> confirmPasswordReset(String token, String newPassword) async {
    final tokenHash = hashToken(token);

    final emailToken = await (db.select(db.emailTokens)
      ..where((t) => t.tokenHash.equals(tokenHash))
      ..where((t) => t.type.equals('reset'))
      ..where((t) => t.usedAt.isNull())
      ..where((t) => t.expiresAt.isBiggerThanValue(DateTime.now().toUtc())))
        .getSingleOrNull();

    if (emailToken == null) return false;

    // Mark token as used
    await (db.update(db.emailTokens)..where((t) => t.id.equals(emailToken.id)))
        .write(EmailTokensCompanion(usedAt: Value(DateTime.now().toUtc())));

    // Update password
    final passwordHash = hashPassword(newPassword);
    await (db.update(db.users)..where((u) => u.id.equals(emailToken.userId)))
        .write(UsersCompanion(passwordHash: Value(passwordHash)));

    return true;
  }
}
