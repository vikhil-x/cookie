import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cooking_step.dart';
import '../theme/nothing_theme.dart';
import 'flame_badge.dart';
import 'step_timer_widget.dart';

class StepCard extends StatelessWidget {
  final CookingStep step;
  final int index;
  final VoidCallback? onEdit;

  const StepCard({
    super.key,
    required this.step,
    required this.index,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final stepNum = (index + 1).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: NothingTheme.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Step number, Flame badge, and inline timer
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Step sequence number
                Text(
                  stepNum,
                  style: GoogleFonts.spaceMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: NothingTheme.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                // Flame Level Badge
                FlameBadge(flame: step.flame),
                const Spacer(),
                // Step Timer
                if (step.totalSeconds > 0)
                  StepTimerWidget(
                    totalDurationSeconds: step.totalSeconds,
                    stepLabel: 'STEP $stepNum',
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Step Description
            Text(
              step.description,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: NothingTheme.white,
                height: 1.5,
              ),
            ),

            // Highlighted Slight Thin Box for Step Ingredients
            if (step.ingredients.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: NothingTheme.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PREPARE FOR THIS STEP',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: NothingTheme.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: step.ingredients.map((ing) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: NothingTheme.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: NothingTheme.border,
                              width: 1,
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.spaceMono(
                                fontSize: 11,
                                color: NothingTheme.white,
                              ),
                              children: [
                                TextSpan(
                                  text: ing.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (ing.quantity.trim().isNotEmpty) ...[
                                  TextSpan(
                                    text: '  •  ',
                                    style: TextStyle(
                                      color: NothingTheme.grey.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ing.quantity,
                                    style: const TextStyle(
                                      color: Color(0xFFCCCCCC),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
