import 'dart:math';
import 'card.dart';
import 'deck.dart';
import 'meld.dart';
import 'player.dart';

/// Current phase of a player's turn.
enum TurnPhase {
  /// Player must draw from stock or discard pile.
  mustDraw,

  /// Player has drawn and must discard (may lay melds first).
  mustDiscard,
}

/// Game status.
enum GameStatus {
  /// Waiting for players in lobby.
  lobby,

  /// Game is active.
  active,

  /// Game has finished.
  finished,
}

/// Represents the complete state of a Five Crowns game.
class GameState {
  final String gameId;
  final List<Player> players;
  final Deck _stock;
  final List<Card> _discardPile;

  GameStatus status;
  int roundNumber; // 1-11
  int currentPlayerIndex;
  TurnPhase turnPhase;

  /// Player who went out this round (triggers final turns).
  int? playerWhoWentOut;

  /// Tracks which players have had their final turn.
  final Set<int> _playersWithFinalTurn;

  /// Random source for shuffling.
  final Random _random;

  GameState._({
    required this.gameId,
    required this.players,
    required Deck stock,
    required List<Card> discardPile,
    required this.status,
    required this.roundNumber,
    required this.currentPlayerIndex,
    required this.turnPhase,
    this.playerWhoWentOut,
    Set<int>? playersWithFinalTurn,
    Random? random,
  })  : _stock = stock,
        _discardPile = discardPile,
        _playersWithFinalTurn = playersWithFinalTurn ?? {},
        _random = random ?? Random();

  /// Creates a new game in lobby state.
  factory GameState.create({
    required String gameId,
    required List<String> playerIds,
    Random? random,
  }) {
    if (playerIds.length < 2 || playerIds.length > 7) {
      throw ArgumentError('Five Crowns requires 2-7 players');
    }

    final players = <Player>[];
    for (var i = 0; i < playerIds.length; i++) {
      players.add(Player(id: playerIds[i], seat: i));
    }

    return GameState._(
      gameId: gameId,
      players: players,
      stock: Deck.create(),
      discardPile: [],
      status: GameStatus.lobby,
      roundNumber: 0,
      currentPlayerIndex: 0,
      turnPhase: TurnPhase.mustDraw,
      random: random,
    );
  }

  /// Number of cards dealt in current round (round 1 = 3 cards, round 11 = 13).
  int get cardsPerHand => roundNumber + 2;

  /// The current wild rank for this round.
  Rank get wildRank => Rank.fromCardCount(cardsPerHand);

  /// Current player.
  Player get currentPlayer => players[currentPlayerIndex];

  /// Top card of discard pile (if any).
  Card? get topDiscard => _discardPile.isEmpty ? null : _discardPile.last;

  /// Discard pile (read-only view).
  List<Card> get discardPile => List.unmodifiable(_discardPile);

  /// Number of cards remaining in stock.
  int get stockCount => _stock.remainingCards;

  /// Whether the game is in the final turn phase.
  bool get isFinalTurnPhase => playerWhoWentOut != null;

  /// Starts the game (transitions from lobby to active, starts round 1).
  void startGame() {
    if (status != GameStatus.lobby) {
      throw StateError('Game already started');
    }
    if (players.length < 2) {
      throw StateError('Need at least 2 players to start');
    }
    status = GameStatus.active;
    _startRound(1);
  }

  /// Starts a new round.
  void _startRound(int round) {
    roundNumber = round;
    playerWhoWentOut = null;
    _playersWithFinalTurn.clear();

    // Clear hands and melds
    for (final player in players) {
      player.clearForRound();
    }

    // Create and shuffle fresh deck
    final deck = Deck.create();
    deck.shuffle(_random);
    _stock.reset(deck.remainingCardsList);
    _discardPile.clear();

    // Deal cards
    final cardsToDeal = cardsPerHand;
    for (final player in players) {
      player.addAllToHand(_stock.drawMany(cardsToDeal));
    }

    // Start discard pile with one card
    _discardPile.add(_stock.draw());

    // First player starts
    currentPlayerIndex = 0;
    turnPhase = TurnPhase.mustDraw;
  }

  /// Draws a card from stock.
  Card drawFromStock() {
    _validateTurnPhase(TurnPhase.mustDraw);

    if (_stock.isEmpty) {
      _reshuffleDiscardPile();
    }

    final card = _stock.draw();
    currentPlayer.addToHand(card);
    turnPhase = TurnPhase.mustDiscard;
    return card;
  }

  /// Draws the top card from discard pile.
  Card drawFromDiscard() {
    _validateTurnPhase(TurnPhase.mustDraw);

    if (_discardPile.isEmpty) {
      throw StateError('Discard pile is empty');
    }

    final card = _discardPile.removeLast();
    currentPlayer.addToHand(card);
    turnPhase = TurnPhase.mustDiscard;
    return card;
  }

  /// Reshuffles the discard pile into the stock (keeping top card).
  void _reshuffleDiscardPile() {
    if (_discardPile.length <= 1) {
      throw StateError('Not enough cards to reshuffle');
    }

    final topCard = _discardPile.removeLast();
    final cardsToShuffle = List<Card>.from(_discardPile);
    _discardPile.clear();
    _discardPile.add(topCard);

    _stock.reset(cardsToShuffle);
    _stock.shuffle(_random);
  }

  /// Lays down melds (without going out).
  void layMelds(List<List<Card>> melds) {
    _validateTurnPhase(TurnPhase.mustDiscard);

    for (final meldCards in melds) {
      if (!MeldValidator.isValidMeld(meldCards, roundNumber)) {
        throw StateError('Invalid meld');
      }

      // Remove cards from hand
      currentPlayer.removeCardsFromHand(meldCards);

      // Create and store meld
      final meldType = MeldValidator.getMeldType(meldCards, roundNumber)!;
      final meld = meldType == MeldType.run
          ? Meld.run(meldCards)
          : Meld.book(meldCards);
      currentPlayer.layMeld(meld);
    }
  }

  /// Lays off cards to an existing meld (own or another player's).
  /// Not allowed during final turn phase.
  void layOff(int targetPlayerIndex, int meldIndex, List<Card> cards) {
    _validateTurnPhase(TurnPhase.mustDiscard);

    if (isFinalTurnPhase) {
      throw StateError('Cannot lay off cards during final turn phase');
    }

    if (cards.isEmpty) {
      throw StateError('Must lay off at least one card');
    }

    // Validate target player exists
    if (targetPlayerIndex < 0 || targetPlayerIndex >= players.length) {
      throw StateError('Invalid target player index');
    }

    final targetPlayer = players[targetPlayerIndex];

    // Validate meld exists
    if (meldIndex < 0 || meldIndex >= targetPlayer.melds.length) {
      throw StateError('Invalid meld index');
    }

    final existingMeld = targetPlayer.melds[meldIndex];

    // Validate cards exist in current player's hand
    final handCopy = List<Card>.from(currentPlayer.hand);
    for (final card in cards) {
      final idx = handCopy.indexWhere((c) => c == card);
      if (idx == -1) {
        throw StateError('Card $card not in hand');
      }
      handCopy.removeAt(idx);
    }

    // Validate extension is valid
    if (!MeldValidator.canExtendMeld(existingMeld, cards, roundNumber)) {
      throw StateError('Cannot extend meld with provided cards');
    }

    // Remove cards from current player's hand
    currentPlayer.removeCardsFromHand(cards);

    // Extend the target meld
    final extendedMeld = MeldValidator.extendMeld(existingMeld, cards, roundNumber);
    targetPlayer.replaceMeld(meldIndex, extendedMeld);
  }

  /// Discards a card, ending the turn.
  void discard(Card card) {
    _validateTurnPhase(TurnPhase.mustDiscard);

    if (!currentPlayer.removeFromHand(card)) {
      throw StateError('Card not in hand');
    }

    _discardPile.add(card);
    _advanceTurn();
  }

  /// Goes out by laying all remaining cards as melds and discarding.
  void goOut(List<List<Card>> melds, Card discard) {
    _validateTurnPhase(TurnPhase.mustDiscard);

    if (isFinalTurnPhase) {
      throw StateError('Cannot go out during final turn phase');
    }

    // Validate the go-out move
    if (!MeldValidator.canGoOut(
      currentPlayer.hand,
      melds,
      discard,
      roundNumber,
    )) {
      throw StateError('Invalid go-out: melds must use all cards except discard');
    }

    // Lay all melds
    for (final meldCards in melds) {
      currentPlayer.removeCardsFromHand(meldCards);
      final meldType = MeldValidator.getMeldType(meldCards, roundNumber)!;
      final meld = meldType == MeldType.run
          ? Meld.run(meldCards)
          : Meld.book(meldCards);
      currentPlayer.layMeld(meld);
    }

    // Discard final card
    currentPlayer.removeFromHand(discard);
    _discardPile.add(discard);

    // Mark player as going out
    playerWhoWentOut = currentPlayerIndex;

    _advanceTurn();
  }

  /// Advances to the next player's turn.
  void _advanceTurn() {
    if (isFinalTurnPhase) {
      _playersWithFinalTurn.add(currentPlayerIndex);

      // Check if all other players have had final turn
      final allDone = players.asMap().entries.every((e) =>
          e.key == playerWhoWentOut || _playersWithFinalTurn.contains(e.key));

      if (allDone) {
        _endRound();
        return;
      }
    }

    // Move to next player
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

    // Skip player who went out in final turn phase
    if (isFinalTurnPhase && currentPlayerIndex == playerWhoWentOut) {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }

    turnPhase = TurnPhase.mustDraw;
  }

  /// Ends the current round, calculates scores, and starts next round or ends game.
  void _endRound() {
    // Calculate scores for remaining cards in each player's hand
    for (final player in players) {
      final handScore = player.calculateHandScore(roundNumber);
      player.addScore(handScore);
    }

    // Check if game is over (round 11 complete)
    if (roundNumber >= 11) {
      status = GameStatus.finished;
    } else {
      _startRound(roundNumber + 1);
    }
  }

  /// Gets the winner(s) - player(s) with lowest score.
  List<Player> get winners {
    if (status != GameStatus.finished) return [];

    final minScore = players.map((p) => p.score).reduce((a, b) => a < b ? a : b);
    return players.where((p) => p.score == minScore).toList();
  }

  /// Validates that we're in the expected turn phase.
  void _validateTurnPhase(TurnPhase expected) {
    if (status != GameStatus.active) {
      throw StateError('Game is not active');
    }
    if (turnPhase != expected) {
      throw StateError('Expected $expected but in $turnPhase');
    }
  }

  /// Creates a snapshot of visible state for a specific player.
  /// Hides other players' hands.
  Map<String, dynamic> toPlayerView(String playerId) {
    final playerIndex = players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) {
      throw ArgumentError('Player not in game');
    }

    final playersList = <Map<String, dynamic>>[];
    for (final p in players) {
      final isMe = p.id == playerId;
      final playerMap = <String, dynamic>{
        'id': p.id,
        'seat': p.seat,
        'score': p.score,
        'handCount': p.hand.length,
        'melds': p.melds.map((m) => m.encode()).toList(),
      };
      if (isMe) {
        playerMap['hand'] = p.hand.map((c) => c.encode()).toList();
      }
      playersList.add(playerMap);
    }

    final result = <String, dynamic>{
      'gameId': gameId,
      'status': status.name,
      'roundNumber': roundNumber,
      'cardsPerHand': cardsPerHand,
      'wildRank': wildRank.code,
      'currentPlayerIndex': currentPlayerIndex,
      'turnPhase': turnPhase.name,
      'isFinalTurnPhase': isFinalTurnPhase,
      'stockCount': stockCount,
      'topDiscard': topDiscard?.encode(),
      'players': playersList,
    };

    if (playerIndex >= 0) {
      result['yourHand'] = players[playerIndex].hand.map((c) => c.encode()).toList();
    }

    return result;
  }

  /// Creates a full snapshot including all hands (for server-side persistence).
  Map<String, dynamic> toFullSnapshot() {
    final playersList = <Map<String, dynamic>>[];
    for (final p in players) {
      final meldsList = <Map<String, dynamic>>[];
      for (final m in p.melds) {
        meldsList.add({
          'type': m.type.name,
          'cards': m.encode(),
        });
      }
      playersList.add({
        'id': p.id,
        'seat': p.seat,
        'score': p.score,
        'hand': p.hand.map((c) => c.encode()).toList(),
        'melds': meldsList,
      });
    }

    return {
      'gameId': gameId,
      'status': status.name,
      'roundNumber': roundNumber,
      'currentPlayerIndex': currentPlayerIndex,
      'turnPhase': turnPhase.name,
      'playerWhoWentOut': playerWhoWentOut,
      'playersWithFinalTurn': _playersWithFinalTurn.toList(),
      'discardPile': _discardPile.map((c) => c.encode()).toList(),
      'stockCards': _stock.remainingCardsList.map((c) => c.encode()).toList(),
      'players': playersList,
    };
  }

  /// Restores game state from a full snapshot.
  static GameState fromFullSnapshot(Map<String, dynamic> snapshot) {
    final stockCards = (snapshot['stockCards'] as List)
        .map((c) => Card.decode(c as String))
        .toList();
    final stock = Deck.create();
    stock.reset(stockCards);

    final discardPile = (snapshot['discardPile'] as List)
        .map((c) => Card.decode(c as String))
        .toList();

    final players = (snapshot['players'] as List).map((p) {
      final handCards = (p['hand'] as List)
          .map((c) => Card.decode(c as String))
          .toList();
      final melds = (p['melds'] as List).map((m) {
        final cards = (m['cards'] as List)
            .map((c) => Card.decode(c as String))
            .toList();
        return m['type'] == 'run' ? Meld.run(cards) : Meld.book(cards);
      }).toList();

      return Player(
        id: p['id'] as String,
        seat: p['seat'] as int,
        hand: handCards,
        melds: melds,
        score: p['score'] as int,
      );
    }).toList();

    return GameState._(
      gameId: snapshot['gameId'] as String,
      players: players,
      stock: stock,
      discardPile: discardPile,
      status: GameStatus.values.byName(snapshot['status'] as String),
      roundNumber: snapshot['roundNumber'] as int,
      currentPlayerIndex: snapshot['currentPlayerIndex'] as int,
      turnPhase: TurnPhase.values.byName(snapshot['turnPhase'] as String),
      playerWhoWentOut: snapshot['playerWhoWentOut'] as int?,
      playersWithFinalTurn:
          (snapshot['playersWithFinalTurn'] as List).cast<int>().toSet(),
    );
  }
}
