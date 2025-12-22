import 'dart:math';
import 'package:test/test.dart';
import 'package:fivecrowns_core/fivecrowns_core.dart';

void main() {
  group('Deck', () {
    test('has 116 cards (2 decks of 58)', () {
      final deck = Deck.create();
      expect(deck.totalCards, 116);
      expect(deck.remainingCards, 116);
    });

    test('contains correct card distribution', () {
      final deck = Deck.create();
      final cards = <Card>[];
      while (!deck.isEmpty) {
        cards.add(deck.draw());
      }

      // Count jokers: 6 total (3 per deck × 2 decks)
      final jokers = cards.where((c) => c.isJoker).length;
      expect(jokers, 6);

      // Count each suit/rank combo: 2 each (1 per deck × 2 decks)
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          final count = cards.where((c) => c.suit == suit && c.rank == rank).length;
          expect(count, 2, reason: 'Expected 2 copies of ${rank.code}${suit.code}');
        }
      }
    });

    test('draw removes cards from deck', () {
      final deck = Deck.create();
      expect(deck.remainingCards, 116);

      deck.draw();
      expect(deck.remainingCards, 115);

      deck.drawMany(5);
      expect(deck.remainingCards, 110);
    });

    test('draw throws when empty', () {
      final deck = Deck.create();
      deck.drawMany(116);
      expect(deck.isEmpty, true);
      expect(() => deck.draw(), throwsStateError);
    });

    test('shuffle randomizes order', () {
      final deck1 = Deck.create();
      final deck2 = Deck.create();

      deck1.shuffle(Random(42));
      deck2.shuffle(Random(99));

      // Draw 10 cards from each and compare
      final cards1 = deck1.drawMany(10);
      final cards2 = deck2.drawMany(10);

      // Very unlikely to be identical with different seeds
      var identical = true;
      for (var i = 0; i < 10; i++) {
        if (cards1[i] != cards2[i]) {
          identical = false;
          break;
        }
      }
      expect(identical, false);
    });

    test('shuffle is deterministic with same seed', () {
      final deck1 = Deck.create();
      final deck2 = Deck.create();

      deck1.shuffle(Random(42));
      deck2.shuffle(Random(42));

      final cards1 = deck1.drawMany(10);
      final cards2 = deck2.drawMany(10);

      for (var i = 0; i < 10; i++) {
        expect(cards1[i], cards2[i]);
      }
    });

    test('reset restores cards', () {
      final deck = Deck.create();
      deck.drawMany(50);
      expect(deck.remainingCards, 66);

      final newCards = [
        Card(Suit.hearts, Rank.seven),
        Card(Suit.spades, Rank.queen),
      ];
      deck.reset(newCards);
      expect(deck.remainingCards, 2);
    });
  });
}
