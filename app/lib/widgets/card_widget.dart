import 'package:flutter/material.dart';
import 'package:fivecrowns_core/fivecrowns_core.dart' as core;
import '../theme/app_theme.dart';

class CardWidget extends StatelessWidget {
  final String cardCode;
  final bool isSelected;
  final bool highlighted;
  final bool small;

  const CardWidget({
    super.key,
    required this.cardCode,
    this.isSelected = false,
    this.highlighted = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = core.Card.decode(cardCode);
    final size = small ? const Size(44, 60) : const Size(64, 88);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: size.width,
      height: size.height,
      transform: isSelected ? Matrix4.translationValues(0, -10, 0) : Matrix4.identity(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)]
              : [Colors.white, const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(small ? 8 : 12),
        border: Border.all(
          color: highlighted
              ? AppTheme.accent
              : isSelected
                  ? AppTheme.primary
                  : isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFE2E8F0),
          width: highlighted || isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: isSelected ? 12 : 6,
            offset: Offset(0, isSelected ? 6 : 3),
          ),
        ],
      ),
      child: Center(
        child: card.isJoker
            ? _buildJoker(small)
            : _buildRegularCard(card, small),
      ),
    );
  }

  Widget _buildJoker(bool small) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          color: AppTheme.primary,
          size: small ? 18 : 26,
        ),
        Text(
          'JOKER',
          style: TextStyle(
            fontSize: small ? 7 : 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegularCard(core.Card card, bool small) {
    final color = _getSuitColor(card.suit!);
    final symbol = _getSuitSymbol(card.suit!);
    final rankStr = _getRankString(card.rank!);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          rankStr,
          style: TextStyle(
            fontSize: small ? 16 : 22,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          symbol,
          style: TextStyle(
            fontSize: small ? 16 : 22,
            color: color,
            height: 1,
          ),
        ),
      ],
    );
  }

  Color _getSuitColor(core.Suit suit) {
    switch (suit) {
      case core.Suit.hearts:
        return AppTheme.hearts;
      case core.Suit.diamonds:
        return AppTheme.diamonds;
      case core.Suit.clubs:
        return const Color(0xFF1E293B);
      case core.Suit.spades:
        return const Color(0xFF1E293B);
      case core.Suit.stars:
        return AppTheme.stars;
    }
  }

  String _getSuitSymbol(core.Suit suit) {
    switch (suit) {
      case core.Suit.hearts:
        return '\u2665';
      case core.Suit.diamonds:
        return '\u2666';
      case core.Suit.clubs:
        return '\u2663';
      case core.Suit.spades:
        return '\u2660';
      case core.Suit.stars:
        return '\u2605';
    }
  }

  String _getRankString(core.Rank rank) {
    switch (rank) {
      case core.Rank.three:
        return '3';
      case core.Rank.four:
        return '4';
      case core.Rank.five:
        return '5';
      case core.Rank.six:
        return '6';
      case core.Rank.seven:
        return '7';
      case core.Rank.eight:
        return '8';
      case core.Rank.nine:
        return '9';
      case core.Rank.ten:
        return '10';
      case core.Rank.jack:
        return 'J';
      case core.Rank.queen:
        return 'Q';
      case core.Rank.king:
        return 'K';
    }
  }
}
