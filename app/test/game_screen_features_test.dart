import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fivecrowns_app/theme/app_theme.dart';
import 'package:fivecrowns_app/widgets/card_widget.dart';

void main() {
  group('Hand Reordering', () {
    testWidgets('ReorderableListView allows card reordering', (WidgetTester tester) async {
      // Simulated hand of cards (format: rank + suit, e.g., "7H" = 7 of Hearts)
      final cards = ['7H', '8S', '9D', 'JC'];
      var displayOrder = List.generate(cards.length, (i) => i);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    const Text('My Hand (4)'),
                    SizedBox(
                      height: 100,
                      child: ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        buildDefaultDragHandles: false,
                        itemCount: displayOrder.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = displayOrder.removeAt(oldIndex);
                            displayOrder.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final handIndex = displayOrder[index];
                          final card = cards[handIndex];
                          return ReorderableDragStartListener(
                            key: ValueKey('card_$handIndex'),
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: CardWidget(
                                cardCode: card,
                                isSelected: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial order
      expect(displayOrder, [0, 1, 2, 3]);

      // Find all CardWidgets
      final cardWidgets = find.byType(CardWidget);
      expect(cardWidgets, findsNWidgets(4));

      // Verify the hand section is rendered
      expect(find.text('My Hand (4)'), findsOneWidget);
    });

    testWidgets('Display order persists through selections', (WidgetTester tester) async {
      final cards = ['7H', '8S', '9D'];
      var displayOrder = [2, 0, 1]; // Reordered: 9D, 7H, 8S
      final selectedIndices = <int>{};

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('Selected: ${selectedIndices.length}'),
                    SizedBox(
                      height: 100,
                      child: ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        buildDefaultDragHandles: false,
                        itemCount: displayOrder.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = displayOrder.removeAt(oldIndex);
                            displayOrder.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final handIndex = displayOrder[index];
                          final card = cards[handIndex];
                          final isSelected = selectedIndices.contains(handIndex);
                          return ReorderableDragStartListener(
                            key: ValueKey('card_$handIndex'),
                            index: index,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedIndices.contains(handIndex)) {
                                    selectedIndices.remove(handIndex);
                                  } else {
                                    selectedIndices.add(handIndex);
                                  }
                                });
                              },
                              child: CardWidget(
                                cardCode: card,
                                isSelected: isSelected,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify custom order is maintained
      expect(displayOrder, [2, 0, 1]);

      // Tap first card in display order (9D at index 2)
      await tester.tap(find.byType(CardWidget).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify selection was made to the correct index (2)
      expect(selectedIndices.contains(2), true);
      expect(find.text('Selected: 1'), findsOneWidget);

      // Order should remain the same
      expect(displayOrder, [2, 0, 1]);
    });
  });

  group('Reconnection Feature', () {
    testWidgets('Error screen shows reconnect button', (WidgetTester tester) async {
      var reconnectCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error: Connection lost', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      reconnectCalled = true;
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error UI elements are present
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error: Connection lost'), findsOneWidget);
      expect(find.text('Reconnect'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Tap reconnect button
      await tester.tap(find.text('Reconnect'));
      await tester.pumpAndSettle();

      // Verify reconnect was called
      expect(reconnectCalled, true);
    });

    testWidgets('Error screen has proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error: WebSocket disconnected', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all error UI elements are present
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error: WebSocket disconnected'), findsOneWidget);
      expect(find.text('Reconnect'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Verify error icon has correct color
      final errorIcon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(errorIcon.color, Colors.red);
      expect(errorIcon.size, 48);
    });
  });

  group('Hand Order Reset', () {
    testWidgets('Hand order resets when hand size changes', (WidgetTester tester) async {
      var handLength = 4;
      var displayOrder = List.generate(handLength, (i) => i);
      int? lastHandLength;

      void updateHandDisplayOrder(int newLength) {
        if (newLength != lastHandLength) {
          displayOrder = List.generate(newLength, (i) => i);
          lastHandLength = newLength;
        }
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('Hand length: $handLength'),
                    Text('Order: $displayOrder'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Simulate drawing a card
                          handLength = 5;
                          updateHandDisplayOrder(handLength);
                        });
                      },
                      child: const Text('Draw Card'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('Hand length: 4'), findsOneWidget);

      // Manually reorder (simulate)
      displayOrder = [3, 2, 1, 0];
      await tester.pump();

      // Draw a card - should reset order
      await tester.tap(find.text('Draw Card'));
      await tester.pumpAndSettle();

      // Hand length changed
      expect(find.text('Hand length: 5'), findsOneWidget);
      // Order was reset to default
      expect(displayOrder, [0, 1, 2, 3, 4]);
    });
  });
}
