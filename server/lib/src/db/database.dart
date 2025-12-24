import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuidGen = Uuid();

/// Users table
class Users extends Table {
  TextColumn get id => text().clientDefault(() => _uuidGen.v4())();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get username => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get emailVerifiedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Email verification and password reset tokens
class EmailTokens extends Table {
  TextColumn get id => text().clientDefault(() => _uuidGen.v4())();
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // 'verify' or 'reset'
  TextColumn get tokenHash => text()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get usedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Refresh tokens for JWT rotation
class RefreshTokens extends Table {
  TextColumn get id => text().clientDefault(() => _uuidGen.v4())();
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get tokenHash => text()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get revokedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Friendships between users
class Friendships extends Table {
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get friendId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text()(); // 'pending', 'accepted', 'blocked'
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {userId, friendId};
}

/// Games
class Games extends Table {
  TextColumn get id => text().clientDefault(() => _uuidGen.v4())();
  TextColumn get status => text()(); // 'lobby', 'active', 'finished'
  TextColumn get createdBy => text().references(Users, #id)();
  IntColumn get maxPlayers => integer().withDefault(const Constant(7))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Players in games
class GamePlayers extends Table {
  TextColumn get gameId => text().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get seat => integer()();
  DateTimeColumn get joinedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {gameId, userId};
}

/// Game events (append-only log)
class GameEvents extends Table {
  TextColumn get gameId => text().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get serverSeq => integer()();
  TextColumn get type => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {gameId, serverSeq};
}

/// Game snapshots (full state including hands)
class GameSnapshots extends Table {
  TextColumn get gameId => text().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get serverSeq => integer()();
  TextColumn get stateJson => text()();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// Game results
class GameResults extends Table {
  TextColumn get gameId => text().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get winnerUserId => text().nullable().references(Users, #id)();
  TextColumn get scoresJson => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// User statistics
class UserStats extends Table {
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  IntColumn get gamesPlayed => integer().withDefault(const Constant(0))();
  IntColumn get gamesWon => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Notifications for game invitations and other events
class Notifications extends Table {
  TextColumn get id => text().clientDefault(() => _uuidGen.v4())();
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // 'game_invitation', 'friend_request', etc.
  TextColumn get fromUserId => text().nullable().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get gameId => text().nullable().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'read', 'accepted', 'declined'
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Users,
  EmailTokens,
  RefreshTokens,
  Friendships,
  Games,
  GamePlayers,
  GameEvents,
  GameSnapshots,
  GameResults,
  UserStats,
  Notifications,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Handle schema migrations here
          if (from < 2) {
            await m.createTable(notifications);
          }
        },
      );

  /// Creates a database connected to PostgreSQL.
  static Future<AppDatabase> connect({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    final endpoint = pg.Endpoint(
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
    );

    final connection = await pg.Connection.open(
      endpoint,
      settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
    );

    return AppDatabase(PgDatabase.opened(connection));
  }

  /// Creates from a DATABASE_URL environment variable.
  static Future<AppDatabase> connectFromUrl(String databaseUrl) async {
    // Parse postgres://user:password@host:port/database
    final uri = Uri.parse(databaseUrl);
    return connect(
      host: uri.host,
      port: uri.port != 0 ? uri.port : 5432,
      database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'fivecrowns',
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.contains(':') ? uri.userInfo.split(':').last : '',
    );
  }
}
