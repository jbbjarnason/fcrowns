import 'package:flutter_test/flutter_test.dart';
import 'package:fivecrowns_app/utils/hand_slot_manager.dart';

void main() {
  group('HandSlotManager', () {
    late HandSlotManager manager;

    setUp(() {
      manager = HandSlotManager();
    });

    group('duplicate card handling', () {
      test('displays all cards when hand has duplicates', () {
        // This is the bug that was reported: with two decks, you can have
        // identical cards (e.g., two 7♥). The old code used Set which lost duplicates.
        final hand = ['7H', '7H', '5S', '9D']; // Two 7 of Hearts

        final contents = manager.getSlotContents(hand);

        // All 4 cards should be displayed
        expect(contents.length, 4);
        // No -1 (missing cards)
        expect(contents.where((c) => c == -1).length, 0);
        // All indices 0-3 should be used exactly once
        expect(contents.toSet(), {0, 1, 2, 3});
      });

      test('displays all cards when hand has multiple duplicates', () {
        // Even more duplicates
        final hand = ['7H', '7H', '7H', '5S', '5S'];

        final contents = manager.getSlotContents(hand);

        expect(contents.length, 5);
        expect(contents.where((c) => c == -1).length, 0);
        expect(contents.toSet(), {0, 1, 2, 3, 4});
      });

      test('handles drawing a duplicate card', () {
        // Start with hand of 3 cards
        final initialHand = ['7H', '5S', '9D'];
        manager.getSlotContents(initialHand);

        // Draw a duplicate card (another 7H)
        final afterDraw = ['7H', '5S', '9D', '7H'];
        final contents = manager.getSlotContents(afterDraw);

        // All 4 cards should be displayed
        expect(contents.length, 4);
        expect(contents.where((c) => c == -1).length, 0);
      });

      test('handles discarding one of duplicate cards', () {
        // Start with duplicates
        final initialHand = ['7H', '7H', '5S'];
        manager.getSlotContents(initialHand);

        // Discard one 7H
        final afterDiscard = ['7H', '5S'];
        final contents = manager.getSlotContents(afterDiscard);

        // 2 cards should remain (one slot becomes empty or removed)
        final nonEmpty = contents.where((c) => c != -1).length;
        expect(nonEmpty, 2);
      });
    });

    group('basic functionality', () {
      test('initial hand populates slots', () {
        final hand = ['3H', '5S', '7D'];
        final contents = manager.getSlotContents(hand);

        expect(contents.length, 3);
        expect(contents, [0, 1, 2]);
      });

      test('preserves order after draw', () {
        final initialHand = ['3H', '5S', '7D'];
        manager.getSlotContents(initialHand);

        // Draw a new card (added to end of hand by server)
        final afterDraw = ['3H', '5S', '7D', '9C'];
        final contents = manager.getSlotContents(afterDraw);

        // Original cards should be in same position
        expect(contents.length, 4);
        expect(contents[0], 0); // 3H still first
        expect(contents[1], 1); // 5S still second
        expect(contents[2], 2); // 7D still third
        expect(contents[3], 3); // 9C added at end
      });

      test('handles discard correctly', () {
        final initialHand = ['3H', '5S', '7D'];
        manager.getSlotContents(initialHand);

        // Discard middle card
        final afterDiscard = ['3H', '7D'];
        final contents = manager.getSlotContents(afterDiscard);

        // Should have empty slot or be compacted
        final nonEmpty = contents.where((c) => c != -1).toList();
        expect(nonEmpty.length, 2);
      });

      test('swap slots works', () {
        final hand = ['3H', '5S', '7D'];
        manager.getSlotContents(hand);

        manager.swapSlots(0, 2);

        // After swap, first slot should have 7D (index 2)
        final contents = manager.getSlotContents(hand);
        expect(contents[0], 2); // 7D now first
        expect(contents[2], 0); // 3H now last
      });
    });

    group('edge cases', () {
      test('empty hand', () {
        final contents = manager.getSlotContents([]);
        expect(contents, isEmpty);
      });

      test('single card', () {
        final contents = manager.getSlotContents(['3H']);
        expect(contents, [0]);
      });

      test('all same card (max duplicates)', () {
        // Extreme case: 6 identical cards
        final hand = ['JK', 'JK', 'JK', 'JK', 'JK', 'JK'];
        final contents = manager.getSlotContents(hand);

        expect(contents.length, 6);
        expect(contents.where((c) => c == -1).length, 0);
        expect(contents.toSet(), {0, 1, 2, 3, 4, 5});
      });
    });

    group('empty slot operations', () {
      test('add empty slot after', () {
        final hand = ['3H', '5S', '7D'];
        manager.getSlotContents(hand);

        manager.addEmptySlotAfter(1); // After 5S

        final contents = manager.getSlotContents(hand);
        expect(contents.length, 4);
        expect(contents[2], -1); // Empty slot
      });

      test('remove empty slot', () {
        final hand = ['3H', '5S', '7D'];
        manager.getSlotContents(hand);
        manager.addEmptySlotAfter(1);

        manager.removeEmptySlot(2); // Remove the empty slot

        final contents = manager.getSlotContents(hand);
        expect(contents.length, 3);
        expect(contents.where((c) => c == -1).length, 0);
      });

      test('cannot remove non-empty slot', () {
        final hand = ['3H', '5S', '7D'];
        manager.getSlotContents(hand);

        manager.removeEmptySlot(1); // Try to remove 5S slot

        final contents = manager.getSlotContents(hand);
        expect(contents.length, 3); // Still 3 slots
      });
    });
  });
}
