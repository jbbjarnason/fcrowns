import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class GameLobbyScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameLobbyScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends ConsumerState<GameLobbyScreen> {
  bool _subscribedToGame = false;
  GameProvider? _gameProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gamesProvider).loadGame(widget.gameId);
      ref.read(friendsProvider).loadFriends();
      _setupCallbacks();
      _subscribeToGameUpdates();
    });
  }

  void _setupCallbacks() {
    final notifications = ref.read(notificationsProvider);
    notifications.onGameDeleted = (gameId, deletedBy) {
      if (gameId == widget.gameId && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Game was deleted by $deletedBy')),
        );
        context.beamToNamed('/games');
      }
    };
  }

  Future<void> _subscribeToGameUpdates() async {
    if (_subscribedToGame) return;
    _subscribedToGame = true;

    final auth = ref.read(authProvider);
    _gameProvider = ref.read(gameProvider);

    _gameProvider!.setUserId(auth.userId!);
    await _gameProvider!.joinGame(widget.gameId);

    // Listen for game status changes
    _gameProvider!.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (_gameProvider?.gameStatus == 'active' && mounted) {
      // Game has started - navigate to play screen
      context.beamToNamed('/games/${widget.gameId}/play');
    }
  }

  @override
  void dispose() {
    _gameProvider?.removeListener(_onGameStateChanged);
    super.dispose();
  }

  Future<void> _inviteFriend(String friendId) async {
    final success = await ref.read(gamesProvider).invitePlayer(widget.gameId, friendId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Invited!' : 'Failed to invite')),
      );
    }
  }

  Future<void> _startGame() async {
    final game = ref.read(gameProvider);
    // Already subscribed to game via _subscribeToGameUpdates
    // Navigation will happen automatically via _onGameStateChanged
    game.startGame();
  }

  Future<void> _deleteGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text('Are you sure you want to delete this game? All players will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(gamesProvider).deleteGame(widget.gameId);
      if (mounted) {
        if (success) {
          context.beamToNamed('/games');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete game')),
          );
        }
      }
    }
  }

  Future<void> _nudgeHost() async {
    final success = await ref.read(gamesProvider).nudgeHost(widget.gameId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Nudge sent!' : 'Failed to nudge')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(gamesProvider);
    final friends = ref.watch(friendsProvider);
    final auth = ref.watch(authProvider);

    final game = games.currentGame;
    final isHost = game != null && game['createdBy'] == auth.userId;
    final status = game?['status'] as String? ?? 'lobby';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.beamToNamed('/games'),
        ),
        actions: [
          // Only show delete button for host and if game is in lobby
          if (isHost && status == 'lobby')
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Game',
              onPressed: _deleteGame,
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (games.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (game == null) {
            return const Center(child: Text('Game not found'));
          }

          final players = (game['players'] as List?) ?? [];
          final maxPlayers = game['maxPlayers'] as int? ?? 4;

          if (status == 'active' || status == 'finished') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Game is ${status == 'active' ? 'in progress' : 'finished'}'),
                  const SizedBox(height: 16),
                  if (status == 'active')
                    ElevatedButton(
                      onPressed: () => context.beamToNamed('/games/${widget.gameId}/play'),
                      child: const Text('Join Game'),
                    ),
                ],
              ),
            );
          }

          // Get friends not already in game
          final playerIds = players.map((p) => (p['user'] as Map)['id'] as String).toSet();
          final invitableFriends = friends.friends
              .where((f) => !playerIds.contains(f['id']))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Players (${players.length}/$maxPlayers)',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...players.map((player) {
                        final user = player['user'] as Map;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text((user['username'] as String? ?? '?')[0].toUpperCase()),
                          ),
                          title: Text(user['displayName'] as String? ?? user['username'] as String? ?? 'Unknown'),
                          subtitle: Text('Seat ${player['seat'] + 1}'),
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (players.length < maxPlayers) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite Friends', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (invitableFriends.isEmpty)
                          const Text('No friends to invite', style: TextStyle(color: Colors.grey))
                        else
                          ...invitableFriends.map((friend) => ListTile(
                            leading: CircleAvatar(
                              child: Text((friend['username'] as String? ?? '?')[0].toUpperCase()),
                            ),
                            title: Text(friend['displayName'] as String? ?? friend['username'] as String? ?? 'Unknown'),
                            trailing: ElevatedButton(
                              onPressed: () => _inviteFriend(friend['id'] as String),
                              child: const Text('Invite'),
                            ),
                            dense: true,
                          )),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (players.length >= 2)
                isHost
                    ? ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Start Game'),
                      )
                    : ElevatedButton(
                        onPressed: _nudgeHost,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Nudge Host to Start'),
                      )
              else
                const Center(
                  child: Text('Need at least 2 players to start',
                      style: TextStyle(color: Colors.grey)),
                ),
            ],
          );
        },
      ),
    );
  }
}
