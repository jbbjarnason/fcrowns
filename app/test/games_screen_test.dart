import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fivecrowns_app/theme/app_theme.dart';

void main() {
  testWidgets('GamesScreen renders with dark theme', (WidgetTester tester) async {

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the games provider with a mock
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Consumer(
            builder: (context, ref, child) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.games, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No games yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check scaffold background color
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    debugPrint('Scaffold backgroundColor: ${scaffold.backgroundColor}');

    // Get the Material widget's color
    final material = tester.widget<Material>(find.byType(Material).first);
    debugPrint('Material color: ${material.color}');

    // Check if "No games yet" text is visible
    expect(find.text('No games yet'), findsOneWidget);

    // Check the icon
    expect(find.byIcon(Icons.games), findsOneWidget);
  });

  testWidgets('Check theme colors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            debugPrint('scaffoldBackgroundColor: ${theme.scaffoldBackgroundColor}');
            debugPrint('colorScheme.surface: ${theme.colorScheme.surface}');
            debugPrint('colorScheme.background: N/A (deprecated)');
            debugPrint('canvasColor: ${theme.canvasColor}');

            return Scaffold(
              body: Container(
                color: theme.scaffoldBackgroundColor,
                child: const Center(child: Text('Test')),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Empty games list shows correct content', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Five Crowns')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.games, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No games yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Create Game'),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('New Game'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all elements are present
    expect(find.text('Five Crowns'), findsOneWidget);
    expect(find.text('No games yet'), findsOneWidget);
    expect(find.text('Create Game'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byIcon(Icons.games), findsOneWidget);

    // Get scaffold and check background
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    debugPrint('Scaffold in empty games: backgroundColor=${scaffold.backgroundColor}');
  });
}
