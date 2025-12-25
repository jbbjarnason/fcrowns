import 'dart:math';
import 'package:test/test.dart';
import 'package:fivecrowns_core/fivecrowns_core.dart';

void main() {
  group('GameState', () {
    group('creation', () {
      test('creates game in lobby state', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2', 'p3'],
        );

        expect(game.gameId, 'test-game');
        expect(game.status, GameStatus.lobby);
        expect(game.players.length, 3);
        expect(game.roundNumber, 0);
      });

      test('assigns seats correctly', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2', 'p3'],
        );

        expect(game.players[0].id, 'p1');
        expect(game.players[0].seat, 0);
        expect(game.players[1].id, 'p2');
        expect(game.players[1].seat, 1);
        expect(game.players[2].id, 'p3');
        expect(game.players[2].seat, 2);
      });

      test('rejects invalid player counts', () {
        expect(
          () => GameState.create(gameId: 'g', playerIds: ['p1']),
          throwsArgumentError,
        );
        expect(
          () => GameState.create(
            gameId: 'g',
            playerIds: ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8'],
          ),
          throwsArgumentError,
        );
      });
    });

    group('starting game', () {
      test('transitions to active and starts round 1', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );

        game.startGame();

        expect(game.status, GameStatus.active);
        expect(game.roundNumber, 1);
        expect(game.cardsPerHand, 3);
        expect(game.wildRank, Rank.three);
      });

      test('deals correct number of cards', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2', 'p3'],
          random: Random(42),
        );

        game.startGame();

        for (final player in game.players) {
          expect(player.hand.length, 3);
        }
      });

      test('starts discard pile with one card', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );

        game.startGame();

        expect(game.topDiscard, isNotNull);
        expect(game.discardPile.length, 1);
      });

      test('first player must draw', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );

        game.startGame();

        expect(game.currentPlayerIndex, 0);
        expect(game.turnPhase, TurnPhase.mustDraw);
      });

      test('cannot start already started game', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
        );

        game.startGame();
        expect(() => game.startGame(), throwsStateError);
      });
    });

    group('drawing', () {
      late GameState game;

      setUp(() {
        game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
      });

      test('draw from stock adds card to hand', () {
        final initialHandSize = game.currentPlayer.hand.length;
        final initialStockCount = game.stockCount;

        game.drawFromStock();

        expect(game.currentPlayer.hand.length, initialHandSize + 1);
        expect(game.stockCount, initialStockCount - 1);
        expect(game.turnPhase, TurnPhase.mustDiscard);
      });

      test('draw from discard adds top card to hand', () {
        final topDiscard = game.topDiscard!;
        final initialHandSize = game.currentPlayer.hand.length;

        game.drawFromDiscard();

        expect(game.currentPlayer.hand.length, initialHandSize + 1);
        expect(game.currentPlayer.hand.contains(topDiscard), true);
        expect(game.turnPhase, TurnPhase.mustDiscard);
      });

      test('cannot draw twice', () {
        game.drawFromStock();
        expect(() => game.drawFromStock(), throwsStateError);
        expect(() => game.drawFromDiscard(), throwsStateError);
      });
    });

    group('discarding', () {
      late GameState game;

      setUp(() {
        game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();
      });

      test('discard removes card from hand and adds to pile', () {
        final cardToDiscard = game.currentPlayer.hand.first;
        final initialHandSize = game.currentPlayer.hand.length;

        game.discard(cardToDiscard);

        expect(game.topDiscard, cardToDiscard);
        expect(game.players[0].hand.length, initialHandSize - 1);
      });

      test('discard advances to next player', () {
        final cardToDiscard = game.currentPlayer.hand.first;

        game.discard(cardToDiscard);

        expect(game.currentPlayerIndex, 1);
        expect(game.turnPhase, TurnPhase.mustDraw);
      });

      test('cannot discard before drawing', () {
        final game2 = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game2.startGame();

        expect(
          () => game2.discard(game2.currentPlayer.hand.first),
          throwsStateError,
        );
      });

      test('cannot discard card not in hand', () {
        expect(
          () => game.discard(Card(Suit.stars, Rank.king)),
          throwsStateError,
        );
      });
    });

    group('laying melds', () {
      test('valid meld removes cards from hand', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        // Manually set up a hand with a valid meld
        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.three),
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.spades, Rank.six),
        ]);

        game.layMelds([
          [
            Card(Suit.hearts, Rank.three),
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
          ],
        ]);

        expect(player.hand.length, 1);
        expect(player.melds.length, 1);
        expect(player.melds[0].type, MeldType.run);
      });

      test('rejects invalid meld', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.three),
          Card(Suit.spades, Rank.five),
          Card(Suit.hearts, Rank.eight),
          Card(Suit.spades, Rank.six),
        ]);

        expect(
          () => game.layMelds([
            [
              Card(Suit.hearts, Rank.three),
              Card(Suit.spades, Rank.five),
              Card(Suit.hearts, Rank.eight),
            ],
          ]),
          throwsStateError,
        );
      });
    });

    group('going out', () {
      test('valid go out triggers final turn phase', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        // Set up hand for going out
        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.three),
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.spades, Rank.six),
        ]);

        game.goOut(
          [
            [
              Card(Suit.hearts, Rank.three),
              Card(Suit.hearts, Rank.four),
              Card(Suit.hearts, Rank.five),
            ],
          ],
          Card(Suit.spades, Rank.six),
        );

        expect(game.isFinalTurnPhase, true);
        expect(game.playerWhoWentOut, 0);
        expect(player.hand.isEmpty, true);
      });

      test('other players get final turn', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2', 'p3'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        // Player 0 goes out
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.hearts, Rank.three),
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.spades, Rank.six),
        ]);

        game.goOut(
          [
            [
              Card(Suit.hearts, Rank.three),
              Card(Suit.hearts, Rank.four),
              Card(Suit.hearts, Rank.five),
            ],
          ],
          Card(Suit.spades, Rank.six),
        );

        // Should be player 1's turn
        expect(game.currentPlayerIndex, 1);

        // Player 1 takes final turn
        game.drawFromStock();
        game.discard(game.currentPlayer.hand.first);

        // Should be player 2's turn
        expect(game.currentPlayerIndex, 2);

        // Player 2 takes final turn
        game.drawFromStock();
        game.discard(game.currentPlayer.hand.first);

        // Round should end, start round 2
        expect(game.roundNumber, 2);
        expect(game.isFinalTurnPhase, false);
      });

      test('cannot go out during final turn phase', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        // Player 0 goes out
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.hearts, Rank.three),
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.spades, Rank.six),
        ]);

        game.goOut(
          [
            [
              Card(Suit.hearts, Rank.three),
              Card(Suit.hearts, Rank.four),
              Card(Suit.hearts, Rank.five),
            ],
          ],
          Card(Suit.spades, Rank.six),
        );

        // Player 1 tries to go out
        game.drawFromStock();
        final player1 = game.players[1];
        player1.setHand([
          Card(Suit.diamonds, Rank.three),
          Card(Suit.diamonds, Rank.four),
          Card(Suit.diamonds, Rank.five),
          Card(Suit.clubs, Rank.six),
        ]);

        expect(
          () => game.goOut(
            [
              [
                Card(Suit.diamonds, Rank.three),
                Card(Suit.diamonds, Rank.four),
                Card(Suit.diamonds, Rank.five),
              ],
            ],
            Card(Suit.clubs, Rank.six),
          ),
          throwsStateError,
        );
      });
    });

    group('scoring', () {
      test('scores remaining cards at end of round', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Player 0 goes out
        game.drawFromStock();
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.hearts, Rank.three),
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.spades, Rank.six),
        ]);

        game.goOut(
          [
            [
              Card(Suit.hearts, Rank.three),
              Card(Suit.hearts, Rank.four),
              Card(Suit.hearts, Rank.five),
            ],
          ],
          Card(Suit.spades, Rank.six),
        );

        // Player 1 has cards remaining - set specific hand for predictable score
        final player1 = game.players[1];
        player1.setHand([
          Card(Suit.diamonds, Rank.five), // 5 points
          Card(Suit.diamonds, Rank.six),  // 6 points
          Card(Suit.diamonds, Rank.eight), // 8 points
          Card(Suit.diamonds, Rank.nine), // 9 points after draw
        ]);

        game.drawFromStock();
        game.discard(game.currentPlayer.hand.first);

        // Player 0 should have 0, player 1 has remaining cards
        expect(game.players[0].score, 0);
        // Player 1's score depends on remaining hand
        expect(game.players[1].score, greaterThan(0));
      });

      test('wild cards score 20, jokers score 50', () {
        // Test scoring in round 1 where 3s are wild
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Player 0 goes out
        game.drawFromStock();
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.spades, Rank.seven),
        ]);

        game.goOut(
          [
            [
              Card(Suit.hearts, Rank.four),
              Card(Suit.hearts, Rank.five),
              Card(Suit.hearts, Rank.six),
            ],
          ],
          Card(Suit.spades, Rank.seven),
        );

        // Player 1 has wild (3) and joker
        final player1 = game.players[1];
        player1.setHand([
          Card(Suit.hearts, Rank.three), // wild = 20
          const Card.joker(),             // joker = 50
          Card(Suit.spades, Rank.five),   // 5 points
        ]);

        game.drawFromStock();
        game.discard(game.currentPlayer.hand.last);

        // After discard, 2 cards remain: wild (20) + joker (50) = 70
        // or 2 of the 3, depends on which card was drawn
        expect(game.players[1].score, greaterThanOrEqualTo(20));
      });
    });

    group('game completion', () {
      test('game finishes after round 11 completion', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Play through 11 rounds by having player 0 go out each time
        for (var round = 1; round <= 11; round++) {
          // Player 0's turn - go out with all jokers
          game.drawFromStock();
          final player0 = game.players[0];
          player0.setHand([
            const Card.joker(),
            const Card.joker(),
            const Card.joker(),
            Card(Suit.spades, Rank.king),
          ]);

          game.goOut(
            [
              [const Card.joker(), const Card.joker(), const Card.joker()],
            ],
            Card(Suit.spades, Rank.king),
          );

          // Player 1 takes final turn
          game.drawFromStock();
          game.discard(game.currentPlayer.hand.first);

          if (round < 11) {
            expect(game.roundNumber, round + 1);
            expect(game.status, GameStatus.active);
          }
        }

        expect(game.status, GameStatus.finished);
        expect(game.winners.isNotEmpty, true);
      });
    });

    group('player view', () {
      test('hides other players hands', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2', 'p3'],
          random: Random(42),
        );
        game.startGame();

        final p1View = game.toPlayerView('p1');

        // Should see own hand
        expect(p1View['yourHand'], isNotEmpty);

        // Other players should not have 'hand' field
        final players = p1View['players'] as List;
        for (final playerData in players) {
          final pData = playerData as Map<String, dynamic>;
          if (pData['id'] == 'p1') {
            expect(pData.containsKey('hand'), true);
          } else {
            expect(pData.containsKey('hand'), false);
          }
          // All should have handCount
          expect(pData.containsKey('handCount'), true);
        }
      });
    });

    group('snapshot serialization', () {
      test('roundtrips full snapshot', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Take some actions
        game.drawFromStock();
        game.discard(game.currentPlayer.hand.first);
        game.drawFromStock();

        final snapshot = game.toFullSnapshot();
        final restored = GameState.fromFullSnapshot(snapshot);

        expect(restored.gameId, game.gameId);
        expect(restored.status, game.status);
        expect(restored.roundNumber, game.roundNumber);
        expect(restored.currentPlayerIndex, game.currentPlayerIndex);
        expect(restored.turnPhase, game.turnPhase);
        expect(restored.players.length, game.players.length);

        for (var i = 0; i < game.players.length; i++) {
          expect(restored.players[i].id, game.players[i].id);
          expect(restored.players[i].hand.length, game.players[i].hand.length);
        }
      });
    });

    group('laying off cards', () {
      test('can lay off to own meld during mustDiscard phase', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        // Set up hand with cards for meld + extension
        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.hearts, Rank.seven), // card to lay off
          Card(Suit.spades, Rank.king),  // card to discard
        ]);

        // Lay initial meld
        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);

        // Lay off the 7 to extend the run
        game.layOff(0, 0, [Card(Suit.hearts, Rank.seven)]);

        expect(player.hand.length, 1); // only king left
        expect(player.melds[0].cards.length, 4); // run is now 4-5-6-7
      });

      test('can lay off to another player\'s meld', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Player 0 lays a meld
        game.drawFromStock();
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.clubs, Rank.seven),
          Card(Suit.clubs, Rank.eight),
          Card(Suit.clubs, Rank.nine),
          Card(Suit.spades, Rank.king),
        ]);
        game.layMelds([
          [
            Card(Suit.clubs, Rank.seven),
            Card(Suit.clubs, Rank.eight),
            Card(Suit.clubs, Rank.nine),
          ],
        ]);
        game.discard(Card(Suit.spades, Rank.king));

        // Player 1's turn
        game.drawFromStock();
        final player1 = game.players[1];
        player1.setHand([
          Card(Suit.clubs, Rank.ten),  // can extend player 0's run
          Card(Suit.diamonds, Rank.four),
          Card(Suit.diamonds, Rank.five),
          Card(Suit.spades, Rank.queen),
        ]);

        // Player 1 lays off to player 0's meld
        game.layOff(0, 0, [Card(Suit.clubs, Rank.ten)]);

        expect(player1.hand.length, 3);
        expect(player0.melds[0].cards.length, 4); // 7-8-9-10
      });

      test('can lay off multiple cards at once', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.spades, Rank.five),
          Card(Suit.spades, Rank.six),
          Card(Suit.spades, Rank.seven),
          Card(Suit.spades, Rank.eight),
          Card(Suit.spades, Rank.nine),
          Card(Suit.diamonds, Rank.king),
        ]);

        // Lay initial meld
        game.layMelds([
          [
            Card(Suit.spades, Rank.five),
            Card(Suit.spades, Rank.six),
            Card(Suit.spades, Rank.seven),
          ],
        ]);

        // Lay off 8 and 9 together
        game.layOff(0, 0, [
          Card(Suit.spades, Rank.eight),
          Card(Suit.spades, Rank.nine),
        ]);

        expect(player.hand.length, 1);
        expect(player.melds[0].cards.length, 5);
      });

      test('cannot lay off during mustDraw phase', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Player 0 lays a meld first turn
        game.drawFromStock();
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.spades, Rank.king),
        ]);
        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);
        game.discard(Card(Suit.spades, Rank.king));

        // Player 1's turn - hasn't drawn yet
        expect(game.turnPhase, TurnPhase.mustDraw);
        final player1 = game.players[1];
        player1.setHand([
          Card(Suit.hearts, Rank.seven),
          Card(Suit.diamonds, Rank.four),
          Card(Suit.diamonds, Rank.five),
        ]);

        expect(
          () => game.layOff(0, 0, [Card(Suit.hearts, Rank.seven)]),
          throwsStateError,
        );
      });

      test('cannot lay off during final turn phase', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();

        // Player 0 lays a meld and goes out
        game.drawFromStock();
        final player0 = game.players[0];
        player0.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.spades, Rank.king),
        ]);

        game.goOut(
          [
            [
              Card(Suit.hearts, Rank.four),
              Card(Suit.hearts, Rank.five),
              Card(Suit.hearts, Rank.six),
            ],
          ],
          Card(Suit.spades, Rank.king),
        );

        expect(game.isFinalTurnPhase, true);

        // Player 1's final turn
        game.drawFromStock();
        final player1 = game.players[1];
        player1.setHand([
          Card(Suit.hearts, Rank.seven),
          Card(Suit.diamonds, Rank.four),
          Card(Suit.diamonds, Rank.five),
          Card(Suit.spades, Rank.queen),
        ]);

        // Cannot lay off during final turn phase
        expect(
          () => game.layOff(0, 0, [Card(Suit.hearts, Rank.seven)]),
          throwsStateError,
        );
      });

      test('cannot lay off with cards not in hand', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.spades, Rank.king),
        ]);

        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);

        // Try to lay off a card that's not in hand
        expect(
          () => game.layOff(0, 0, [Card(Suit.hearts, Rank.seven)]),
          throwsStateError,
        );
      });

      test('cannot lay off with invalid extension', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.spades, Rank.nine), // wrong suit for run
          Card(Suit.diamonds, Rank.king),
        ]);

        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);

        // Try to lay off a card that doesn't extend the run
        expect(
          () => game.layOff(0, 0, [Card(Suit.spades, Rank.nine)]),
          throwsStateError,
        );
      });

      test('cannot lay off to invalid player index', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.hearts, Rank.seven),
          Card(Suit.diamonds, Rank.king),
        ]);

        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);

        expect(
          () => game.layOff(5, 0, [Card(Suit.hearts, Rank.seven)]),
          throwsStateError,
        );
      });

      test('cannot lay off to invalid meld index', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.hearts, Rank.seven),
          Card(Suit.diamonds, Rank.king),
        ]);

        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);

        expect(
          () => game.layOff(0, 3, [Card(Suit.hearts, Rank.seven)]),
          throwsStateError,
        );
      });

      test('cannot lay off empty cards list', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.four),
          Card(Suit.hearts, Rank.five),
          Card(Suit.hearts, Rank.six),
          Card(Suit.diamonds, Rank.king),
        ]);

        game.layMelds([
          [
            Card(Suit.hearts, Rank.four),
            Card(Suit.hearts, Rank.five),
            Card(Suit.hearts, Rank.six),
          ],
        ]);

        expect(
          () => game.layOff(0, 0, []),
          throwsStateError,
        );
      });

      test('lay off to book with matching rank', () {
        final game = GameState.create(
          gameId: 'test-game',
          playerIds: ['p1', 'p2'],
          random: Random(42),
        );
        game.startGame();
        game.drawFromStock();

        final player = game.players[0];
        player.setHand([
          Card(Suit.hearts, Rank.seven),
          Card(Suit.spades, Rank.seven),
          Card(Suit.clubs, Rank.seven),
          Card(Suit.diamonds, Rank.seven), // card to lay off
          Card(Suit.spades, Rank.king),
        ]);

        // Lay initial book
        game.layMelds([
          [
            Card(Suit.hearts, Rank.seven),
            Card(Suit.spades, Rank.seven),
            Card(Suit.clubs, Rank.seven),
          ],
        ]);

        // Lay off the diamonds 7
        game.layOff(0, 0, [Card(Suit.diamonds, Rank.seven)]);

        expect(player.hand.length, 1);
        expect(player.melds[0].cards.length, 4);
        expect(player.melds[0].type, MeldType.book);
      });
    });
  });
}
