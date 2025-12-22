import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gamesProvider).loadGames();
    });
  }

  Future<void> _createGame() async {
    final games = ref.read(gamesProvider);
    final gameId = await games.createGame();
    if (gameId != null && mounted) {
      context.beamToNamed('/games/$gameId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(gamesProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Five Crowns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            onPressed: () => context.beamToNamed('/stats'),
            tooltip: 'My Stats',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.beamToNamed('/friends'),
            tooltip: 'Friends',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                context.beamToNamed('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (games.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final gamesList = games.games;
          if (gamesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.games, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No games yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createGame,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Game'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => games.loadGames(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gamesList.length,
              itemBuilder: (context, index) {
                final game = gamesList[index];
                // Safely access game data
                final gameId = game['id']?.toString() ?? 'unknown';
                final players = (game['players'] as List?) ?? [];
                final status = game['status']?.toString() ?? 'lobby';
                final maxPlayers = (game['maxPlayers'] as int?) ?? 4;
                final dateStr = _formatDate(game['createdAt']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Game ${gameId.length > 8 ? gameId.substring(0, 8) : gameId}'),
                    subtitle: Text(
                      '${players.length}/$maxPlayers players - ${_statusLabel(status)}${dateStr.isNotEmpty ? '\nStarted: $dateStr' : ''}',
                    ),
                    isThreeLine: dateStr.isNotEmpty,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.beamToNamed('/games/$gameId'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGame,
        icon: const Icon(Icons.add),
        label: const Text('New Game'),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'lobby':
        return 'Waiting for players';
      case 'active':
        return 'In progress';
      case 'finished':
        return 'Finished';
      default:
        return status;
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      DateTime date;
      if (dateValue is int) {
        // Unix timestamp in milliseconds
        date = DateTime.fromMillisecondsSinceEpoch(dateValue).toLocal();
      } else if (dateValue is String) {
        // Try ISO 8601 format first, then Unix timestamp
        if (dateValue.contains('-') || dateValue.contains('T')) {
          date = DateTime.parse(dateValue).toLocal();
        } else {
          final ms = int.tryParse(dateValue);
          if (ms == null) return '';
          date = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
        }
      } else {
        return '';
      }
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day}, ${date.year} $hour:$minute';
    } catch (e) {
      return '';
    }
  }
}
