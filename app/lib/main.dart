import 'dart:math' as math;
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'routing/locations.dart';
import 'theme/app_theme.dart';

final themeProvider = ChangeNotifierProvider((ref) => ThemeProvider());

/// Global key to trigger nudge shake animation from anywhere
final nudgeShakeKey = GlobalKey<_NudgeShakeWrapperState>();

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

    // Set up nudge callback at app level so it works from any screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNudgeCallback();
    });

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
          pathPatterns: ['/games', '/games/*', '/friends', '/stats', '/profile'],
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
      // Re-setup nudge callback when user authenticates
      _setupNudgeCallback();
    } else if (auth.state == AuthState.unauthenticated) {
      _routerDelegate.beamToNamed('/login');
    }
  }

  void _setupNudgeCallback() {
    final notifications = ref.read(notificationsProvider);
    notifications.onNudgeReceived = () {
      debugPrint('[NUDGE] Triggering shake animation');
      nudgeShakeKey.currentState?.shake();
    };
    debugPrint('[NUDGE] Callback set up at app level');
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

    return NudgeShakeWrapper(
      key: nudgeShakeKey,
      child: MaterialApp.router(
        title: 'Five Crowns',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: theme.mode,
        routerDelegate: _routerDelegate,
        routeInformationParser: BeamerParser(),
      ),
    );
  }
}

/// Widget that wraps the app and can shake when nudged
class NudgeShakeWrapper extends StatefulWidget {
  final Widget child;

  const NudgeShakeWrapper({super.key, required this.child});

  @override
  State<NudgeShakeWrapper> createState() => _NudgeShakeWrapperState();
}

class _NudgeShakeWrapperState extends State<NudgeShakeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create a shake animation that goes: 0 -> right -> left -> right -> left -> 0
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: -0.03), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.02), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.02, end: -0.02), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.02, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger the shake animation
  void shake() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * math.pi,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
