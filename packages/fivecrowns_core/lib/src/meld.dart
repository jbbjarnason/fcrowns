import 'card.dart';

/// Type of meld.
enum MeldType { run, book }

/// Represents a valid meld (run or book) of cards.
class Meld {
  final MeldType type;
  final List<Card> cards;

  const Meld._(this.type, this.cards);

  /// Creates a run meld (same suit, consecutive ranks).
  factory Meld.run(List<Card> cards) {
    if (cards.length < 3) {
      throw ArgumentError('Run must have at least 3 cards');
    }
    return Meld._(MeldType.run, List.unmodifiable(cards));
  }

  /// Creates a book meld (same rank, different suits).
  factory Meld.book(List<Card> cards) {
    if (cards.length < 3) {
      throw ArgumentError('Book must have at least 3 cards');
    }
    return Meld._(MeldType.book, List.unmodifiable(cards));
  }

  /// Encodes meld to list of card codes.
  List<String> encode() => cards.map((c) => c.encode()).toList();
}

/// Validates melds according to Five Crowns rules.
class MeldValidator {
  /// Validates a proposed run (same suit, consecutive ranks).
  /// Wild cards (jokers + rotating wild) can substitute for any card.
  /// Returns true if valid.
  static bool isValidRun(List<Card> cards, int roundNumber) {
    if (cards.length < 3) return false;

    // Separate wilds from natural cards
    final wilds = <Card>[];
    final naturals = <Card>[];
    for (final card in cards) {
      if (card.isWild(roundNumber)) {
        wilds.add(card);
      } else {
        naturals.add(card);
      }
    }

    // If all wilds, valid if at least 3
    if (naturals.isEmpty) return cards.length >= 3;

    // All natural cards must be same suit
    final suit = naturals.first.suit;
    if (!naturals.every((c) => c.suit == suit)) return false;

    // Sort naturals by rank value
    naturals.sort((a, b) => a.rank!.value.compareTo(b.rank!.value));

    // Check for duplicates in naturals
    for (var i = 0; i < naturals.length - 1; i++) {
      if (naturals[i].rank == naturals[i + 1].rank) return false;
    }

    // Calculate gaps that need to be filled by wilds
    var wildsNeeded = 0;
    for (var i = 0; i < naturals.length - 1; i++) {
      final gap = naturals[i + 1].rank!.value - naturals[i].rank!.value - 1;
      wildsNeeded += gap;
    }

    // We have enough wilds to fill gaps
    return wilds.length >= wildsNeeded;
  }

  /// Validates a proposed book (same rank, different suits for naturals).
  /// Wild cards can substitute for any card of that rank.
  /// Returns true if valid.
  static bool isValidBook(List<Card> cards, int roundNumber) {
    if (cards.length < 3) return false;

    // Separate wilds from natural cards
    final naturals = <Card>[];
    for (final card in cards) {
      if (!card.isWild(roundNumber)) {
        naturals.add(card);
      }
    }

    // If all wilds, valid if at least 3
    if (naturals.isEmpty) return cards.length >= 3;

    // All natural cards must be same rank
    final rank = naturals.first.rank;
    if (!naturals.every((c) => c.rank == rank)) return false;

    // All natural cards must have different suits
    final suits = <Suit>{};
    for (final card in naturals) {
      if (suits.contains(card.suit)) return false;
      suits.add(card.suit!);
    }

    return true;
  }

  /// Validates a meld (either run or book).
  static bool isValidMeld(List<Card> cards, int roundNumber) {
    return isValidRun(cards, roundNumber) || isValidBook(cards, roundNumber);
  }

  /// Determines the type of a valid meld.
  /// Returns null if the meld is invalid.
  static MeldType? getMeldType(List<Card> cards, int roundNumber) {
    if (isValidRun(cards, roundNumber)) return MeldType.run;
    if (isValidBook(cards, roundNumber)) return MeldType.book;
    return null;
  }

  /// Validates that a collection of melds uses all cards exactly once
  /// and leaves exactly one card for discarding (for going out).
  static bool canGoOut(
    List<Card> hand,
    List<List<Card>> proposedMelds,
    Card discard,
    int roundNumber,
  ) {
    // Count all cards in melds + discard
    final meldCards = <Card>[];
    for (final meld in proposedMelds) {
      meldCards.addAll(meld);
    }

    // Total should equal hand size
    if (meldCards.length + 1 != hand.length) return false;

    // Validate each meld
    for (final meld in proposedMelds) {
      if (!isValidMeld(meld, roundNumber)) return false;
    }

    // Verify all cards come from hand (with proper duplicate handling)
    final handCopy = List<Card>.from(hand);

    for (final card in meldCards) {
      final idx = handCopy.indexWhere((c) => c == card);
      if (idx == -1) return false;
      handCopy.removeAt(idx);
    }

    // Only discard should remain
    if (handCopy.length != 1) return false;
    if (handCopy.first != discard) return false;

    return true;
  }
}
