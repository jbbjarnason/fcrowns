import 'card.dart';
import 'meld.dart';

/// Represents a player in the game.
class Player {
  final String id;
  final int seat;
  final List<Card> _hand;
  final List<Meld> _melds;
  int _score;

  Player({
    required this.id,
    required this.seat,
    List<Card>? hand,
    List<Meld>? melds,
    int score = 0,
  })  : _hand = hand ?? [],
        _melds = melds ?? [],
        _score = score;

  /// The player's current hand.
  List<Card> get hand => List.unmodifiable(_hand);

  /// The melds the player has laid down.
  List<Meld> get melds => List.unmodifiable(_melds);

  /// The player's accumulated score (lower is better).
  int get score => _score;

  /// Adds a card to the player's hand.
  void addToHand(Card card) => _hand.add(card);

  /// Adds multiple cards to the player's hand.
  void addAllToHand(List<Card> cards) => _hand.addAll(cards);

  /// Removes a card from the player's hand.
  /// Returns false if card not found.
  bool removeFromHand(Card card) {
    final idx = _hand.indexWhere((c) => c == card);
    if (idx == -1) return false;
    _hand.removeAt(idx);
    return true;
  }

  /// Removes multiple cards from hand and returns them.
  /// Throws if any card not found.
  List<Card> removeCardsFromHand(List<Card> cards) {
    final removed = <Card>[];
    final handCopy = List<Card>.from(_hand);

    for (final card in cards) {
      final idx = handCopy.indexWhere((c) => c == card);
      if (idx == -1) {
        throw StateError('Card $card not in hand');
      }
      removed.add(handCopy.removeAt(idx));
    }

    _hand.clear();
    _hand.addAll(handCopy);
    return removed;
  }

  /// Lays down a meld.
  void layMeld(Meld meld) => _melds.add(meld);

  /// Clears the player's hand and melds for a new round.
  void clearForRound() {
    _hand.clear();
    _melds.clear();
  }

  /// Replaces the hand with new cards (for testing/restoration).
  void setHand(List<Card> cards) {
    _hand.clear();
    _hand.addAll(cards);
  }

  /// Adds points to the player's score.
  void addScore(int points) => _score += points;

  /// Calculates points for remaining cards in hand.
  int calculateHandScore(int roundNumber) {
    var total = 0;
    for (final card in _hand) {
      total += card.score(roundNumber);
    }
    return total;
  }

  /// Creates a copy of this player.
  Player copy() => Player(
        id: id,
        seat: seat,
        hand: List.from(_hand),
        melds: List.from(_melds),
        score: _score,
      );
}
