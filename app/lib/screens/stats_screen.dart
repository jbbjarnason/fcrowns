import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;
  String? _selectedGroupKey;
  Map<String, dynamic>? _groupDetail;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final stats = await api.getMyStats();

      if (stats != null) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load stats';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadGroupDetail(String groupKey) async {
    try {
      final api = ref.read(apiServiceProvider);
      final detail = await api.getGroupStats(groupKey);

      if (detail != null) {
        setState(() {
          _selectedGroupKey = groupKey;
          _groupDetail = detail;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.beamToNamed('/games'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _selectedGroupKey != null
                  ? _buildGroupDetail()
                  : _buildOverview(),
    );
  }

  Widget _buildOverview() {
    final overall = _stats?['overall'] as Map<String, dynamic>?;
    final groups = (_stats?['groups'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall stats card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                const Text(
                  'Overall Stats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Games', '${overall?['gamesPlayed'] ?? 0}', Colors.white),
                    _buildStatItem('Wins', '${overall?['gamesWon'] ?? 0}', Colors.white),
                    _buildStatItem(
                      'Win Rate',
                      overall != null && (overall['gamesPlayed'] as int) > 0
                          ? '${((overall['gamesWon'] as int) / (overall['gamesPlayed'] as int) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Group stats
          Text(
            'Game Groups',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your history with different player combinations',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          if (groups.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.sports_esports_outlined, size: 48, color: Theme.of(context).disabledColor),
                    const SizedBox(height: 16),
                    Text(
                      'No completed games yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else
            ...groups.map((group) => _buildGroupCard(group as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final players = (group['players'] as List<dynamic>?) ?? [];
    final playerNames = players.map((p) => p['displayName'] as String).join(', ');
    final gamesPlayed = group['gamesPlayed'] as int;
    final gamesWon = group['gamesWon'] as int;
    final avgScore = group['averageScore'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _loadGroupDetail(group['groupKey'] as String),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      players.isEmpty ? 'Solo (test)' : 'vs $playerNames',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniStat('Games', '$gamesPlayed'),
                  const SizedBox(width: 24),
                  _buildMiniStat('Wins', '$gamesWon'),
                  const SizedBox(width: 24),
                  _buildMiniStat('Win %', gamesPlayed > 0 ? '${(gamesWon / gamesPlayed * 100).toStringAsFixed(0)}%' : '0%'),
                  const SizedBox(width: 24),
                  _buildMiniStat('Avg Score', '$avgScore'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildGroupDetail() {
    final detail = _groupDetail!;
    final playerStats = (detail['playerStats'] as List<dynamic>?) ?? [];
    final games = (detail['games'] as List<dynamic>?) ?? [];

    // Sort player stats by wins (descending)
    final sortedStats = List<Map<String, dynamic>>.from(playerStats)
      ..sort((a, b) => (b['gamesWon'] as int).compareTo(a['gamesWon'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedGroupKey = null;
              _groupDetail = null;
            }),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to overview'),
          ),
          const SizedBox(height: 16),

          // Player standings
          Text(
            'Player Standings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          ...sortedStats.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final stats = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rank == 1 ? AppTheme.success.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: rank == 1 ? AppTheme.success : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rank == 1 ? AppTheme.success : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rank == 1 ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stats['displayName'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stats['gamesWon']} wins',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: rank == 1 ? AppTheme.success : null,
                        ),
                      ),
                      Text(
                        'Avg: ${stats['averageScore']} pts',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Game history
          Text(
            'Game History (${games.length} games)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          ...games.map((game) {
            final scores = (game['scores'] as List<dynamic>?) ?? [];
            final winnerId = game['winnerId'] as String?;
            final finishedAt = game['finishedAt'] as String?;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (finishedAt != null)
                      Text(
                        _formatDate(finishedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    ...scores.map((s) {
                      final isWinner = s['playerId'] == winnerId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            if (isWinner)
                              const Icon(Icons.emoji_events, size: 16, color: AppTheme.success)
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s['displayName'] as String,
                                style: TextStyle(
                                  fontWeight: isWinner ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${s['score']} pts',
                              style: TextStyle(
                                fontWeight: isWinner ? FontWeight.w600 : FontWeight.normal,
                                color: isWinner ? AppTheme.success : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
