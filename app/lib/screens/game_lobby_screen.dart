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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gamesProvider).loadGame(widget.gameId);
      ref.read(friendsProvider).loadFriends();
    });
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
    final auth = ref.read(authProvider);
    final game = ref.read(gameProvider);

    game.setUserId(auth.userId!);
    await game.joinGame(widget.gameId);
    game.startGame();

    if (mounted) {
      context.beamToNamed('/games/${widget.gameId}/play');
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(gamesProvider);
    final friends = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.beamToNamed('/games'),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (games.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final game = games.currentGame;
          if (game == null) {
            return const Center(child: Text('Game not found'));
          }

          final players = (game['players'] as List?) ?? [];
          final maxPlayers = game['maxPlayers'] as int? ?? 4;
          final status = game['status'] as String? ?? 'lobby';

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
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Game'),
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
