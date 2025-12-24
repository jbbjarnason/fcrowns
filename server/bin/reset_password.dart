import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dotenv/dotenv.dart';
import 'package:fivecrowns_server/src/db/database.dart';
import 'package:drift/drift.dart';

void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run bin/reset_password.dart <email> <new_password>');
    exit(1);
  }

  final email = args[0];
  final password = args[1];

  // Load environment
  final env = DotEnv();
  try {
    env.load();
  } catch (_) {}

  String getEnv(String key, [String? defaultValue]) =>
      Platform.environment[key] ?? env[key] ?? defaultValue ?? '';

  final databaseUrl = getEnv('DATABASE_URL');
  if (databaseUrl.isEmpty) {
    print('DATABASE_URL not set');
    exit(1);
  }

  final db = await AppDatabase.connectFromUrl(databaseUrl);

  // Find user
  final user = await (db.select(db.users)..where((u) => u.email.equals(email))).getSingleOrNull();
  if (user == null) {
    print('User not found: $email');
    await db.close();
    exit(1);
  }

  // Hash new password
  final hash = BCrypt.hashpw(password, BCrypt.gensalt());

  // Update password
  await (db.update(db.users)..where((u) => u.email.equals(email)))
      .write(UsersCompanion(passwordHash: Value(hash)));

  print('Password reset for $email');
  await db.close();
}
