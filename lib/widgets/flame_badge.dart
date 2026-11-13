import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cooking_step.dart';
import '../theme/nothing_theme.dart';

class FlameBadge extends StatelessWidget {
  final FlameLevel flame;
  final bool showFull;

  const FlameBadge({
    super.key,
    required this.flame,
    this.showFull = false,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    int pips;

    switch (flame) {
      case FlameLevel.off:
        dotColor = NothingTheme.grey;
        pips = 0;
        break;
      case FlameLevel.low:
        dotColor = NothingTheme.white;
        pips = 1;
        break;
      case FlameLevel.medium:
        dotColor = NothingTheme.white;
        pips = 2;
        break;
      case FlameLevel.high:
        dotColor = NothingTheme.red;
        pips = 3;
        break;
    }

    final text = showFull ? flame.fullLabel : flame.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NothingTheme.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: flame == FlameLevel.high
              ? NothingTheme.red.withValues(alpha: 0.5)
              : NothingTheme.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pips/dots indicator
          if (pips > 0) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                pips,
                (index) => Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: flame == FlameLevel.off
                  ? NothingTheme.grey
                  : flame == FlameLevel.high
                      ? NothingTheme.red
                      : NothingTheme.white,
            ),
          ),
        ],
      ),
    );
  }
}
