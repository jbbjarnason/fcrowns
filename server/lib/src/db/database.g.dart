// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuidGen.v4());
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailVerifiedAtMeta =
      const VerificationMeta('emailVerifiedAt');
  @override
  late final GeneratedColumn<DateTime> emailVerifiedAt =
      GeneratedColumn<DateTime>('email_verified_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        passwordHash,
        username,
        displayName,
        avatarUrl,
        emailVerifiedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('email_verified_at')) {
      context.handle(
          _emailVerifiedAtMeta,
          emailVerifiedAt.isAcceptableOrUnknown(
              data['email_verified_at']!, _emailVerifiedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      emailVerifiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}email_verified_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String passwordHash;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  const User(
      {required this.id,
      required this.email,
      required this.passwordHash,
      required this.username,
      required this.displayName,
      this.avatarUrl,
      this.emailVerifiedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || emailVerifiedAt != null) {
      map['email_verified_at'] = Variable<DateTime>(emailVerifiedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      passwordHash: Value(passwordHash),
      username: Value(username),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      emailVerifiedAt: emailVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(emailVerifiedAt),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      emailVerifiedAt: serializer.fromJson<DateTime?>(json['emailVerifiedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'emailVerifiedAt': serializer.toJson<DateTime?>(emailVerifiedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith(
          {String? id,
          String? email,
          String? passwordHash,
          String? username,
          String? displayName,
          Value<String?> avatarUrl = const Value.absent(),
          Value<DateTime?> emailVerifiedAt = const Value.absent(),
          DateTime? createdAt}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        emailVerifiedAt: emailVerifiedAt.present
            ? emailVerifiedAt.value
            : this.emailVerifiedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      username: data.username.present ? data.username.value : this.username,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      emailVerifiedAt: data.emailVerifiedAt.present
          ? data.emailVerifiedAt.value
          : this.emailVerifiedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('emailVerifiedAt: $emailVerifiedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, passwordHash, username,
      displayName, avatarUrl, emailVerifiedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.emailVerifiedAt == this.emailVerifiedAt &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<DateTime?> emailVerifiedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.emailVerifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String passwordHash,
    required String username,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.emailVerifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : email = Value(email),
        passwordHash = Value(passwordHash),
        username = Value(username),
        displayName = Value(displayName);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<DateTime>? emailVerifiedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (emailVerifiedAt != null) 'email_verified_at': emailVerifiedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? passwordHash,
      Value<String>? username,
      Value<String>? displayName,
      Value<String?>? avatarUrl,
      Value<DateTime?>? emailVerifiedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (emailVerifiedAt.present) {
      map['email_verified_at'] = Variable<DateTime>(emailVerifiedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('emailVerifiedAt: $emailVerifiedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmailTokensTable extends EmailTokens
    with TableInfo<$EmailTokensTable, EmailToken> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmailTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuidGen.v4());
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenHashMeta =
      const VerificationMeta('tokenHash');
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
      'token_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<DateTime> usedAt = GeneratedColumn<DateTime>(
      'used_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, type, tokenHash, expiresAt, usedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'email_tokens';
  @override
  VerificationContext validateIntegrity(Insertable<EmailToken> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(_tokenHashMeta,
          tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta));
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(_usedAtMeta,
          usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmailToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmailToken(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      tokenHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_hash'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      usedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}used_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EmailTokensTable createAlias(String alias) {
    return $EmailTokensTable(attachedDatabase, alias);
  }
}

class EmailToken extends DataClass implements Insertable<EmailToken> {
  final String id;
  final String userId;
  final String type;
  final String tokenHash;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime createdAt;
  const EmailToken(
      {required this.id,
      required this.userId,
      required this.type,
      required this.tokenHash,
      required this.expiresAt,
      this.usedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    map['token_hash'] = Variable<String>(tokenHash);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || usedAt != null) {
      map['used_at'] = Variable<DateTime>(usedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmailTokensCompanion toCompanion(bool nullToAbsent) {
    return EmailTokensCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      tokenHash: Value(tokenHash),
      expiresAt: Value(expiresAt),
      usedAt:
          usedAt == null && nullToAbsent ? const Value.absent() : Value(usedAt),
      createdAt: Value(createdAt),
    );
  }

  factory EmailToken.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmailToken(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      usedAt: serializer.fromJson<DateTime?>(json['usedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'usedAt': serializer.toJson<DateTime?>(usedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EmailToken copyWith(
          {String? id,
          String? userId,
          String? type,
          String? tokenHash,
          DateTime? expiresAt,
          Value<DateTime?> usedAt = const Value.absent(),
          DateTime? createdAt}) =>
      EmailToken(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        tokenHash: tokenHash ?? this.tokenHash,
        expiresAt: expiresAt ?? this.expiresAt,
        usedAt: usedAt.present ? usedAt.value : this.usedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  EmailToken copyWithCompanion(EmailTokensCompanion data) {
    return EmailToken(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmailToken(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('usedAt: $usedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, tokenHash, expiresAt, usedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmailToken &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.tokenHash == this.tokenHash &&
          other.expiresAt == this.expiresAt &&
          other.usedAt == this.usedAt &&
          other.createdAt == this.createdAt);
}

class EmailTokensCompanion extends UpdateCompanion<EmailToken> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String> tokenHash;
  final Value<DateTime> expiresAt;
  final Value<DateTime?> usedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EmailTokensCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.usedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmailTokensCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String type,
    required String tokenHash,
    required DateTime expiresAt,
    this.usedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        type = Value(type),
        tokenHash = Value(tokenHash),
        expiresAt = Value(expiresAt);
  static Insertable<EmailToken> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? tokenHash,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? usedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (usedAt != null) 'used_at': usedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmailTokensCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? type,
      Value<String>? tokenHash,
      Value<DateTime>? expiresAt,
      Value<DateTime?>? usedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return EmailTokensCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      tokenHash: tokenHash ?? this.tokenHash,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<DateTime>(usedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmailTokensCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('usedAt: $usedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefreshTokensTable extends RefreshTokens
    with TableInfo<$RefreshTokensTable, RefreshToken> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefreshTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuidGen.v4());
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _tokenHashMeta =
      const VerificationMeta('tokenHash');
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
      'token_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _revokedAtMeta =
      const VerificationMeta('revokedAt');
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
      'revoked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, tokenHash, expiresAt, revokedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refresh_tokens';
  @override
  VerificationContext validateIntegrity(Insertable<RefreshToken> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token_hash')) {
      context.handle(_tokenHashMeta,
          tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta));
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('revoked_at')) {
      context.handle(_revokedAtMeta,
          revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefreshToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefreshToken(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      tokenHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token_hash'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
      revokedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}revoked_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RefreshTokensTable createAlias(String alias) {
    return $RefreshTokensTable(attachedDatabase, alias);
  }
}

class RefreshToken extends DataClass implements Insertable<RefreshToken> {
  final String id;
  final String userId;
  final String tokenHash;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;
  const RefreshToken(
      {required this.id,
      required this.userId,
      required this.tokenHash,
      required this.expiresAt,
      this.revokedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['token_hash'] = Variable<String>(tokenHash);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RefreshTokensCompanion toCompanion(bool nullToAbsent) {
    return RefreshTokensCompanion(
      id: Value(id),
      userId: Value(userId),
      tokenHash: Value(tokenHash),
      expiresAt: Value(expiresAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      createdAt: Value(createdAt),
    );
  }

  factory RefreshToken.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefreshToken(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RefreshToken copyWith(
          {String? id,
          String? userId,
          String? tokenHash,
          DateTime? expiresAt,
          Value<DateTime?> revokedAt = const Value.absent(),
          DateTime? createdAt}) =>
      RefreshToken(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        tokenHash: tokenHash ?? this.tokenHash,
        expiresAt: expiresAt ?? this.expiresAt,
        revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  RefreshToken copyWithCompanion(RefreshTokensCompanion data) {
    return RefreshToken(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefreshToken(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, tokenHash, expiresAt, revokedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefreshToken &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.tokenHash == this.tokenHash &&
          other.expiresAt == this.expiresAt &&
          other.revokedAt == this.revokedAt &&
          other.createdAt == this.createdAt);
}

class RefreshTokensCompanion extends UpdateCompanion<RefreshToken> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> tokenHash;
  final Value<DateTime> expiresAt;
  final Value<DateTime?> revokedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RefreshTokensCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefreshTokensCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String tokenHash,
    required DateTime expiresAt,
    this.revokedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        tokenHash = Value(tokenHash),
        expiresAt = Value(expiresAt);
  static Insertable<RefreshToken> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? tokenHash,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? revokedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefreshTokensCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? tokenHash,
      Value<DateTime>? expiresAt,
      Value<DateTime?>? revokedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RefreshTokensCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tokenHash: tokenHash ?? this.tokenHash,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefreshTokensCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendshipsTable extends Friendships
    with TableInfo<$FriendshipsTable, Friendship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _friendIdMeta =
      const VerificationMeta('friendId');
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
      'friend_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns => [userId, friendId, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friendships';
  @override
  VerificationContext validateIntegrity(Insertable<Friendship> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(_friendIdMeta,
          friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, friendId};
  @override
  Friendship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Friendship(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      friendId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FriendshipsTable createAlias(String alias) {
    return $FriendshipsTable(attachedDatabase, alias);
  }
}

class Friendship extends DataClass implements Insertable<Friendship> {
  final String userId;
  final String friendId;
  final String status;
  final DateTime createdAt;
  const Friendship(
      {required this.userId,
      required this.friendId,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['friend_id'] = Variable<String>(friendId);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FriendshipsCompanion toCompanion(bool nullToAbsent) {
    return FriendshipsCompanion(
      userId: Value(userId),
      friendId: Value(friendId),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Friendship.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Friendship(
      userId: serializer.fromJson<String>(json['userId']),
      friendId: serializer.fromJson<String>(json['friendId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'friendId': serializer.toJson<String>(friendId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Friendship copyWith(
          {String? userId,
          String? friendId,
          String? status,
          DateTime? createdAt}) =>
      Friendship(
        userId: userId ?? this.userId,
        friendId: friendId ?? this.friendId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  Friendship copyWithCompanion(FriendshipsCompanion data) {
    return Friendship(
      userId: data.userId.present ? data.userId.value : this.userId,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Friendship(')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, friendId, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Friendship &&
          other.userId == this.userId &&
          other.friendId == this.friendId &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class FriendshipsCompanion extends UpdateCompanion<Friendship> {
  final Value<String> userId;
  final Value<String> friendId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FriendshipsCompanion({
    this.userId = const Value.absent(),
    this.friendId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendshipsCompanion.insert({
    required String userId,
    required String friendId,
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        friendId = Value(friendId),
        status = Value(status);
  static Insertable<Friendship> custom({
    Expression<String>? userId,
    Expression<String>? friendId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (friendId != null) 'friend_id': friendId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendshipsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? friendId,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FriendshipsCompanion(
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendshipsCompanion(')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuidGen.v4());
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _maxPlayersMeta =
      const VerificationMeta('maxPlayers');
  @override
  late final GeneratedColumn<int> maxPlayers = GeneratedColumn<int>(
      'max_players', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(7));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, status, createdBy, maxPlayers, createdAt, finishedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(Insertable<Game> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('max_players')) {
      context.handle(
          _maxPlayersMeta,
          maxPlayers.isAcceptableOrUnknown(
              data['max_players']!, _maxPlayersMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      maxPlayers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_players'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final String id;
  final String status;
  final String createdBy;
  final int maxPlayers;
  final DateTime createdAt;
  final DateTime? finishedAt;
  const Game(
      {required this.id,
      required this.status,
      required this.createdBy,
      required this.maxPlayers,
      required this.createdAt,
      this.finishedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    map['max_players'] = Variable<int>(maxPlayers);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      status: Value(status),
      createdBy: Value(createdBy),
      maxPlayers: Value(maxPlayers),
      createdAt: Value(createdAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory Game.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      maxPlayers: serializer.fromJson<int>(json['maxPlayers']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
      'maxPlayers': serializer.toJson<int>(maxPlayers),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  Game copyWith(
          {String? id,
          String? status,
          String? createdBy,
          int? maxPlayers,
          DateTime? createdAt,
          Value<DateTime?> finishedAt = const Value.absent()}) =>
      Game(
        id: id ?? this.id,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        maxPlayers: maxPlayers ?? this.maxPlayers,
        createdAt: createdAt ?? this.createdAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
      );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      maxPlayers:
          data.maxPlayers.present ? data.maxPlayers.value : this.maxPlayers,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, status, createdBy, maxPlayers, createdAt, finishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.maxPlayers == this.maxPlayers &&
          other.createdAt == this.createdAt &&
          other.finishedAt == this.finishedAt);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<String> id;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<int> maxPlayers;
  final Value<DateTime> createdAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required String status,
    required String createdBy,
    this.maxPlayers = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : status = Value(status),
        createdBy = Value(createdBy);
  static Insertable<Game> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<int>? maxPlayers,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (createdAt != null) 'created_at': createdAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith(
      {Value<String>? id,
      Value<String>? status,
      Value<String>? createdBy,
      Value<int>? maxPlayers,
      Value<DateTime>? createdAt,
      Value<DateTime?>? finishedAt,
      Value<int>? rowid}) {
    return GamesCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (maxPlayers.present) {
      map['max_players'] = Variable<int>(maxPlayers.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GamePlayersTable extends GamePlayers
    with TableInfo<$GamePlayersTable, GamePlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamePlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
      'game_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES games (id) ON DELETE CASCADE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<int> seat = GeneratedColumn<int>(
      'seat', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns => [gameId, userId, seat, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_players';
  @override
  VerificationContext validateIntegrity(Insertable<GamePlayer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta,
          gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('seat')) {
      context.handle(
          _seatMeta, seat.isAcceptableOrUnknown(data['seat']!, _seatMeta));
    } else if (isInserting) {
      context.missing(_seatMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, userId};
  @override
  GamePlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GamePlayer(
      gameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      seat: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seat'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $GamePlayersTable createAlias(String alias) {
    return $GamePlayersTable(attachedDatabase, alias);
  }
}

class GamePlayer extends DataClass implements Insertable<GamePlayer> {
  final String gameId;
  final String userId;
  final int seat;
  final DateTime joinedAt;
  const GamePlayer(
      {required this.gameId,
      required this.userId,
      required this.seat,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['user_id'] = Variable<String>(userId);
    map['seat'] = Variable<int>(seat);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  GamePlayersCompanion toCompanion(bool nullToAbsent) {
    return GamePlayersCompanion(
      gameId: Value(gameId),
      userId: Value(userId),
      seat: Value(seat),
      joinedAt: Value(joinedAt),
    );
  }

  factory GamePlayer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GamePlayer(
      gameId: serializer.fromJson<String>(json['gameId']),
      userId: serializer.fromJson<String>(json['userId']),
      seat: serializer.fromJson<int>(json['seat']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'userId': serializer.toJson<String>(userId),
      'seat': serializer.toJson<int>(seat),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  GamePlayer copyWith(
          {String? gameId, String? userId, int? seat, DateTime? joinedAt}) =>
      GamePlayer(
        gameId: gameId ?? this.gameId,
        userId: userId ?? this.userId,
        seat: seat ?? this.seat,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  GamePlayer copyWithCompanion(GamePlayersCompanion data) {
    return GamePlayer(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      userId: data.userId.present ? data.userId.value : this.userId,
      seat: data.seat.present ? data.seat.value : this.seat,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GamePlayer(')
          ..write('gameId: $gameId, ')
          ..write('userId: $userId, ')
          ..write('seat: $seat, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, userId, seat, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GamePlayer &&
          other.gameId == this.gameId &&
          other.userId == this.userId &&
          other.seat == this.seat &&
          other.joinedAt == this.joinedAt);
}

class GamePlayersCompanion extends UpdateCompanion<GamePlayer> {
  final Value<String> gameId;
  final Value<String> userId;
  final Value<int> seat;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const GamePlayersCompanion({
    this.gameId = const Value.absent(),
    this.userId = const Value.absent(),
    this.seat = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamePlayersCompanion.insert({
    required String gameId,
    required String userId,
    required int seat,
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : gameId = Value(gameId),
        userId = Value(userId),
        seat = Value(seat);
  static Insertable<GamePlayer> custom({
    Expression<String>? gameId,
    Expression<String>? userId,
    Expression<int>? seat,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (userId != null) 'user_id': userId,
      if (seat != null) 'seat': seat,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamePlayersCompanion copyWith(
      {Value<String>? gameId,
      Value<String>? userId,
      Value<int>? seat,
      Value<DateTime>? joinedAt,
      Value<int>? rowid}) {
    return GamePlayersCompanion(
      gameId: gameId ?? this.gameId,
      userId: userId ?? this.userId,
      seat: seat ?? this.seat,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (seat.present) {
      map['seat'] = Variable<int>(seat.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamePlayersCompanion(')
          ..write('gameId: $gameId, ')
          ..write('userId: $userId, ')
          ..write('seat: $seat, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameEventsTable extends GameEvents
    with TableInfo<$GameEventsTable, GameEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
      'game_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES games (id) ON DELETE CASCADE'));
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns =>
      [gameId, serverSeq, type, payloadJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_events';
  @override
  VerificationContext validateIntegrity(Insertable<GameEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta,
          gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    } else if (isInserting) {
      context.missing(_serverSeqMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, serverSeq};
  @override
  GameEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameEvent(
      gameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GameEventsTable createAlias(String alias) {
    return $GameEventsTable(attachedDatabase, alias);
  }
}

class GameEvent extends DataClass implements Insertable<GameEvent> {
  final String gameId;
  final int serverSeq;
  final String type;
  final String payloadJson;
  final DateTime createdAt;
  const GameEvent(
      {required this.gameId,
      required this.serverSeq,
      required this.type,
      required this.payloadJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['server_seq'] = Variable<int>(serverSeq);
    map['type'] = Variable<String>(type);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GameEventsCompanion toCompanion(bool nullToAbsent) {
    return GameEventsCompanion(
      gameId: Value(gameId),
      serverSeq: Value(serverSeq),
      type: Value(type),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory GameEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameEvent(
      gameId: serializer.fromJson<String>(json['gameId']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GameEvent copyWith(
          {String? gameId,
          int? serverSeq,
          String? type,
          String? payloadJson,
          DateTime? createdAt}) =>
      GameEvent(
        gameId: gameId ?? this.gameId,
        serverSeq: serverSeq ?? this.serverSeq,
        type: type ?? this.type,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
      );
  GameEvent copyWithCompanion(GameEventsCompanion data) {
    return GameEvent(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      type: data.type.present ? data.type.value : this.type,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameEvent(')
          ..write('gameId: $gameId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(gameId, serverSeq, type, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameEvent &&
          other.gameId == this.gameId &&
          other.serverSeq == this.serverSeq &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class GameEventsCompanion extends UpdateCompanion<GameEvent> {
  final Value<String> gameId;
  final Value<int> serverSeq;
  final Value<String> type;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GameEventsCompanion({
    this.gameId = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameEventsCompanion.insert({
    required String gameId,
    required int serverSeq,
    required String type,
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : gameId = Value(gameId),
        serverSeq = Value(serverSeq),
        type = Value(type);
  static Insertable<GameEvent> custom({
    Expression<String>? gameId,
    Expression<int>? serverSeq,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameEventsCompanion copyWith(
      {Value<String>? gameId,
      Value<int>? serverSeq,
      Value<String>? type,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GameEventsCompanion(
      gameId: gameId ?? this.gameId,
      serverSeq: serverSeq ?? this.serverSeq,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameEventsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSnapshotsTable extends GameSnapshots
    with TableInfo<$GameSnapshotsTable, GameSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
      'game_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES games (id) ON DELETE CASCADE'));
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateJsonMeta =
      const VerificationMeta('stateJson');
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
      'state_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns =>
      [gameId, serverSeq, stateJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<GameSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta,
          gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    } else if (isInserting) {
      context.missing(_serverSeqMeta);
    }
    if (data.containsKey('state_json')) {
      context.handle(_stateJsonMeta,
          stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta));
    } else if (isInserting) {
      context.missing(_stateJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  GameSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSnapshot(
      gameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq'])!,
      stateJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GameSnapshotsTable createAlias(String alias) {
    return $GameSnapshotsTable(attachedDatabase, alias);
  }
}

class GameSnapshot extends DataClass implements Insertable<GameSnapshot> {
  final String gameId;
  final int serverSeq;
  final String stateJson;
  final DateTime updatedAt;
  const GameSnapshot(
      {required this.gameId,
      required this.serverSeq,
      required this.stateJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['server_seq'] = Variable<int>(serverSeq);
    map['state_json'] = Variable<String>(stateJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GameSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return GameSnapshotsCompanion(
      gameId: Value(gameId),
      serverSeq: Value(serverSeq),
      stateJson: Value(stateJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory GameSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSnapshot(
      gameId: serializer.fromJson<String>(json['gameId']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'stateJson': serializer.toJson<String>(stateJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GameSnapshot copyWith(
          {String? gameId,
          int? serverSeq,
          String? stateJson,
          DateTime? updatedAt}) =>
      GameSnapshot(
        gameId: gameId ?? this.gameId,
        serverSeq: serverSeq ?? this.serverSeq,
        stateJson: stateJson ?? this.stateJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GameSnapshot copyWithCompanion(GameSnapshotsCompanion data) {
    return GameSnapshot(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSnapshot(')
          ..write('gameId: $gameId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('stateJson: $stateJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, serverSeq, stateJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSnapshot &&
          other.gameId == this.gameId &&
          other.serverSeq == this.serverSeq &&
          other.stateJson == this.stateJson &&
          other.updatedAt == this.updatedAt);
}

class GameSnapshotsCompanion extends UpdateCompanion<GameSnapshot> {
  final Value<String> gameId;
  final Value<int> serverSeq;
  final Value<String> stateJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GameSnapshotsCompanion({
    this.gameId = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSnapshotsCompanion.insert({
    required String gameId,
    required int serverSeq,
    required String stateJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : gameId = Value(gameId),
        serverSeq = Value(serverSeq),
        stateJson = Value(stateJson);
  static Insertable<GameSnapshot> custom({
    Expression<String>? gameId,
    Expression<int>? serverSeq,
    Expression<String>? stateJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (stateJson != null) 'state_json': stateJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSnapshotsCompanion copyWith(
      {Value<String>? gameId,
      Value<int>? serverSeq,
      Value<String>? stateJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GameSnapshotsCompanion(
      gameId: gameId ?? this.gameId,
      serverSeq: serverSeq ?? this.serverSeq,
      stateJson: stateJson ?? this.stateJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSnapshotsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('stateJson: $stateJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameResultsTable extends GameResults
    with TableInfo<$GameResultsTable, GameResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
      'game_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES games (id) ON DELETE CASCADE'));
  static const VerificationMeta _winnerUserIdMeta =
      const VerificationMeta('winnerUserId');
  @override
  late final GeneratedColumn<String> winnerUserId = GeneratedColumn<String>(
      'winner_user_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _scoresJsonMeta =
      const VerificationMeta('scoresJson');
  @override
  late final GeneratedColumn<String> scoresJson = GeneratedColumn<String>(
      'scores_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns =>
      [gameId, winnerUserId, scoresJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_results';
  @override
  VerificationContext validateIntegrity(Insertable<GameResult> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta,
          gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('winner_user_id')) {
      context.handle(
          _winnerUserIdMeta,
          winnerUserId.isAcceptableOrUnknown(
              data['winner_user_id']!, _winnerUserIdMeta));
    }
    if (data.containsKey('scores_json')) {
      context.handle(
          _scoresJsonMeta,
          scoresJson.isAcceptableOrUnknown(
              data['scores_json']!, _scoresJsonMeta));
    } else if (isInserting) {
      context.missing(_scoresJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  GameResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameResult(
      gameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_id'])!,
      winnerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}winner_user_id']),
      scoresJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scores_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GameResultsTable createAlias(String alias) {
    return $GameResultsTable(attachedDatabase, alias);
  }
}

class GameResult extends DataClass implements Insertable<GameResult> {
  final String gameId;
  final String? winnerUserId;
  final String scoresJson;
  final DateTime createdAt;
  const GameResult(
      {required this.gameId,
      this.winnerUserId,
      required this.scoresJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    if (!nullToAbsent || winnerUserId != null) {
      map['winner_user_id'] = Variable<String>(winnerUserId);
    }
    map['scores_json'] = Variable<String>(scoresJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GameResultsCompanion toCompanion(bool nullToAbsent) {
    return GameResultsCompanion(
      gameId: Value(gameId),
      winnerUserId: winnerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerUserId),
      scoresJson: Value(scoresJson),
      createdAt: Value(createdAt),
    );
  }

  factory GameResult.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameResult(
      gameId: serializer.fromJson<String>(json['gameId']),
      winnerUserId: serializer.fromJson<String?>(json['winnerUserId']),
      scoresJson: serializer.fromJson<String>(json['scoresJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'winnerUserId': serializer.toJson<String?>(winnerUserId),
      'scoresJson': serializer.toJson<String>(scoresJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GameResult copyWith(
          {String? gameId,
          Value<String?> winnerUserId = const Value.absent(),
          String? scoresJson,
          DateTime? createdAt}) =>
      GameResult(
        gameId: gameId ?? this.gameId,
        winnerUserId:
            winnerUserId.present ? winnerUserId.value : this.winnerUserId,
        scoresJson: scoresJson ?? this.scoresJson,
        createdAt: createdAt ?? this.createdAt,
      );
  GameResult copyWithCompanion(GameResultsCompanion data) {
    return GameResult(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      winnerUserId: data.winnerUserId.present
          ? data.winnerUserId.value
          : this.winnerUserId,
      scoresJson:
          data.scoresJson.present ? data.scoresJson.value : this.scoresJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameResult(')
          ..write('gameId: $gameId, ')
          ..write('winnerUserId: $winnerUserId, ')
          ..write('scoresJson: $scoresJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, winnerUserId, scoresJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameResult &&
          other.gameId == this.gameId &&
          other.winnerUserId == this.winnerUserId &&
          other.scoresJson == this.scoresJson &&
          other.createdAt == this.createdAt);
}

class GameResultsCompanion extends UpdateCompanion<GameResult> {
  final Value<String> gameId;
  final Value<String?> winnerUserId;
  final Value<String> scoresJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GameResultsCompanion({
    this.gameId = const Value.absent(),
    this.winnerUserId = const Value.absent(),
    this.scoresJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameResultsCompanion.insert({
    required String gameId,
    this.winnerUserId = const Value.absent(),
    required String scoresJson,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : gameId = Value(gameId),
        scoresJson = Value(scoresJson);
  static Insertable<GameResult> custom({
    Expression<String>? gameId,
    Expression<String>? winnerUserId,
    Expression<String>? scoresJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (winnerUserId != null) 'winner_user_id': winnerUserId,
      if (scoresJson != null) 'scores_json': scoresJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameResultsCompanion copyWith(
      {Value<String>? gameId,
      Value<String?>? winnerUserId,
      Value<String>? scoresJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return GameResultsCompanion(
      gameId: gameId ?? this.gameId,
      winnerUserId: winnerUserId ?? this.winnerUserId,
      scoresJson: scoresJson ?? this.scoresJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (winnerUserId.present) {
      map['winner_user_id'] = Variable<String>(winnerUserId.value);
    }
    if (scoresJson.present) {
      map['scores_json'] = Variable<String>(scoresJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameResultsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('winnerUserId: $winnerUserId, ')
          ..write('scoresJson: $scoresJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _gamesPlayedMeta =
      const VerificationMeta('gamesPlayed');
  @override
  late final GeneratedColumn<int> gamesPlayed = GeneratedColumn<int>(
      'games_played', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gamesWonMeta =
      const VerificationMeta('gamesWon');
  @override
  late final GeneratedColumn<int> gamesWon = GeneratedColumn<int>(
      'games_won', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  @override
  List<GeneratedColumn> get $columns =>
      [userId, gamesPlayed, gamesWon, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(Insertable<UserStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('games_played')) {
      context.handle(
          _gamesPlayedMeta,
          gamesPlayed.isAcceptableOrUnknown(
              data['games_played']!, _gamesPlayedMeta));
    }
    if (data.containsKey('games_won')) {
      context.handle(_gamesWonMeta,
          gamesWon.isAcceptableOrUnknown(data['games_won']!, _gamesWonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStat(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      gamesPlayed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}games_played'])!,
      gamesWon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}games_won'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }
}

class UserStat extends DataClass implements Insertable<UserStat> {
  final String userId;
  final int gamesPlayed;
  final int gamesWon;
  final DateTime updatedAt;
  const UserStat(
      {required this.userId,
      required this.gamesPlayed,
      required this.gamesWon,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['games_played'] = Variable<int>(gamesPlayed);
    map['games_won'] = Variable<int>(gamesWon);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      userId: Value(userId),
      gamesPlayed: Value(gamesPlayed),
      gamesWon: Value(gamesWon),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStat(
      userId: serializer.fromJson<String>(json['userId']),
      gamesPlayed: serializer.fromJson<int>(json['gamesPlayed']),
      gamesWon: serializer.fromJson<int>(json['gamesWon']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'gamesPlayed': serializer.toJson<int>(gamesPlayed),
      'gamesWon': serializer.toJson<int>(gamesWon),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserStat copyWith(
          {String? userId,
          int? gamesPlayed,
          int? gamesWon,
          DateTime? updatedAt}) =>
      UserStat(
        userId: userId ?? this.userId,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        gamesWon: gamesWon ?? this.gamesWon,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserStat copyWithCompanion(UserStatsCompanion data) {
    return UserStat(
      userId: data.userId.present ? data.userId.value : this.userId,
      gamesPlayed:
          data.gamesPlayed.present ? data.gamesPlayed.value : this.gamesPlayed,
      gamesWon: data.gamesWon.present ? data.gamesWon.value : this.gamesWon,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStat(')
          ..write('userId: $userId, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('gamesWon: $gamesWon, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, gamesPlayed, gamesWon, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStat &&
          other.userId == this.userId &&
          other.gamesPlayed == this.gamesPlayed &&
          other.gamesWon == this.gamesWon &&
          other.updatedAt == this.updatedAt);
}

class UserStatsCompanion extends UpdateCompanion<UserStat> {
  final Value<String> userId;
  final Value<int> gamesPlayed;
  final Value<int> gamesWon;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserStatsCompanion({
    this.userId = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.gamesWon = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStatsCompanion.insert({
    required String userId,
    this.gamesPlayed = const Value.absent(),
    this.gamesWon = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserStat> custom({
    Expression<String>? userId,
    Expression<int>? gamesPlayed,
    Expression<int>? gamesWon,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (gamesPlayed != null) 'games_played': gamesPlayed,
      if (gamesWon != null) 'games_won': gamesWon,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStatsCompanion copyWith(
      {Value<String>? userId,
      Value<int>? gamesPlayed,
      Value<int>? gamesWon,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserStatsCompanion(
      userId: userId ?? this.userId,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (gamesPlayed.present) {
      map['games_played'] = Variable<int>(gamesPlayed.value);
    }
    if (gamesWon.present) {
      map['games_won'] = Variable<int>(gamesWon.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('userId: $userId, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('gamesWon: $gamesWon, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuidGen.v4());
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromUserIdMeta =
      const VerificationMeta('fromUserId');
  @override
  late final GeneratedColumn<String> fromUserId = GeneratedColumn<String>(
      'from_user_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES users (id) ON DELETE CASCADE'));
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
      'game_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES games (id) ON DELETE CASCADE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toUtc());
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, type, fromUserId, gameId, status, createdAt, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<Notification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('from_user_id')) {
      context.handle(
          _fromUserIdMeta,
          fromUserId.isAcceptableOrUnknown(
              data['from_user_id']!, _fromUserIdMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(_gameIdMeta,
          gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      fromUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_user_id']),
      gameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final String id;
  final String userId;
  final String type;
  final String? fromUserId;
  final String? gameId;
  final String status;
  final DateTime createdAt;
  final DateTime? readAt;
  const Notification(
      {required this.id,
      required this.userId,
      required this.type,
      this.fromUserId,
      this.gameId,
      required this.status,
      required this.createdAt,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || fromUserId != null) {
      map['from_user_id'] = Variable<String>(fromUserId);
    }
    if (!nullToAbsent || gameId != null) {
      map['game_id'] = Variable<String>(gameId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      fromUserId: fromUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromUserId),
      gameId:
          gameId == null && nullToAbsent ? const Value.absent() : Value(gameId),
      status: Value(status),
      createdAt: Value(createdAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      fromUserId: serializer.fromJson<String?>(json['fromUserId']),
      gameId: serializer.fromJson<String?>(json['gameId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'fromUserId': serializer.toJson<String?>(fromUserId),
      'gameId': serializer.toJson<String?>(gameId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  Notification copyWith(
          {String? id,
          String? userId,
          String? type,
          Value<String?> fromUserId = const Value.absent(),
          Value<String?> gameId = const Value.absent(),
          String? status,
          DateTime? createdAt,
          Value<DateTime?> readAt = const Value.absent()}) =>
      Notification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        fromUserId: fromUserId.present ? fromUserId.value : this.fromUserId,
        gameId: gameId.present ? gameId.value : this.gameId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      fromUserId:
          data.fromUserId.present ? data.fromUserId.value : this.fromUserId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('gameId: $gameId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, type, fromUserId, gameId, status, createdAt, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.fromUserId == this.fromUserId &&
          other.gameId == this.gameId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String?> fromUserId;
  final Value<String?> gameId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String type,
    this.fromUserId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        type = Value(type);
  static Insertable<Notification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? fromUserId,
    Expression<String>? gameId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (gameId != null) 'game_id': gameId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? type,
      Value<String?>? fromUserId,
      Value<String?>? gameId,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime?>? readAt,
      Value<int>? rowid}) {
    return NotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      gameId: gameId ?? this.gameId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (fromUserId.present) {
      map['from_user_id'] = Variable<String>(fromUserId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('gameId: $gameId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $EmailTokensTable emailTokens = $EmailTokensTable(this);
  late final $RefreshTokensTable refreshTokens = $RefreshTokensTable(this);
  late final $FriendshipsTable friendships = $FriendshipsTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $GamePlayersTable gamePlayers = $GamePlayersTable(this);
  late final $GameEventsTable gameEvents = $GameEventsTable(this);
  late final $GameSnapshotsTable gameSnapshots = $GameSnapshotsTable(this);
  late final $GameResultsTable gameResults = $GameResultsTable(this);
  late final $UserStatsTable userStats = $UserStatsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        emailTokens,
        refreshTokens,
        friendships,
        games,
        gamePlayers,
        gameEvents,
        gameSnapshots,
        gameResults,
        userStats,
        notifications
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('email_tokens', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('refresh_tokens', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('friendships', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('friendships', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('games',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('game_players', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('game_players', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('games',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('game_events', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('games',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('game_snapshots', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('games',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('game_results', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('user_stats', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('notifications', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('users',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('notifications', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('games',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('notifications', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  required String email,
  required String passwordHash,
  required String username,
  required String displayName,
  Value<String?> avatarUrl,
  Value<DateTime?> emailVerifiedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> passwordHash,
  Value<String> username,
  Value<String> displayName,
  Value<String?> avatarUrl,
  Value<DateTime?> emailVerifiedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EmailTokensTable, List<EmailToken>>
      _emailTokensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.emailTokens,
          aliasName: $_aliasNameGenerator(db.users.id, db.emailTokens.userId));

  $$EmailTokensTableProcessedTableManager get emailTokensRefs {
    final manager = $$EmailTokensTableTableManager($_db, $_db.emailTokens)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_emailTokensRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RefreshTokensTable, List<RefreshToken>>
      _refreshTokensRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.refreshTokens,
              aliasName:
                  $_aliasNameGenerator(db.users.id, db.refreshTokens.userId));

  $$RefreshTokensTableProcessedTableManager get refreshTokensRefs {
    final manager = $$RefreshTokensTableTableManager($_db, $_db.refreshTokens)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_refreshTokensRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GamesTable, List<Game>> _gamesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.games,
          aliasName: $_aliasNameGenerator(db.users.id, db.games.createdBy));

  $$GamesTableProcessedTableManager get gamesRefs {
    final manager = $$GamesTableTableManager($_db, $_db.games)
        .filter((f) => f.createdBy.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GamePlayersTable, List<GamePlayer>>
      _gamePlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.gamePlayers,
          aliasName: $_aliasNameGenerator(db.users.id, db.gamePlayers.userId));

  $$GamePlayersTableProcessedTableManager get gamePlayersRefs {
    final manager = $$GamePlayersTableTableManager($_db, $_db.gamePlayers)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlayersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GameResultsTable, List<GameResult>>
      _gameResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.gameResults,
          aliasName:
              $_aliasNameGenerator(db.users.id, db.gameResults.winnerUserId));

  $$GameResultsTableProcessedTableManager get gameResultsRefs {
    final manager = $$GameResultsTableTableManager($_db, $_db.gameResults)
        .filter(
            (f) => f.winnerUserId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameResultsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserStatsTable, List<UserStat>>
      _userStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userStats,
          aliasName: $_aliasNameGenerator(db.users.id, db.userStats.userId));

  $$UserStatsTableProcessedTableManager get userStatsRefs {
    final manager = $$UserStatsTableTableManager($_db, $_db.userStats)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userStatsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get emailVerifiedAt => $composableBuilder(
      column: $table.emailVerifiedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> emailTokensRefs(
      Expression<bool> Function($$EmailTokensTableFilterComposer f) f) {
    final $$EmailTokensTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.emailTokens,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmailTokensTableFilterComposer(
              $db: $db,
              $table: $db.emailTokens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> refreshTokensRefs(
      Expression<bool> Function($$RefreshTokensTableFilterComposer f) f) {
    final $$RefreshTokensTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.refreshTokens,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RefreshTokensTableFilterComposer(
              $db: $db,
              $table: $db.refreshTokens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gamesRefs(
      Expression<bool> Function($$GamesTableFilterComposer f) f) {
    final $$GamesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableFilterComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gamePlayersRefs(
      Expression<bool> Function($$GamePlayersTableFilterComposer f) f) {
    final $$GamePlayersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gamePlayers,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamePlayersTableFilterComposer(
              $db: $db,
              $table: $db.gamePlayers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gameResultsRefs(
      Expression<bool> Function($$GameResultsTableFilterComposer f) f) {
    final $$GameResultsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameResults,
        getReferencedColumn: (t) => t.winnerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameResultsTableFilterComposer(
              $db: $db,
              $table: $db.gameResults,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> userStatsRefs(
      Expression<bool> Function($$UserStatsTableFilterComposer f) f) {
    final $$UserStatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userStats,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserStatsTableFilterComposer(
              $db: $db,
              $table: $db.userStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get emailVerifiedAt => $composableBuilder(
      column: $table.emailVerifiedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get emailVerifiedAt => $composableBuilder(
      column: $table.emailVerifiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> emailTokensRefs<T extends Object>(
      Expression<T> Function($$EmailTokensTableAnnotationComposer a) f) {
    final $$EmailTokensTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.emailTokens,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EmailTokensTableAnnotationComposer(
              $db: $db,
              $table: $db.emailTokens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> refreshTokensRefs<T extends Object>(
      Expression<T> Function($$RefreshTokensTableAnnotationComposer a) f) {
    final $$RefreshTokensTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.refreshTokens,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RefreshTokensTableAnnotationComposer(
              $db: $db,
              $table: $db.refreshTokens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gamesRefs<T extends Object>(
      Expression<T> Function($$GamesTableAnnotationComposer a) f) {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.createdBy,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableAnnotationComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gamePlayersRefs<T extends Object>(
      Expression<T> Function($$GamePlayersTableAnnotationComposer a) f) {
    final $$GamePlayersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gamePlayers,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamePlayersTableAnnotationComposer(
              $db: $db,
              $table: $db.gamePlayers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gameResultsRefs<T extends Object>(
      Expression<T> Function($$GameResultsTableAnnotationComposer a) f) {
    final $$GameResultsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameResults,
        getReferencedColumn: (t) => t.winnerUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameResultsTableAnnotationComposer(
              $db: $db,
              $table: $db.gameResults,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> userStatsRefs<T extends Object>(
      Expression<T> Function($$UserStatsTableAnnotationComposer a) f) {
    final $$UserStatsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userStats,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserStatsTableAnnotationComposer(
              $db: $db,
              $table: $db.userStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool emailTokensRefs,
        bool refreshTokensRefs,
        bool gamesRefs,
        bool gamePlayersRefs,
        bool gameResultsRefs,
        bool userStatsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime?> emailVerifiedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            passwordHash: passwordHash,
            username: username,
            displayName: displayName,
            avatarUrl: avatarUrl,
            emailVerifiedAt: emailVerifiedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String email,
            required String passwordHash,
            required String username,
            required String displayName,
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime?> emailVerifiedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            passwordHash: passwordHash,
            username: username,
            displayName: displayName,
            avatarUrl: avatarUrl,
            emailVerifiedAt: emailVerifiedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {emailTokensRefs = false,
              refreshTokensRefs = false,
              gamesRefs = false,
              gamePlayersRefs = false,
              gameResultsRefs = false,
              userStatsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (emailTokensRefs) db.emailTokens,
                if (refreshTokensRefs) db.refreshTokens,
                if (gamesRefs) db.games,
                if (gamePlayersRefs) db.gamePlayers,
                if (gameResultsRefs) db.gameResults,
                if (userStatsRefs) db.userStats
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (emailTokensRefs)
                    await $_getPrefetchedData<User, $UsersTable, EmailToken>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._emailTokensRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .emailTokensRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (refreshTokensRefs)
                    await $_getPrefetchedData<User, $UsersTable, RefreshToken>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._refreshTokensRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .refreshTokensRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (gamesRefs)
                    await $_getPrefetchedData<User, $UsersTable, Game>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._gamesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).gamesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.createdBy == item.id),
                        typedResults: items),
                  if (gamePlayersRefs)
                    await $_getPrefetchedData<User, $UsersTable, GamePlayer>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._gamePlayersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .gamePlayersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (gameResultsRefs)
                    await $_getPrefetchedData<User, $UsersTable, GameResult>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._gameResultsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .gameResultsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.winnerUserId == item.id),
                        typedResults: items),
                  if (userStatsRefs)
                    await $_getPrefetchedData<User, $UsersTable, UserStat>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._userStatsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).userStatsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool emailTokensRefs,
        bool refreshTokensRefs,
        bool gamesRefs,
        bool gamePlayersRefs,
        bool gameResultsRefs,
        bool userStatsRefs})>;
typedef $$EmailTokensTableCreateCompanionBuilder = EmailTokensCompanion
    Function({
  Value<String> id,
  required String userId,
  required String type,
  required String tokenHash,
  required DateTime expiresAt,
  Value<DateTime?> usedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$EmailTokensTableUpdateCompanionBuilder = EmailTokensCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> type,
  Value<String> tokenHash,
  Value<DateTime> expiresAt,
  Value<DateTime?> usedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$EmailTokensTableReferences
    extends BaseReferences<_$AppDatabase, $EmailTokensTable, EmailToken> {
  $$EmailTokensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.emailTokens.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EmailTokensTableFilterComposer
    extends Composer<_$AppDatabase, $EmailTokensTable> {
  $$EmailTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmailTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $EmailTokensTable> {
  $$EmailTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get usedAt => $composableBuilder(
      column: $table.usedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmailTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmailTokensTable> {
  $$EmailTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EmailTokensTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmailTokensTable,
    EmailToken,
    $$EmailTokensTableFilterComposer,
    $$EmailTokensTableOrderingComposer,
    $$EmailTokensTableAnnotationComposer,
    $$EmailTokensTableCreateCompanionBuilder,
    $$EmailTokensTableUpdateCompanionBuilder,
    (EmailToken, $$EmailTokensTableReferences),
    EmailToken,
    PrefetchHooks Function({bool userId})> {
  $$EmailTokensTableTableManager(_$AppDatabase db, $EmailTokensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmailTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmailTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmailTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> tokenHash = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<DateTime?> usedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmailTokensCompanion(
            id: id,
            userId: userId,
            type: type,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            usedAt: usedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String userId,
            required String type,
            required String tokenHash,
            required DateTime expiresAt,
            Value<DateTime?> usedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EmailTokensCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            usedAt: usedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EmailTokensTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$EmailTokensTableReferences._userIdTable(db),
                    referencedColumn:
                        $$EmailTokensTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EmailTokensTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EmailTokensTable,
    EmailToken,
    $$EmailTokensTableFilterComposer,
    $$EmailTokensTableOrderingComposer,
    $$EmailTokensTableAnnotationComposer,
    $$EmailTokensTableCreateCompanionBuilder,
    $$EmailTokensTableUpdateCompanionBuilder,
    (EmailToken, $$EmailTokensTableReferences),
    EmailToken,
    PrefetchHooks Function({bool userId})>;
typedef $$RefreshTokensTableCreateCompanionBuilder = RefreshTokensCompanion
    Function({
  Value<String> id,
  required String userId,
  required String tokenHash,
  required DateTime expiresAt,
  Value<DateTime?> revokedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$RefreshTokensTableUpdateCompanionBuilder = RefreshTokensCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> tokenHash,
  Value<DateTime> expiresAt,
  Value<DateTime?> revokedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$RefreshTokensTableReferences
    extends BaseReferences<_$AppDatabase, $RefreshTokensTable, RefreshToken> {
  $$RefreshTokensTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.refreshTokens.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RefreshTokensTableFilterComposer
    extends Composer<_$AppDatabase, $RefreshTokensTable> {
  $$RefreshTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
      column: $table.revokedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RefreshTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $RefreshTokensTable> {
  $$RefreshTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tokenHash => $composableBuilder(
      column: $table.tokenHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
      column: $table.revokedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RefreshTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefreshTokensTable> {
  $$RefreshTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RefreshTokensTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RefreshTokensTable,
    RefreshToken,
    $$RefreshTokensTableFilterComposer,
    $$RefreshTokensTableOrderingComposer,
    $$RefreshTokensTableAnnotationComposer,
    $$RefreshTokensTableCreateCompanionBuilder,
    $$RefreshTokensTableUpdateCompanionBuilder,
    (RefreshToken, $$RefreshTokensTableReferences),
    RefreshToken,
    PrefetchHooks Function({bool userId})> {
  $$RefreshTokensTableTableManager(_$AppDatabase db, $RefreshTokensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefreshTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefreshTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefreshTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> tokenHash = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<DateTime?> revokedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RefreshTokensCompanion(
            id: id,
            userId: userId,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            revokedAt: revokedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String userId,
            required String tokenHash,
            required DateTime expiresAt,
            Value<DateTime?> revokedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RefreshTokensCompanion.insert(
            id: id,
            userId: userId,
            tokenHash: tokenHash,
            expiresAt: expiresAt,
            revokedAt: revokedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RefreshTokensTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$RefreshTokensTableReferences._userIdTable(db),
                    referencedColumn:
                        $$RefreshTokensTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RefreshTokensTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RefreshTokensTable,
    RefreshToken,
    $$RefreshTokensTableFilterComposer,
    $$RefreshTokensTableOrderingComposer,
    $$RefreshTokensTableAnnotationComposer,
    $$RefreshTokensTableCreateCompanionBuilder,
    $$RefreshTokensTableUpdateCompanionBuilder,
    (RefreshToken, $$RefreshTokensTableReferences),
    RefreshToken,
    PrefetchHooks Function({bool userId})>;
typedef $$FriendshipsTableCreateCompanionBuilder = FriendshipsCompanion
    Function({
  required String userId,
  required String friendId,
  required String status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$FriendshipsTableUpdateCompanionBuilder = FriendshipsCompanion
    Function({
  Value<String> userId,
  Value<String> friendId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$FriendshipsTableReferences
    extends BaseReferences<_$AppDatabase, $FriendshipsTable, Friendship> {
  $$FriendshipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.friendships.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _friendIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.friendships.friendId, db.users.id));

  $$UsersTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FriendshipsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendshipsTable> {
  $$FriendshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get friendId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.friendId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FriendshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendshipsTable> {
  $$FriendshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get friendId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.friendId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FriendshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendshipsTable> {
  $$FriendshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get friendId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.friendId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FriendshipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendshipsTable,
    Friendship,
    $$FriendshipsTableFilterComposer,
    $$FriendshipsTableOrderingComposer,
    $$FriendshipsTableAnnotationComposer,
    $$FriendshipsTableCreateCompanionBuilder,
    $$FriendshipsTableUpdateCompanionBuilder,
    (Friendship, $$FriendshipsTableReferences),
    Friendship,
    PrefetchHooks Function({bool userId, bool friendId})> {
  $$FriendshipsTableTableManager(_$AppDatabase db, $FriendshipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> friendId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendshipsCompanion(
            userId: userId,
            friendId: friendId,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String friendId,
            required String status,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendshipsCompanion.insert(
            userId: userId,
            friendId: friendId,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FriendshipsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false, friendId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$FriendshipsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$FriendshipsTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (friendId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.friendId,
                    referencedTable:
                        $$FriendshipsTableReferences._friendIdTable(db),
                    referencedColumn:
                        $$FriendshipsTableReferences._friendIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FriendshipsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FriendshipsTable,
    Friendship,
    $$FriendshipsTableFilterComposer,
    $$FriendshipsTableOrderingComposer,
    $$FriendshipsTableAnnotationComposer,
    $$FriendshipsTableCreateCompanionBuilder,
    $$FriendshipsTableUpdateCompanionBuilder,
    (Friendship, $$FriendshipsTableReferences),
    Friendship,
    PrefetchHooks Function({bool userId, bool friendId})>;
typedef $$GamesTableCreateCompanionBuilder = GamesCompanion Function({
  Value<String> id,
  required String status,
  required String createdBy,
  Value<int> maxPlayers,
  Value<DateTime> createdAt,
  Value<DateTime?> finishedAt,
  Value<int> rowid,
});
typedef $$GamesTableUpdateCompanionBuilder = GamesCompanion Function({
  Value<String> id,
  Value<String> status,
  Value<String> createdBy,
  Value<int> maxPlayers,
  Value<DateTime> createdAt,
  Value<DateTime?> finishedAt,
  Value<int> rowid,
});

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _createdByTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.games.createdBy, db.users.id));

  $$UsersTableProcessedTableManager get createdBy {
    final $_column = $_itemColumn<String>('created_by')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$GamePlayersTable, List<GamePlayer>>
      _gamePlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.gamePlayers,
          aliasName: $_aliasNameGenerator(db.games.id, db.gamePlayers.gameId));

  $$GamePlayersTableProcessedTableManager get gamePlayersRefs {
    final manager = $$GamePlayersTableTableManager($_db, $_db.gamePlayers)
        .filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamePlayersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GameEventsTable, List<GameEvent>>
      _gameEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.gameEvents,
          aliasName: $_aliasNameGenerator(db.games.id, db.gameEvents.gameId));

  $$GameEventsTableProcessedTableManager get gameEventsRefs {
    final manager = $$GameEventsTableTableManager($_db, $_db.gameEvents)
        .filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GameSnapshotsTable, List<GameSnapshot>>
      _gameSnapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.gameSnapshots,
              aliasName:
                  $_aliasNameGenerator(db.games.id, db.gameSnapshots.gameId));

  $$GameSnapshotsTableProcessedTableManager get gameSnapshotsRefs {
    final manager = $$GameSnapshotsTableTableManager($_db, $_db.gameSnapshots)
        .filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameSnapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GameResultsTable, List<GameResult>>
      _gameResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.gameResults,
          aliasName: $_aliasNameGenerator(db.games.id, db.gameResults.gameId));

  $$GameResultsTableProcessedTableManager get gameResultsRefs {
    final manager = $$GameResultsTableTableManager($_db, $_db.gameResults)
        .filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameResultsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotificationsTable, List<Notification>>
      _notificationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.notifications,
              aliasName:
                  $_aliasNameGenerator(db.games.id, db.notifications.gameId));

  $$NotificationsTableProcessedTableManager get notificationsRefs {
    final manager = $$NotificationsTableTableManager($_db, $_db.notifications)
        .filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notificationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxPlayers => $composableBuilder(
      column: $table.maxPlayers, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get createdBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> gamePlayersRefs(
      Expression<bool> Function($$GamePlayersTableFilterComposer f) f) {
    final $$GamePlayersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gamePlayers,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamePlayersTableFilterComposer(
              $db: $db,
              $table: $db.gamePlayers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gameEventsRefs(
      Expression<bool> Function($$GameEventsTableFilterComposer f) f) {
    final $$GameEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameEvents,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameEventsTableFilterComposer(
              $db: $db,
              $table: $db.gameEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gameSnapshotsRefs(
      Expression<bool> Function($$GameSnapshotsTableFilterComposer f) f) {
    final $$GameSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameSnapshots,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.gameSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gameResultsRefs(
      Expression<bool> Function($$GameResultsTableFilterComposer f) f) {
    final $$GameResultsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameResults,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameResultsTableFilterComposer(
              $db: $db,
              $table: $db.gameResults,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notificationsRefs(
      Expression<bool> Function($$NotificationsTableFilterComposer f) f) {
    final $$NotificationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notifications,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotificationsTableFilterComposer(
              $db: $db,
              $table: $db.notifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxPlayers => $composableBuilder(
      column: $table.maxPlayers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get createdBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get maxPlayers => $composableBuilder(
      column: $table.maxPlayers, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get createdBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.createdBy,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> gamePlayersRefs<T extends Object>(
      Expression<T> Function($$GamePlayersTableAnnotationComposer a) f) {
    final $$GamePlayersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gamePlayers,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamePlayersTableAnnotationComposer(
              $db: $db,
              $table: $db.gamePlayers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gameEventsRefs<T extends Object>(
      Expression<T> Function($$GameEventsTableAnnotationComposer a) f) {
    final $$GameEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameEvents,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.gameEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gameSnapshotsRefs<T extends Object>(
      Expression<T> Function($$GameSnapshotsTableAnnotationComposer a) f) {
    final $$GameSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameSnapshots,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.gameSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gameResultsRefs<T extends Object>(
      Expression<T> Function($$GameResultsTableAnnotationComposer a) f) {
    final $$GameResultsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameResults,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameResultsTableAnnotationComposer(
              $db: $db,
              $table: $db.gameResults,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notificationsRefs<T extends Object>(
      Expression<T> Function($$NotificationsTableAnnotationComposer a) f) {
    final $$NotificationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notifications,
        getReferencedColumn: (t) => t.gameId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotificationsTableAnnotationComposer(
              $db: $db,
              $table: $db.notifications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GamesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GamesTable,
    Game,
    $$GamesTableFilterComposer,
    $$GamesTableOrderingComposer,
    $$GamesTableAnnotationComposer,
    $$GamesTableCreateCompanionBuilder,
    $$GamesTableUpdateCompanionBuilder,
    (Game, $$GamesTableReferences),
    Game,
    PrefetchHooks Function(
        {bool createdBy,
        bool gamePlayersRefs,
        bool gameEventsRefs,
        bool gameSnapshotsRefs,
        bool gameResultsRefs,
        bool notificationsRefs})> {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<int> maxPlayers = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GamesCompanion(
            id: id,
            status: status,
            createdBy: createdBy,
            maxPlayers: maxPlayers,
            createdAt: createdAt,
            finishedAt: finishedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String status,
            required String createdBy,
            Value<int> maxPlayers = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GamesCompanion.insert(
            id: id,
            status: status,
            createdBy: createdBy,
            maxPlayers: maxPlayers,
            createdAt: createdAt,
            finishedAt: finishedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GamesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {createdBy = false,
              gamePlayersRefs = false,
              gameEventsRefs = false,
              gameSnapshotsRefs = false,
              gameResultsRefs = false,
              notificationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gamePlayersRefs) db.gamePlayers,
                if (gameEventsRefs) db.gameEvents,
                if (gameSnapshotsRefs) db.gameSnapshots,
                if (gameResultsRefs) db.gameResults,
                if (notificationsRefs) db.notifications
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (createdBy) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.createdBy,
                    referencedTable: $$GamesTableReferences._createdByTable(db),
                    referencedColumn:
                        $$GamesTableReferences._createdByTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gamePlayersRefs)
                    await $_getPrefetchedData<Game, $GamesTable, GamePlayer>(
                        currentTable: table,
                        referencedTable:
                            $$GamesTableReferences._gamePlayersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GamesTableReferences(db, table, p0)
                                .gamePlayersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.gameId == item.id),
                        typedResults: items),
                  if (gameEventsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, GameEvent>(
                        currentTable: table,
                        referencedTable:
                            $$GamesTableReferences._gameEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GamesTableReferences(db, table, p0)
                                .gameEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.gameId == item.id),
                        typedResults: items),
                  if (gameSnapshotsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, GameSnapshot>(
                        currentTable: table,
                        referencedTable:
                            $$GamesTableReferences._gameSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GamesTableReferences(db, table, p0)
                                .gameSnapshotsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.gameId == item.id),
                        typedResults: items),
                  if (gameResultsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, GameResult>(
                        currentTable: table,
                        referencedTable:
                            $$GamesTableReferences._gameResultsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GamesTableReferences(db, table, p0)
                                .gameResultsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.gameId == item.id),
                        typedResults: items),
                  if (notificationsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, Notification>(
                        currentTable: table,
                        referencedTable:
                            $$GamesTableReferences._notificationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GamesTableReferences(db, table, p0)
                                .notificationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.gameId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GamesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GamesTable,
    Game,
    $$GamesTableFilterComposer,
    $$GamesTableOrderingComposer,
    $$GamesTableAnnotationComposer,
    $$GamesTableCreateCompanionBuilder,
    $$GamesTableUpdateCompanionBuilder,
    (Game, $$GamesTableReferences),
    Game,
    PrefetchHooks Function(
        {bool createdBy,
        bool gamePlayersRefs,
        bool gameEventsRefs,
        bool gameSnapshotsRefs,
        bool gameResultsRefs,
        bool notificationsRefs})>;
typedef $$GamePlayersTableCreateCompanionBuilder = GamePlayersCompanion
    Function({
  required String gameId,
  required String userId,
  required int seat,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});
typedef $$GamePlayersTableUpdateCompanionBuilder = GamePlayersCompanion
    Function({
  Value<String> gameId,
  Value<String> userId,
  Value<int> seat,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});

final class $$GamePlayersTableReferences
    extends BaseReferences<_$AppDatabase, $GamePlayersTable, GamePlayer> {
  $$GamePlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games
      .createAlias($_aliasNameGenerator(db.gamePlayers.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager($_db, $_db.games)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.gamePlayers.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GamePlayersTableFilterComposer
    extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seat => $composableBuilder(
      column: $table.seat, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableFilterComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GamePlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seat => $composableBuilder(
      column: $table.seat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableOrderingComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GamePlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamePlayersTable> {
  $$GamePlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableAnnotationComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GamePlayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GamePlayersTable,
    GamePlayer,
    $$GamePlayersTableFilterComposer,
    $$GamePlayersTableOrderingComposer,
    $$GamePlayersTableAnnotationComposer,
    $$GamePlayersTableCreateCompanionBuilder,
    $$GamePlayersTableUpdateCompanionBuilder,
    (GamePlayer, $$GamePlayersTableReferences),
    GamePlayer,
    PrefetchHooks Function({bool gameId, bool userId})> {
  $$GamePlayersTableTableManager(_$AppDatabase db, $GamePlayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamePlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamePlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamePlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> gameId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> seat = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GamePlayersCompanion(
            gameId: gameId,
            userId: userId,
            seat: seat,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String gameId,
            required String userId,
            required int seat,
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GamePlayersCompanion.insert(
            gameId: gameId,
            userId: userId,
            seat: seat,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GamePlayersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({gameId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (gameId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gameId,
                    referencedTable:
                        $$GamePlayersTableReferences._gameIdTable(db),
                    referencedColumn:
                        $$GamePlayersTableReferences._gameIdTable(db).id,
                  ) as T;
                }
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$GamePlayersTableReferences._userIdTable(db),
                    referencedColumn:
                        $$GamePlayersTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GamePlayersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GamePlayersTable,
    GamePlayer,
    $$GamePlayersTableFilterComposer,
    $$GamePlayersTableOrderingComposer,
    $$GamePlayersTableAnnotationComposer,
    $$GamePlayersTableCreateCompanionBuilder,
    $$GamePlayersTableUpdateCompanionBuilder,
    (GamePlayer, $$GamePlayersTableReferences),
    GamePlayer,
    PrefetchHooks Function({bool gameId, bool userId})>;
typedef $$GameEventsTableCreateCompanionBuilder = GameEventsCompanion Function({
  required String gameId,
  required int serverSeq,
  required String type,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$GameEventsTableUpdateCompanionBuilder = GameEventsCompanion Function({
  Value<String> gameId,
  Value<int> serverSeq,
  Value<String> type,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$GameEventsTableReferences
    extends BaseReferences<_$AppDatabase, $GameEventsTable, GameEvent> {
  $$GameEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games
      .createAlias($_aliasNameGenerator(db.gameEvents.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager($_db, $_db.games)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GameEventsTableFilterComposer
    extends Composer<_$AppDatabase, $GameEventsTable> {
  $$GameEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableFilterComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameEventsTable> {
  $$GameEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableOrderingComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameEventsTable> {
  $$GameEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableAnnotationComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GameEventsTable,
    GameEvent,
    $$GameEventsTableFilterComposer,
    $$GameEventsTableOrderingComposer,
    $$GameEventsTableAnnotationComposer,
    $$GameEventsTableCreateCompanionBuilder,
    $$GameEventsTableUpdateCompanionBuilder,
    (GameEvent, $$GameEventsTableReferences),
    GameEvent,
    PrefetchHooks Function({bool gameId})> {
  $$GameEventsTableTableManager(_$AppDatabase db, $GameEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> gameId = const Value.absent(),
            Value<int> serverSeq = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameEventsCompanion(
            gameId: gameId,
            serverSeq: serverSeq,
            type: type,
            payloadJson: payloadJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String gameId,
            required int serverSeq,
            required String type,
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameEventsCompanion.insert(
            gameId: gameId,
            serverSeq: serverSeq,
            type: type,
            payloadJson: payloadJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GameEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (gameId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gameId,
                    referencedTable:
                        $$GameEventsTableReferences._gameIdTable(db),
                    referencedColumn:
                        $$GameEventsTableReferences._gameIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GameEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GameEventsTable,
    GameEvent,
    $$GameEventsTableFilterComposer,
    $$GameEventsTableOrderingComposer,
    $$GameEventsTableAnnotationComposer,
    $$GameEventsTableCreateCompanionBuilder,
    $$GameEventsTableUpdateCompanionBuilder,
    (GameEvent, $$GameEventsTableReferences),
    GameEvent,
    PrefetchHooks Function({bool gameId})>;
typedef $$GameSnapshotsTableCreateCompanionBuilder = GameSnapshotsCompanion
    Function({
  required String gameId,
  required int serverSeq,
  required String stateJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$GameSnapshotsTableUpdateCompanionBuilder = GameSnapshotsCompanion
    Function({
  Value<String> gameId,
  Value<int> serverSeq,
  Value<String> stateJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$GameSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $GameSnapshotsTable, GameSnapshot> {
  $$GameSnapshotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games
      .createAlias($_aliasNameGenerator(db.gameSnapshots.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager($_db, $_db.games)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GameSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSnapshotsTable> {
  $$GameSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateJson => $composableBuilder(
      column: $table.stateJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableFilterComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSnapshotsTable> {
  $$GameSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateJson => $composableBuilder(
      column: $table.stateJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableOrderingComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSnapshotsTable> {
  $$GameSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableAnnotationComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GameSnapshotsTable,
    GameSnapshot,
    $$GameSnapshotsTableFilterComposer,
    $$GameSnapshotsTableOrderingComposer,
    $$GameSnapshotsTableAnnotationComposer,
    $$GameSnapshotsTableCreateCompanionBuilder,
    $$GameSnapshotsTableUpdateCompanionBuilder,
    (GameSnapshot, $$GameSnapshotsTableReferences),
    GameSnapshot,
    PrefetchHooks Function({bool gameId})> {
  $$GameSnapshotsTableTableManager(_$AppDatabase db, $GameSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> gameId = const Value.absent(),
            Value<int> serverSeq = const Value.absent(),
            Value<String> stateJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameSnapshotsCompanion(
            gameId: gameId,
            serverSeq: serverSeq,
            stateJson: stateJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String gameId,
            required int serverSeq,
            required String stateJson,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameSnapshotsCompanion.insert(
            gameId: gameId,
            serverSeq: serverSeq,
            stateJson: stateJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GameSnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (gameId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gameId,
                    referencedTable:
                        $$GameSnapshotsTableReferences._gameIdTable(db),
                    referencedColumn:
                        $$GameSnapshotsTableReferences._gameIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GameSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GameSnapshotsTable,
    GameSnapshot,
    $$GameSnapshotsTableFilterComposer,
    $$GameSnapshotsTableOrderingComposer,
    $$GameSnapshotsTableAnnotationComposer,
    $$GameSnapshotsTableCreateCompanionBuilder,
    $$GameSnapshotsTableUpdateCompanionBuilder,
    (GameSnapshot, $$GameSnapshotsTableReferences),
    GameSnapshot,
    PrefetchHooks Function({bool gameId})>;
typedef $$GameResultsTableCreateCompanionBuilder = GameResultsCompanion
    Function({
  required String gameId,
  Value<String?> winnerUserId,
  required String scoresJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$GameResultsTableUpdateCompanionBuilder = GameResultsCompanion
    Function({
  Value<String> gameId,
  Value<String?> winnerUserId,
  Value<String> scoresJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$GameResultsTableReferences
    extends BaseReferences<_$AppDatabase, $GameResultsTable, GameResult> {
  $$GameResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games
      .createAlias($_aliasNameGenerator(db.gameResults.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager($_db, $_db.games)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _winnerUserIdTable(_$AppDatabase db) =>
      db.users.createAlias(
          $_aliasNameGenerator(db.gameResults.winnerUserId, db.users.id));

  $$UsersTableProcessedTableManager? get winnerUserId {
    final $_column = $_itemColumn<String>('winner_user_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GameResultsTableFilterComposer
    extends Composer<_$AppDatabase, $GameResultsTable> {
  $$GameResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scoresJson => $composableBuilder(
      column: $table.scoresJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableFilterComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get winnerUserId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.winnerUserId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameResultsTable> {
  $$GameResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scoresJson => $composableBuilder(
      column: $table.scoresJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableOrderingComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get winnerUserId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.winnerUserId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameResultsTable> {
  $$GameResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scoresJson => $composableBuilder(
      column: $table.scoresJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableAnnotationComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get winnerUserId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.winnerUserId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameResultsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GameResultsTable,
    GameResult,
    $$GameResultsTableFilterComposer,
    $$GameResultsTableOrderingComposer,
    $$GameResultsTableAnnotationComposer,
    $$GameResultsTableCreateCompanionBuilder,
    $$GameResultsTableUpdateCompanionBuilder,
    (GameResult, $$GameResultsTableReferences),
    GameResult,
    PrefetchHooks Function({bool gameId, bool winnerUserId})> {
  $$GameResultsTableTableManager(_$AppDatabase db, $GameResultsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> gameId = const Value.absent(),
            Value<String?> winnerUserId = const Value.absent(),
            Value<String> scoresJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameResultsCompanion(
            gameId: gameId,
            winnerUserId: winnerUserId,
            scoresJson: scoresJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String gameId,
            Value<String?> winnerUserId = const Value.absent(),
            required String scoresJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameResultsCompanion.insert(
            gameId: gameId,
            winnerUserId: winnerUserId,
            scoresJson: scoresJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GameResultsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({gameId = false, winnerUserId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (gameId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gameId,
                    referencedTable:
                        $$GameResultsTableReferences._gameIdTable(db),
                    referencedColumn:
                        $$GameResultsTableReferences._gameIdTable(db).id,
                  ) as T;
                }
                if (winnerUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.winnerUserId,
                    referencedTable:
                        $$GameResultsTableReferences._winnerUserIdTable(db),
                    referencedColumn:
                        $$GameResultsTableReferences._winnerUserIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GameResultsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GameResultsTable,
    GameResult,
    $$GameResultsTableFilterComposer,
    $$GameResultsTableOrderingComposer,
    $$GameResultsTableAnnotationComposer,
    $$GameResultsTableCreateCompanionBuilder,
    $$GameResultsTableUpdateCompanionBuilder,
    (GameResult, $$GameResultsTableReferences),
    GameResult,
    PrefetchHooks Function({bool gameId, bool winnerUserId})>;
typedef $$UserStatsTableCreateCompanionBuilder = UserStatsCompanion Function({
  required String userId,
  Value<int> gamesPlayed,
  Value<int> gamesWon,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UserStatsTableUpdateCompanionBuilder = UserStatsCompanion Function({
  Value<String> userId,
  Value<int> gamesPlayed,
  Value<int> gamesWon,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$UserStatsTableReferences
    extends BaseReferences<_$AppDatabase, $UserStatsTable, UserStat> {
  $$UserStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.userStats.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get gamesPlayed => $composableBuilder(
      column: $table.gamesPlayed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gamesWon => $composableBuilder(
      column: $table.gamesWon, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get gamesPlayed => $composableBuilder(
      column: $table.gamesPlayed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gamesWon => $composableBuilder(
      column: $table.gamesWon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get gamesPlayed => $composableBuilder(
      column: $table.gamesPlayed, builder: (column) => column);

  GeneratedColumn<int> get gamesWon =>
      $composableBuilder(column: $table.gamesWon, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserStatsTable,
    UserStat,
    $$UserStatsTableFilterComposer,
    $$UserStatsTableOrderingComposer,
    $$UserStatsTableAnnotationComposer,
    $$UserStatsTableCreateCompanionBuilder,
    $$UserStatsTableUpdateCompanionBuilder,
    (UserStat, $$UserStatsTableReferences),
    UserStat,
    PrefetchHooks Function({bool userId})> {
  $$UserStatsTableTableManager(_$AppDatabase db, $UserStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<int> gamesPlayed = const Value.absent(),
            Value<int> gamesWon = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStatsCompanion(
            userId: userId,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<int> gamesPlayed = const Value.absent(),
            Value<int> gamesWon = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStatsCompanion.insert(
            userId: userId,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserStatsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$UserStatsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$UserStatsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserStatsTable,
    UserStat,
    $$UserStatsTableFilterComposer,
    $$UserStatsTableOrderingComposer,
    $$UserStatsTableAnnotationComposer,
    $$UserStatsTableCreateCompanionBuilder,
    $$UserStatsTableUpdateCompanionBuilder,
    (UserStat, $$UserStatsTableReferences),
    UserStat,
    PrefetchHooks Function({bool userId})>;
typedef $$NotificationsTableCreateCompanionBuilder = NotificationsCompanion
    Function({
  Value<String> id,
  required String userId,
  required String type,
  Value<String?> fromUserId,
  Value<String?> gameId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});
typedef $$NotificationsTableUpdateCompanionBuilder = NotificationsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> type,
  Value<String?> fromUserId,
  Value<String?> gameId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});

final class $$NotificationsTableReferences
    extends BaseReferences<_$AppDatabase, $NotificationsTable, Notification> {
  $$NotificationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.notifications.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UsersTable _fromUserIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.notifications.fromUserId, db.users.id));

  $$UsersTableProcessedTableManager? get fromUserId {
    final $_column = $_itemColumn<String>('from_user_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games
      .createAlias($_aliasNameGenerator(db.notifications.gameId, db.games.id));

  $$GamesTableProcessedTableManager? get gameId {
    final $_column = $_itemColumn<String>('game_id');
    if ($_column == null) return null;
    final manager = $$GamesTableTableManager($_db, $_db.games)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableFilterComposer get fromUserId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromUserId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableFilterComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableOrderingComposer get fromUserId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromUserId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableOrderingComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UsersTableAnnotationComposer get fromUserId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromUserId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gameId,
        referencedTable: $db.games,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GamesTableAnnotationComposer(
              $db: $db,
              $table: $db.games,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (Notification, $$NotificationsTableReferences),
    Notification,
    PrefetchHooks Function({bool userId, bool fromUserId, bool gameId})> {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> fromUserId = const Value.absent(),
            Value<String?> gameId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion(
            id: id,
            userId: userId,
            type: type,
            fromUserId: fromUserId,
            gameId: gameId,
            status: status,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String userId,
            required String type,
            Value<String?> fromUserId = const Value.absent(),
            Value<String?> gameId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            fromUserId: fromUserId,
            gameId: gameId,
            status: status,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NotificationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false, fromUserId = false, gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$NotificationsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$NotificationsTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (fromUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromUserId,
                    referencedTable:
                        $$NotificationsTableReferences._fromUserIdTable(db),
                    referencedColumn:
                        $$NotificationsTableReferences._fromUserIdTable(db).id,
                  ) as T;
                }
                if (gameId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gameId,
                    referencedTable:
                        $$NotificationsTableReferences._gameIdTable(db),
                    referencedColumn:
                        $$NotificationsTableReferences._gameIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (Notification, $$NotificationsTableReferences),
    Notification,
    PrefetchHooks Function({bool userId, bool fromUserId, bool gameId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$EmailTokensTableTableManager get emailTokens =>
      $$EmailTokensTableTableManager(_db, _db.emailTokens);
  $$RefreshTokensTableTableManager get refreshTokens =>
      $$RefreshTokensTableTableManager(_db, _db.refreshTokens);
  $$FriendshipsTableTableManager get friendships =>
      $$FriendshipsTableTableManager(_db, _db.friendships);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$GamePlayersTableTableManager get gamePlayers =>
      $$GamePlayersTableTableManager(_db, _db.gamePlayers);
  $$GameEventsTableTableManager get gameEvents =>
      $$GameEventsTableTableManager(_db, _db.gameEvents);
  $$GameSnapshotsTableTableManager get gameSnapshots =>
      $$GameSnapshotsTableTableManager(_db, _db.gameSnapshots);
  $$GameResultsTableTableManager get gameResults =>
      $$GameResultsTableTableManager(_db, _db.gameResults);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
}
