import 'dart:math';
import 'card.dart';

/// Constructs and manages the Five Crowns deck.
class Deck {
  final List<Card> _cards;
  int _drawIndex = 0;

  Deck._(this._cards);

  /// Creates a new Five Crowns deck (2 standard decks + 6 jokers = 116 cards).
  /// Each standard deck: 5 suits × 11 ranks = 55 cards + 3 jokers = 58 cards.
  factory Deck.create() {
    final cards = <Card>[];

    // Two copies of each standard deck
    for (var copy = 0; copy < 2; copy++) {
      // All suit/rank combinations
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          cards.add(Card(suit, rank));
        }
      }
      // 3 jokers per deck
      for (var j = 0; j < 3; j++) {
        cards.add(const Card.joker());
      }
    }

    return Deck._(cards);
  }

  /// Returns total number of cards in deck.
  int get totalCards => _cards.length;

  /// Returns number of cards remaining to draw.
  int get remainingCards => _cards.length - _drawIndex;

  /// Shuffles the deck using the provided random source.
  void shuffle([Random? random]) {
    random ??= Random();
    // Fisher-Yates shuffle
    for (var i = _cards.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }
    _drawIndex = 0;
  }

  /// Draws the top card from the deck.
  /// Throws if deck is empty.
  Card draw() {
    if (_drawIndex >= _cards.length) {
      throw StateError('Cannot draw from empty deck');
    }
    return _cards[_drawIndex++];
  }

  /// Draws multiple cards from the deck.
  List<Card> drawMany(int count) {
    final cards = <Card>[];
    for (var i = 0; i < count; i++) {
      cards.add(draw());
    }
    return cards;
  }

  /// Returns true if the deck is empty.
  bool get isEmpty => _drawIndex >= _cards.length;

  /// Resets the deck to full (for reshuffling discard pile).
  void reset(List<Card> cards) {
    _cards.clear();
    _cards.addAll(cards);
    _drawIndex = 0;
  }

  /// Returns all remaining cards (for serialization).
  List<Card> get remainingCardsList {
    return _cards.sublist(_drawIndex);
  }
}
