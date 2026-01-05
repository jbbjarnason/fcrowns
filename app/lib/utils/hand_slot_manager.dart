/// Manages card slot ordering in the hand display.
/// Handles duplicate cards (Five Crowns uses two decks).
class HandSlotManager {
  final List<String?> _slots = [];

  List<String?> get slots => List.unmodifiable(_slots);

  /// Update slots when hand changes.
  /// Preserves user's custom ordering and empty slots.
  void updateSlots(List<String> hand) {
    // Count how many of each card are in the hand
    final handCounts = <String, int>{};
    for (final card in hand) {
      handCounts[card] = (handCounts[card] ?? 0) + 1;
    }

    // Track how many of each card we've placed
    final placedCounts = <String, int>{};

    // Replace cards that are no longer in hand with null (empty slot)
    // Keep cards that are still in hand (up to the count available)
    for (int i = 0; i < _slots.length; i++) {
      final card = _slots[i];
      if (card != null) {
        final placed = placedCounts[card] ?? 0;
        final available = handCounts[card] ?? 0;
        if (placed < available) {
          placedCounts[card] = placed + 1;
        } else {
          _slots[i] = null; // Card was discarded/laid or extra duplicate
        }
      }
    }

    // Add new cards (drawn cards) to empty slots first, then append
    for (final card in hand) {
      final placed = placedCounts[card] ?? 0;
      final available = handCounts[card] ?? 0;
      if (placed < available) {
        // Try to find an empty slot
        final emptyIndex = _slots.indexOf(null);
        if (emptyIndex != -1) {
          _slots[emptyIndex] = card;
        } else {
          _slots.add(card);
        }
        placedCounts[card] = placed + 1;
      }
    }

    // Trim trailing empty slots (but keep internal ones)
    while (_slots.isNotEmpty && _slots.last == null) {
      _slots.removeLast();
    }
  }

  /// Get list of slot contents (card index or -1 for empty).
  /// Handles duplicate cards by tracking which indices are already used.
  List<int> getSlotContents(List<String> hand) {
    updateSlots(hand);

    final usedIndices = <int>{};
    final result = <int>[];

    for (final card in _slots) {
      if (card == null) {
        result.add(-1);
      } else {
        // Find the next available index for this card
        int idx = -1;
        for (int i = 0; i < hand.length; i++) {
          if (hand[i] == card && !usedIndices.contains(i)) {
            idx = i;
            break;
          }
        }
        if (idx != -1) {
          usedIndices.add(idx);
          result.add(idx);
        } else {
          // Card not found in hand (shouldn't happen after updateSlots)
          result.add(-1);
        }
      }
    }

    return result;
  }

  /// Swap two slots (visual reordering).
  void swapSlots(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _slots.length) return;
    if (toIndex < 0 || toIndex >= _slots.length) return;

    final temp = _slots[fromIndex];
    _slots[fromIndex] = _slots[toIndex];
    _slots[toIndex] = temp;
  }

  /// Add an empty slot after the given index.
  void addEmptySlotAfter(int slotIndex) {
    if (slotIndex < -1 || slotIndex >= _slots.length) return;
    _slots.insert(slotIndex + 1, null);
  }

  /// Remove empty slot at index (only if empty).
  void removeEmptySlot(int slotIndex) {
    if (slotIndex >= 0 && slotIndex < _slots.length && _slots[slotIndex] == null) {
      _slots.removeAt(slotIndex);
    }
  }

  /// Get current slot count.
  int get length => _slots.length;

  /// Clear all slots.
  void clear() {
    _slots.clear();
  }
}
