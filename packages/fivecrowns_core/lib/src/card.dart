/// Suits in Five Crowns deck.
enum Suit {
  stars,
  hearts,
  spades,
  diamonds,
  clubs;

  String get code => switch (this) {
        Suit.stars => 'T',
        Suit.hearts => 'H',
        Suit.spades => 'S',
        Suit.diamonds => 'D',
        Suit.clubs => 'C',
      };

  static Suit fromCode(String code) => switch (code) {
        'T' => Suit.stars,
        'H' => Suit.hearts,
        'S' => Suit.spades,
        'D' => Suit.diamonds,
        'C' => Suit.clubs,
        _ => throw ArgumentError('Invalid suit code: $code'),
      };
}

/// Ranks in Five Crowns (3-K, no Aces or 2s).
enum Rank {
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(11),
  queen(12),
  king(13);

  const Rank(this.value);
  final int value;

  String get code => switch (this) {
        Rank.three => '3',
        Rank.four => '4',
        Rank.five => '5',
        Rank.six => '6',
        Rank.seven => '7',
        Rank.eight => '8',
        Rank.nine => '9',
        Rank.ten => '10',
        Rank.jack => 'J',
        Rank.queen => 'Q',
        Rank.king => 'K',
      };

  static Rank fromCode(String code) => switch (code) {
        '3' => Rank.three,
        '4' => Rank.four,
        '5' => Rank.five,
        '6' => Rank.six,
        '7' => Rank.seven,
        '8' => Rank.eight,
        '9' => Rank.nine,
        '10' => Rank.ten,
        'J' => Rank.jack,
        'Q' => Rank.queen,
        'K' => Rank.king,
        _ => throw ArgumentError('Invalid rank code: $code'),
      };

  /// Returns the rank that corresponds to a card count (for wild determination).
  /// Round 1 deals 3 cards -> 3s wild, Round 11 deals 13 cards -> Kings wild.
  static Rank fromCardCount(int cardCount) {
    if (cardCount < 3 || cardCount > 13) {
      throw ArgumentError('Card count must be between 3 and 13');
    }
    return Rank.values.firstWhere((r) => r.value == cardCount);
  }
}

/// Represents a card in Five Crowns.
/// Cards can be regular (suit + rank) or jokers.
class Card {
  final Suit? suit;
  final Rank? rank;
  final bool isJoker;

  /// Creates a regular card with a suit and rank.
  const Card(Suit this.suit, Rank this.rank)
      : isJoker = false;

  /// Creates a joker card.
  const Card.joker()
      : suit = null,
        rank = null,
        isJoker = true;

  /// Returns true if this card is wild in the given round.
  /// Jokers are always wild. The rotating wild rank equals cards dealt.
  bool isWild(int roundNumber) {
    if (isJoker) return true;
    // Round 1 = 3 cards = 3s wild, Round 11 = 13 cards = Kings wild
    final wildRank = Rank.fromCardCount(roundNumber + 2);
    return rank == wildRank;
  }

  /// Returns the point value of this card.
  /// Regular scoring: face value for number cards, J=11, Q=12, K=13.
  /// If this card is the rotating wild, it scores 20.
  /// Jokers always score 50.
  int score(int roundNumber) {
    if (isJoker) return 50;
    if (isWild(roundNumber)) return 20;
    return rank!.value;
  }

  /// Encodes this card to a compact string format.
  /// Examples: "7S", "10T", "QH", "X"
  String encode() {
    if (isJoker) return 'X';
    return '${rank!.code}${suit!.code}';
  }

  /// Decodes a card from its compact string format.
  static Card decode(String code) {
    if (code == 'X') return const Card.joker();

    // Extract rank and suit from code
    final suitCode = code[code.length - 1];
    final rankCode = code.substring(0, code.length - 1);

    return Card(Suit.fromCode(suitCode), Rank.fromCode(rankCode));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          suit == other.suit &&
          rank == other.rank &&
          isJoker == other.isJoker;

  @override
  int get hashCode => Object.hash(suit, rank, isJoker);

  @override
  String toString() => encode();
}
