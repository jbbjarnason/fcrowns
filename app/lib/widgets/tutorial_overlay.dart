import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final int roundNumber;

  const TutorialOverlay({
    super.key,
    required this.onDismiss,
    required this.roundNumber,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('tutorial_seen') ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
  }
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      icon: Icons.emoji_events,
      title: 'Goal',
      content: 'Get rid of ALL your cards\nby making melds',
      color: Colors.amber,
    ),
    TutorialStep(
      icon: Icons.grid_view_rounded,
      title: 'Melds',
      content: '3+ same rank\nor 3+ in a row (same suit)',
      color: Colors.blue,
      examples: ['8♠ 8♥ 8♦', '4♣ 5♣ 6♣'],
    ),
    TutorialStep(
      icon: Icons.auto_awesome,
      title: 'Wilds',
      content: 'Round # = Wild card\nJokers always wild',
      color: Colors.purple,
      dynamicContent: true,
    ),
    TutorialStep(
      icon: Icons.loop,
      title: 'Your Turn',
      content: 'Draw 1 → Discard 1\nTap pile to draw\nTap card, then Discard',
      color: Colors.green,
    ),
    TutorialStep(
      icon: Icons.star,
      title: 'Go Out!',
      content: 'All cards in melds?\nTap card → Go Out!',
      color: Colors.orange,
    ),
  ];

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      TutorialOverlay.markSeen();
      widget.onDismiss();
    }
  }

  void _skip() {
    TutorialOverlay.markSeen();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return GestureDetector(
      onTap: _next,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) _next();
      },
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const Spacer(),
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, size: 64, color: step.color),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: step.color,
                ),
              ),
              const SizedBox(height: 16),
              // Content
              Text(
                step.dynamicContent
                    ? 'Round ${widget.roundNumber} = ${widget.roundNumber}s are wild\nJokers always wild'
                    : step.content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
              ),
              // Examples
              if (step.examples != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: step.examples!.map((ex) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(ex, style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                  )).toList(),
                ),
              ],
              const Spacer(),
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) => Container(
                  margin: const EdgeInsets.all(4),
                  width: i == _currentStep ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentStep ? step.color : Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 16),
              // Tap hint
              Text(
                _currentStep < _steps.length - 1 ? 'Tap to continue' : 'Tap to play!',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final List<String>? examples;
  final bool dynamicContent;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    this.examples,
    this.dynamicContent = false,
  });
}
