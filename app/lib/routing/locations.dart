import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/games_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/game_lobby_screen.dart';
import '../screens/game_screen.dart';
import '../screens/stats_screen.dart';

class AuthLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => [
    '/login',
    '/signup',
    '/forgot-password',
  ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = <BeamPage>[];

    if (state.pathPatternSegments.contains('login')) {
      pages.add(const BeamPage(
        key: ValueKey('login'),
        title: 'Login',
        child: LoginScreen(),
      ));
    }

    if (state.pathPatternSegments.contains('signup')) {
      pages.add(const BeamPage(
        key: ValueKey('signup'),
        title: 'Sign Up',
        child: SignupScreen(),
      ));
    }

    if (state.pathPatternSegments.contains('forgot-password')) {
      pages.add(const BeamPage(
        key: ValueKey('forgot-password'),
        title: 'Reset Password',
        child: ForgotPasswordScreen(),
      ));
    }

    return pages;
  }
}

class GamesLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => [
    '/games',
    '/games/:gameId',
    '/games/:gameId/play',
    '/friends',
    '/stats',
  ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = <BeamPage>[];

    // Games list is always the base
    pages.add(const BeamPage(
      key: ValueKey('games'),
      title: 'Games',
      child: GamesScreen(),
    ));

    // Friends screen
    if (state.pathPatternSegments.contains('friends')) {
      pages.add(const BeamPage(
        key: ValueKey('friends'),
        title: 'Friends',
        child: FriendsScreen(),
      ));
    }

    // Stats screen
    if (state.pathPatternSegments.contains('stats')) {
      pages.add(const BeamPage(
        key: ValueKey('stats'),
        title: 'My Stats',
        child: StatsScreen(),
      ));
    }

    // Game lobby
    final gameId = state.pathParameters['gameId'];
    if (gameId != null && !state.uri.path.endsWith('/play')) {
      pages.add(BeamPage(
        key: ValueKey('game-lobby-$gameId'),
        title: 'Game Lobby',
        child: GameLobbyScreen(gameId: gameId),
      ));
    }

    // Game play
    if (gameId != null && state.uri.path.endsWith('/play')) {
      pages.add(BeamPage(
        key: ValueKey('game-play-$gameId'),
        title: 'Five Crowns',
        child: GameScreen(gameId: gameId),
      ));
    }

    return pages;
  }
}
