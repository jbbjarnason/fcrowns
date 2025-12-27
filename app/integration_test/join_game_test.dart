import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fivecrowns_app/main.dart' as app;

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Join Game (iOS Player)', () {
    testWidgets('should join game from credentials file', (tester) async {
      // Try to read credentials from file (set by cross-platform test)
      Map<String, dynamic>? credentials;
      final credFile = File('/tmp/ios_test_credentials.json');

      if (await credFile.exists()) {
        final content = await credFile.readAsString();
        credentials = jsonDecode(content);
        print('Loaded credentials from file:');
        print('Email: ${credentials!['email']}');
        print('Game ID: ${credentials['gameId']}');
      } else {
        // Fall back to environment variables or create a new user
        print('No credentials file found, creating new user');
        final user = await createVerifiedUser();
        credentials = {
          'email': user!['email'],
          'password': user['password'],
          'gameId': null,
        };
      }

      app.main();
      await tester.pumpAndSettle();

      // Login
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), credentials['email']);
      await tester.enterText(textFields.at(1), credentials['password']);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify on games screen
      expect(find.text('My Games'), findsOneWidget);
      print('Successfully logged in and on games screen');

      // Wait for games to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap the game card
      final gameCards = find.byType(Card);
      if (gameCards.evaluate().isNotEmpty) {
        print('Found ${gameCards.evaluate().length} game cards');
        await tester.tap(gameCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('Tapped on first game card');
      } else {
        print('No game cards found');
      }

      // Keep the test running to allow interaction
      print('iOS player is now in the app');
      print('Press Ctrl+C to exit when done testing');

      // Wait for a while to allow manual testing
      await tester.pumpAndSettle(const Duration(seconds: 30));
    });

    testWidgets('should login and wait for game invite', (tester) async {
      // Create a new verified user
      final user = await createVerifiedUser();
      expect(user, isNotNull, reason: 'Failed to create verified user');

      print('');
      print('=== iOS TEST USER ===');
      print('Email: ${user!['email']}');
      print('Password: ${user['password']}');
      print('Username: ${user['username']}');
      print('');
      print('Invite this user to a game from the web interface or API');
      print('=====================');
      print('');

      app.main();
      await tester.pumpAndSettle();

      // Login
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), user['email']!);
      await tester.enterText(textFields.at(1), user['password']!);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify on games screen
      expect(find.text('My Games'), findsOneWidget);
      print('Logged in successfully, on games screen');

      // Poll for new games
      for (var i = 0; i < 30; i++) {
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final gameCards = find.byType(Card);
        final count = gameCards.evaluate().length;
        print('Polling for games... found $count game(s)');

        if (count > 0) {
          print('Game found! Entering lobby...');
          await tester.tap(gameCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          break;
        }
      }

      // Wait to allow observation
      await tester.pumpAndSettle(const Duration(seconds: 30));
    });
  });
}
