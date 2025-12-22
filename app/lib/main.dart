import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'routing/locations.dart';
import 'theme/app_theme.dart';

final themeProvider = ChangeNotifierProvider((ref) => ThemeProvider());

void main() {
  runApp(const ProviderScope(child: FiveCrownsApp()));
}

class FiveCrownsApp extends ConsumerStatefulWidget {
  const FiveCrownsApp({super.key});

  @override
  ConsumerState<FiveCrownsApp> createState() => _FiveCrownsAppState();
}

class _FiveCrownsAppState extends ConsumerState<FiveCrownsApp> {
  late final BeamerDelegate _routerDelegate;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();

    final locationBuilder = BeamerLocationBuilder(
      beamLocations: [
        AuthLocation(),
        GamesLocation(),
      ],
    );
    _routerDelegate = BeamerDelegate(
      initialPath: '/login',
      locationBuilder: locationBuilder.call,
      guards: [
        BeamGuard(
          pathPatterns: ['/games', '/games/*', '/friends', '/stats'],
          check: (context, location) {
            final auth = ref.read(authProvider);
            return auth.state == AuthState.authenticated;
          },
          beamToNamed: (origin, target) => '/login',
        ),
        BeamGuard(
          pathPatterns: ['/login', '/signup', '/forgot-password'],
          check: (context, location) {
            final auth = ref.read(authProvider);
            return auth.state != AuthState.authenticated;
          },
          beamToNamed: (origin, target) => '/games',
        ),
      ],
    );

    // Store reference to auth provider before adding listener
    _authProvider = ref.read(authProvider);
    _authProvider!.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final auth = _authProvider;
    if (auth == null) return;
    if (auth.state == AuthState.authenticated) {
      _routerDelegate.beamToNamed('/games');
    } else if (auth.state == AuthState.unauthenticated) {
      _routerDelegate.beamToNamed('/login');
    }
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    _authProvider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Five Crowns',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: theme.mode,
      routerDelegate: _routerDelegate,
      routeInformationParser: BeamerParser(),
    );
  }
}
