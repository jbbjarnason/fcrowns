# Rule Notes

This document captures any ambiguous rule interpretations made during implementation.

## Meld Validation

1. **Runs with wilds**: Wilds and jokers can substitute for any card in a run. Multiple wilds/jokers can be adjacent (e.g., 3-W-W-6 is valid if wilds represent 4 and 5).

2. **Books with wilds**: In a book (same rank), wilds substitute for cards of that rank. All natural cards in a book must have different suits.

3. **Minimum meld size**: All melds require a minimum of 3 cards.

## Going Out

1. **Final discard requirement**: To go out, a player must be able to meld their entire hand AND still have exactly one card remaining to discard.

2. **Final turn**: After someone goes out, all other players get exactly one more turn. During this final turn, players cannot add cards to other players' melds.

## Deck Construction

1. **Two 58-card decks**: Each deck contains 5 suits (stars, hearts, spades, diamonds, clubs) × 11 ranks (3-K) = 55 cards + 3 jokers = 58 cards. Total: 116 cards.

## Scoring

1. **Unmelded cards**: Only cards remaining in hand after final meld attempt are scored.
2. **Wild card scoring**: The rotating wild for the current round scores 20 points, regardless of face value.
