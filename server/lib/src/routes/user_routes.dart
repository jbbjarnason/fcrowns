import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

import '../db/database.dart';

class UserRoutes {
  final AppDatabase db;

  UserRoutes({required this.db});

  Router get router {
    final router = Router();

    router.get('/me', _getMe);
    router.get('/search', _searchUsers);
    router.get('/me/stats', _getMyStats);
    router.get('/me/stats/<groupKey>', _getGroupStats);

    return router;
  }

  Future<Response> _getMe(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) {
      return Response(401,
          body: jsonEncode({'error': 'unauthorized'}),
          headers: {'content-type': 'application/json'});
    }

    final user = await (db.select(db.users)
      ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();

    if (user == null) {
      return Response(404,
          body: jsonEncode({'error': 'not_found'}),
          headers: {'content-type': 'application/json'});
    }

    return Response(200,
        body: jsonEncode(MeResponse(
          id: user.id,
          email: user.email,
          username: user.username,
          displayName: user.displayName,
          avatarUrl: user.avatarUrl,
          emailVerified: user.emailVerifiedAt != null,
          createdAt: user.createdAt,
        ).toJson()),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _searchUsers(Request request) async {
    final username = request.url.queryParameters['username'];
    if (username == null || username.length < 2) {
      return Response(400,
          body: jsonEncode({'error': 'query_too_short', 'message': 'Username query must be at least 2 characters'}),
          headers: {'content-type': 'application/json'});
    }

    final users = await (db.select(db.users)
      ..where((u) => u.username.like('${username.toLowerCase()}%'))
      ..limit(20))
        .get();

    final results = users.map((u) => UserDto(
      id: u.id,
      username: u.username,
      displayName: u.displayName,
      avatarUrl: u.avatarUrl,
    ).toJson()).toList();

    return Response(200,
        body: jsonEncode({'users': results}),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _getMyStats(Request request) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) {
      return Response(401,
          body: jsonEncode({'error': 'unauthorized'}),
          headers: {'content-type': 'application/json'});
    }

    // Get all finished games for this user
    final myGames = await (db.select(db.gamePlayers)
          ..where((gp) => gp.userId.equals(userId)))
        .get();

    final gameIds = myGames.map((g) => g.gameId).toList();
    if (gameIds.isEmpty) {
      return Response(200,
          body: jsonEncode({'groups': [], 'overall': {'gamesPlayed': 0, 'gamesWon': 0}}),
          headers: {'content-type': 'application/json'});
    }

    // Get finished games only
    final finishedGames = await (db.select(db.games)
          ..where((g) => g.id.isIn(gameIds) & g.status.equals('finished')))
        .get();

    if (finishedGames.isEmpty) {
      return Response(200,
          body: jsonEncode({'groups': [], 'overall': {'gamesPlayed': 0, 'gamesWon': 0}}),
          headers: {'content-type': 'application/json'});
    }

    final finishedGameIds = finishedGames.map((g) => g.id).toList();

    // Get all players for each finished game
    final allGamePlayers = await (db.select(db.gamePlayers)
          ..where((gp) => gp.gameId.isIn(finishedGameIds)))
        .get();

    // Get game results
    final gameResults = await (db.select(db.gameResults)
          ..where((gr) => gr.gameId.isIn(finishedGameIds)))
        .get();

    final resultsMap = {for (var r in gameResults) r.gameId: r};

    // Group by player combination
    final groups = <String, Map<String, dynamic>>{};
    int overallGamesPlayed = 0;
    int overallGamesWon = 0;

    for (final game in finishedGames) {
      final players = allGamePlayers.where((p) => p.gameId == game.id).toList();
      final playerIds = players.map((p) => p.userId).toList()..sort();
      final groupKey = playerIds.join(',');
      final result = resultsMap[game.id];

      final scoresJson = result?.scoresJson;
      final scores = scoresJson != null ? jsonDecode(scoresJson) as Map<String, dynamic> : <String, dynamic>{};

      final isWinner = result?.winnerUserId == userId;
      overallGamesPlayed++;
      if (isWinner) overallGamesWon++;

      if (!groups.containsKey(groupKey)) {
        groups[groupKey] = {
          'groupKey': groupKey,
          'playerIds': playerIds,
          'gamesPlayed': 0,
          'gamesWon': 0,
          'totalScore': 0,
          'gameIds': <String>[],
        };
      }

      groups[groupKey]!['gamesPlayed'] = (groups[groupKey]!['gamesPlayed'] as int) + 1;
      if (isWinner) {
        groups[groupKey]!['gamesWon'] = (groups[groupKey]!['gamesWon'] as int) + 1;
      }
      groups[groupKey]!['totalScore'] = (groups[groupKey]!['totalScore'] as int) + ((scores[userId] as num?)?.toInt() ?? 0);
      (groups[groupKey]!['gameIds'] as List<String>).add(game.id);
    }

    // Enrich with player display names
    final allPlayerIds = groups.values.expand((g) => g['playerIds'] as List<String>).toSet();
    final users = await (db.select(db.users)
          ..where((u) => u.id.isIn(allPlayerIds.toList())))
        .get();
    final userMap = {for (var u in users) u.id: u};

    final enrichedGroups = groups.values.map((g) {
      final playerIds = g['playerIds'] as List<String>;
      final players = playerIds
          .where((id) => id != userId)
          .map((id) => {
                'id': id,
                'displayName': userMap[id]?.displayName ?? 'Unknown',
                'username': userMap[id]?.username ?? 'unknown',
              })
          .toList();
      return {
        'groupKey': g['groupKey'],
        'players': players,
        'gamesPlayed': g['gamesPlayed'],
        'gamesWon': g['gamesWon'],
        'averageScore': (g['gamesPlayed'] as int) > 0
            ? ((g['totalScore'] as int) / (g['gamesPlayed'] as int)).round()
            : 0,
      };
    }).toList();

    // Sort by games played descending
    enrichedGroups.sort((a, b) => (b['gamesPlayed'] as int).compareTo(a['gamesPlayed'] as int));

    return Response(200,
        body: jsonEncode({
          'groups': enrichedGroups,
          'overall': {'gamesPlayed': overallGamesPlayed, 'gamesWon': overallGamesWon}
        }),
        headers: {'content-type': 'application/json'});
  }

  Future<Response> _getGroupStats(Request request, String groupKey) async {
    final userId = request.context['userId'] as String?;
    if (userId == null) {
      return Response(401,
          body: jsonEncode({'error': 'unauthorized'}),
          headers: {'content-type': 'application/json'});
    }

    final playerIds = groupKey.split(',');
    if (!playerIds.contains(userId)) {
      return Response(403,
          body: jsonEncode({'error': 'not_in_group'}),
          headers: {'content-type': 'application/json'});
    }

    // Find all games with exactly these players
    final allGamePlayers = await db.select(db.gamePlayers).get();

    // Group by game
    final gamePlayerMap = <String, List<String>>{};
    for (final gp in allGamePlayers) {
      gamePlayerMap.putIfAbsent(gp.gameId, () => []);
      gamePlayerMap[gp.gameId]!.add(gp.userId);
    }

    // Find games with exactly these players
    final matchingGameIds = gamePlayerMap.entries
        .where((e) {
          final gamePlayers = e.value..sort();
          return gamePlayers.join(',') == groupKey;
        })
        .map((e) => e.key)
        .toList();

    if (matchingGameIds.isEmpty) {
      return Response(200,
          body: jsonEncode({'games': []}),
          headers: {'content-type': 'application/json'});
    }

    // Get finished games with results
    final games = await (db.select(db.games)
          ..where((g) => g.id.isIn(matchingGameIds) & g.status.equals('finished'))
          ..orderBy([(g) => OrderingTerm.desc(g.finishedAt)]))
        .get();

    final results = await (db.select(db.gameResults)
          ..where((r) => r.gameId.isIn(matchingGameIds)))
        .get();
    final resultsMap = {for (var r in results) r.gameId: r};

    // Get player info
    final users = await (db.select(db.users)
          ..where((u) => u.id.isIn(playerIds)))
        .get();
    final userMap = {for (var u in users) u.id: u};

    final gameDetails = games.map((g) {
      final result = resultsMap[g.id];
      final scores = result?.scoresJson != null
          ? jsonDecode(result!.scoresJson) as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'gameId': g.id,
        'finishedAt': g.finishedAt?.toIso8601String(),
        'winnerId': result?.winnerUserId,
        'scores': playerIds.map((id) => {
              'playerId': id,
              'displayName': userMap[id]?.displayName ?? 'Unknown',
              'score': (scores[id] as num?)?.toInt() ?? 0,
            }).toList(),
      };
    }).toList();

    // Calculate per-player stats
    final playerStats = <String, Map<String, dynamic>>{};
    for (final id in playerIds) {
      playerStats[id] = {
        'playerId': id,
        'displayName': userMap[id]?.displayName ?? 'Unknown',
        'gamesWon': 0,
        'totalScore': 0,
      };
    }

    for (final g in gameDetails) {
      final winnerId = g['winnerId'] as String?;
      if (winnerId != null && playerStats.containsKey(winnerId)) {
        playerStats[winnerId]!['gamesWon'] = (playerStats[winnerId]!['gamesWon'] as int) + 1;
      }
      for (final s in g['scores'] as List<Map<String, dynamic>>) {
        final pid = s['playerId'] as String;
        playerStats[pid]!['totalScore'] = (playerStats[pid]!['totalScore'] as int) + (s['score'] as int);
      }
    }

    // Calculate averages
    for (final stats in playerStats.values) {
      stats['averageScore'] = games.isNotEmpty
          ? ((stats['totalScore'] as int) / games.length).round()
          : 0;
    }

    return Response(200,
        body: jsonEncode({
          'groupKey': groupKey,
          'gamesPlayed': games.length,
          'playerStats': playerStats.values.toList(),
          'games': gameDetails,
        }),
        headers: {'content-type': 'application/json'});
  }
}
