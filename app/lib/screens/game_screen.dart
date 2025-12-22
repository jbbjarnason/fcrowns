import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart' show themeProvider;
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/card_widget.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/livekit_controls.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final Set<String> _selectedCards = {};
  final List<List<String>> _melds = [];
  bool _showTutorial = false;

  // Store provider references for safe dispose
  late final GameProvider _game;
  late final LiveKitProvider _liveKit;

  @override
  void initState() {
    super.initState();
    // Store references before any async operations
    _game = ref.read(gameProvider);
    _liveKit = ref.read(liveKitProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ref.read(authProvider);
      _game.setUserId(auth.userId!);
      _game.joinGame(widget.gameId);

      // Connect to LiveKit for audio/video
      final api = ref.read(apiServiceProvider);
      _liveKit.connect(
            api: api,
            gameId: widget.gameId,
          );

      // Show tutorial on first play
      if (await TutorialOverlay.shouldShow()) {
        setState(() => _showTutorial = true);
      }
    });
  }

  @override
  void dispose() {
    _game.leaveGame();
    _liveKit.disconnect();
    super.dispose();
  }

  void _toggleCardSelection(String card) {
    setState(() {
      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else {
        _selectedCards.add(card);
      }
    });
  }

  void _createMeldFromSelection() {
    if (_selectedCards.length >= 3) {
      setState(() {
        _melds.add(_selectedCards.toList());
        _selectedCards.clear();
      });
    }
  }

  void _clearMelds() {
    setState(() {
      _melds.clear();
      _selectedCards.clear();
    });
  }

  void _layMelds() {
    if (_melds.isNotEmpty) {
      ref.read(gameProvider).layMelds(_melds);
      _clearMelds();
    }
  }

  void _goOut(String discardCard) {
    final game = ref.read(gameProvider);
    if (game.canGoOut(_melds, discardCard)) {
      game.goOut(_melds, discardCard);
      _clearMelds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot go out - invalid melds or cards remaining')),
      );
    }
  }

  void _showScoreboard(game) {
    final sortedPlayers = List<Map<String, dynamic>>.from(game.players)
      ..sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));
    final myId = ref.read(authProvider).userId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.leaderboard_rounded),
            const SizedBox(width: 8),
            const Text('Scoreboard'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortedPlayers.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final player = entry.value;
            final isMe = player['id'] == myId;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: rank == 1 ? AppTheme.success : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: rank == 1 ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isMe ? 'You' : 'Player ${player['seat'] + 1}',
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${player['score']} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: rank == 1 ? AppTheme.success : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Five Crowns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(gameProvider).leaveGame();
            context.beamToNamed('/games');
          },
        ),
        actions: [
          // LiveKit audio controls
          LiveKitControls(
            gameId: widget.gameId,
            activePlayerId: game.currentPlayerId,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How to play',
            onPressed: () => setState(() => _showTutorial = true),
          ),
          IconButton(
            icon: Icon(
              ref.watch(themeProvider).isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeProvider).toggle(),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Round ${game.roundNumber}/11',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              if (game.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${game.error}', style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: () => game.clearError(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                );
              }

              if (game.gameStatus == 'lobby') {
                return const Center(child: Text('Waiting for game to start...'));
              }

              if (game.gameStatus == 'finished') {
                return _buildGameEndScreen(game);
              }

              return Column(
                children: [
                  // Other players
                  _buildOtherPlayers(game, auth.userId ?? ''),
                  // Game info
                  _buildGameInfo(game),
                  // Draw piles and active player video
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active player video
                      const ActivePlayerVideo(),
                      const SizedBox(width: 16),
                      // Draw piles
                      _buildDrawPiles(game),
                    ],
                  ),
                  // My melds staging area
                  if (_melds.isNotEmpty) _buildMeldsStaging(),
                  // My laid melds
                  if (game.myMelds.isNotEmpty) _buildMyMelds(game),
                  // My hand
                  Expanded(child: _buildMyHand(game)),
                  // Action buttons
                  _buildActionButtons(game),
                ],
              );
            },
          ),
          // Tutorial overlay
          if (_showTutorial)
            TutorialOverlay(
              roundNumber: game.roundNumber,
              onDismiss: () => setState(() => _showTutorial = false),
            ),
        ],
      ),
    );
  }

  Widget _buildOtherPlayers(game, String userId) {
    final otherPlayers = game.players.where((p) => p['id'] != userId).toList();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: otherPlayers.length,
        itemBuilder: (context, index) {
          final player = otherPlayers[index];
          final isCurrentTurn = player['id'] == game.currentPlayerId;
          final score = player['score'] ?? 0;
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isCurrentTurn ? AppTheme.primary : Theme.of(context).dividerColor,
                width: isCurrentTurn ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrentTurn
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'P${player['seat'] + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: isCurrentTurn ? AppTheme.primary : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  '${player['handCount']} cards',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameInfo(game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Last action log
          if (game.lastAction != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      game.lastAction!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showGameLog(game),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.isFinalTurnPhase)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FINAL TURNS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: game.isMyTurn
                      ? AppTheme.success.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: game.isMyTurn ? AppTheme.success : Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  game.isMyTurn
                      ? "Your turn: ${game.turnPhase == 'mustDraw' ? 'Draw' : 'Discard'}"
                      : "Waiting...",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: game.isMyTurn ? AppTheme.success : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGameLog(game) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded),
                const SizedBox(width: 8),
                const Text(
                  'Game Log',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: game.gameLog.length,
                itemBuilder: (context, index) {
                  final reversedIndex = game.gameLog.length - 1 - index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      game.gameLog[reversedIndex],
                      style: TextStyle(
                        color: index == 0
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: index == 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawPiles(game) {
    final canDraw = game.isMyTurn && game.turnPhase == 'mustDraw';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stock pile
          GestureDetector(
            onTap: canDraw ? () => game.drawFromStock() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: canDraw
                    ? Border.all(color: AppTheme.accent, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: canDraw ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.layers_rounded, color: Colors.white, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      '${game.stockCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Discard pile
          GestureDetector(
            onTap: canDraw && game.discardTop != null
                ? () => game.drawFromDiscard()
                : null,
            child: game.discardTop != null
                ? CardWidget(
                    cardCode: game.discardTop!,
                    isSelected: false,
                    highlighted: canDraw,
                  )
                : Container(
                    width: 64,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Empty',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeldsStaging() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.amber.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Staged Melds: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: _clearMelds,
                child: const Text('Clear'),
              ),
            ],
          ),
          Wrap(
            children: _melds.map((meld) {
              return Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: meld.map((c) => SizedBox(
                    width: 30,
                    child: CardWidget(cardCode: c, isSelected: false, small: true),
                  )).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMelds(game) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.green.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Melds:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            children: game.myMelds.map<Widget>((meld) {
              return Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: (meld as List<String>).map((c) => SizedBox(
                    width: 30,
                    child: CardWidget(cardCode: c, isSelected: false, small: true),
                  )).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyHand(game) {
    // Filter out cards that are in staged melds
    final cardsInMelds = _melds.expand((m) => m).toSet();
    final availableCards = game.hand.where((c) => !cardsInMelds.contains(c)).toList();
    final myScore = game.scores[ref.read(authProvider).userId] ?? 0;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('My Hand (${availableCards.length} cards)', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Score: $myScore',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined, size: 20),
                tooltip: 'Scoreboard',
                onPressed: () => _showScoreboard(game),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: availableCards.map<Widget>((card) {
                  final isSelected = _selectedCards.contains(card);
                  return GestureDetector(
                    onTap: () {
                      if (game.isMyTurn && game.turnPhase == 'mustDiscard') {
                        _toggleCardSelection(card);
                      }
                    },
                    onDoubleTap: () {
                      if (game.isMyTurn && game.turnPhase == 'mustDiscard' && !game.isFinalTurnPhase) {
                        game.discard(card);
                      }
                    },
                    child: CardWidget(
                      cardCode: card,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(game) {
    if (!game.isMyTurn || game.turnPhase != 'mustDiscard') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_selectedCards.length >= 3)
            ElevatedButton(
              onPressed: _createMeldFromSelection,
              child: const Text('Create Meld'),
            ),
          if (_melds.isNotEmpty)
            ElevatedButton(
              onPressed: _layMelds,
              child: const Text('Lay Melds'),
            ),
          if (_selectedCards.length == 1 && !game.isFinalTurnPhase)
            ElevatedButton(
              onPressed: () {
                final card = _selectedCards.first;
                if (game.canGoOut(_melds, card)) {
                  _goOut(card);
                } else {
                  game.discard(card);
                  _selectedCards.clear();
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: game.canGoOut(_melds, _selectedCards.first) ? Colors.green : null,
              ),
              child: Text(game.canGoOut(_melds, _selectedCards.first) ? 'Go Out!' : 'Discard'),
            ),
          if (_selectedCards.length == 1 && game.isFinalTurnPhase)
            ElevatedButton(
              onPressed: () {
                game.discard(_selectedCards.first);
                _selectedCards.clear();
                setState(() {});
              },
              child: const Text('Discard'),
            ),
        ],
      ),
    );
  }

  Widget _buildGameEndScreen(game) {
    final sortedScores = game.scores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Game Over!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Final Scores:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ...sortedScores.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final player = game.players.firstWhere(
              (p) => p['id'] == entry.value.key,
              orElse: () => {'displayName': 'Unknown'},
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '$rank. ${player['displayName'] ?? 'Player'}: ${entry.value.value} points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: rank == 1 ? FontWeight.bold : FontWeight.normal,
                  color: rank == 1 ? Colors.green : null,
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.beamToNamed('/games'),
            child: const Text('Back to Games'),
          ),
        ],
      ),
    );
  }
}
