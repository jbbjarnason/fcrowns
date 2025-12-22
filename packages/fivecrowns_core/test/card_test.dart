import 'package:test/test.dart';
import 'package:fivecrowns_core/fivecrowns_core.dart';

void main() {
  group('Card', () {
    test('creates regular cards with suit and rank', () {
      final card = Card(Suit.hearts, Rank.seven);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.seven);
      expect(card.isJoker, false);
    });

    test('creates joker cards', () {
      const joker = Card.joker();
      expect(joker.suit, isNull);
      expect(joker.rank, isNull);
      expect(joker.isJoker, true);
    });

    group('encoding', () {
      test('encodes regular cards correctly', () {
        expect(Card(Suit.spades, Rank.seven).encode(), '7S');
        expect(Card(Suit.hearts, Rank.queen).encode(), 'QH');
        expect(Card(Suit.diamonds, Rank.ten).encode(), '10D');
        expect(Card(Suit.clubs, Rank.king).encode(), 'KC');
        expect(Card(Suit.stars, Rank.three).encode(), '3T');
      });

      test('encodes joker as X', () {
        expect(const Card.joker().encode(), 'X');
      });

      test('decodes cards correctly', () {
        expect(Card.decode('7S'), Card(Suit.spades, Rank.seven));
        expect(Card.decode('QH'), Card(Suit.hearts, Rank.queen));
        expect(Card.decode('10D'), Card(Suit.diamonds, Rank.ten));
        expect(Card.decode('KC'), Card(Suit.clubs, Rank.king));
        expect(Card.decode('3T'), Card(Suit.stars, Rank.three));
        expect(Card.decode('X'), const Card.joker());
      });

      test('roundtrips encoding', () {
        for (final suit in Suit.values) {
          for (final rank in Rank.values) {
            final card = Card(suit, rank);
            expect(Card.decode(card.encode()), card);
          }
        }
        expect(Card.decode(const Card.joker().encode()), const Card.joker());
      });
    });

    group('wild detection', () {
      test('jokers are always wild', () {
        const joker = Card.joker();
        for (var round = 1; round <= 11; round++) {
          expect(joker.isWild(round), true);
        }
      });

      test('3s are wild in round 1', () {
        expect(Card(Suit.hearts, Rank.three).isWild(1), true);
        expect(Card(Suit.hearts, Rank.four).isWild(1), false);
      });

      test('rotating wild follows round number', () {
        // Round 1: 3 cards, 3s wild
        expect(Card(Suit.hearts, Rank.three).isWild(1), true);
        // Round 5: 7 cards, 7s wild
        expect(Card(Suit.hearts, Rank.seven).isWild(5), true);
        expect(Card(Suit.hearts, Rank.six).isWild(5), false);
        // Round 11: 13 cards, Ks wild
        expect(Card(Suit.hearts, Rank.king).isWild(11), true);
        expect(Card(Suit.hearts, Rank.queen).isWild(11), false);
      });
    });

    group('scoring', () {
      test('number cards score face value', () {
        expect(Card(Suit.hearts, Rank.three).score(5), 3);
        expect(Card(Suit.hearts, Rank.ten).score(5), 10);
      });

      test('face cards score correctly', () {
        expect(Card(Suit.hearts, Rank.jack).score(5), 11);
        expect(Card(Suit.hearts, Rank.queen).score(5), 12);
        expect(Card(Suit.hearts, Rank.king).score(5), 13);
      });

      test('rotating wild scores 20', () {
        // Round 5: 7s are wild, score 20
        expect(Card(Suit.hearts, Rank.seven).score(5), 20);
        // Round 11: Ks are wild, score 20
        expect(Card(Suit.hearts, Rank.king).score(11), 20);
      });

      test('jokers always score 50', () {
        for (var round = 1; round <= 11; round++) {
          expect(const Card.joker().score(round), 50);
        }
      });
    });

    group('equality', () {
      test('equal cards are equal', () {
        expect(Card(Suit.hearts, Rank.seven), Card(Suit.hearts, Rank.seven));
        expect(const Card.joker(), const Card.joker());
      });

      test('different cards are not equal', () {
        expect(
          Card(Suit.hearts, Rank.seven) == Card(Suit.spades, Rank.seven),
          false,
        );
        expect(
          Card(Suit.hearts, Rank.seven) == const Card.joker(),
          false,
        );
      });
    });
  });

  group('Rank', () {
    test('fromCardCount maps correctly', () {
      expect(Rank.fromCardCount(3), Rank.three);
      expect(Rank.fromCardCount(7), Rank.seven);
      expect(Rank.fromCardCount(13), Rank.king);
    });

    test('fromCardCount throws for invalid counts', () {
      expect(() => Rank.fromCardCount(2), throwsArgumentError);
      expect(() => Rank.fromCardCount(14), throwsArgumentError);
    });
  });
}
