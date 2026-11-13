import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/nothing_theme.dart';

class NothingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isDanger;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const NothingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isDanger = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDanger
        ? NothingTheme.red
        : isPrimary
            ? NothingTheme.white
            : NothingTheme.surfaceElevated;

    final fgColor = isDanger
        ? NothingTheme.white
        : isPrimary
            ? NothingTheme.black
            : NothingTheme.white;

    final borderColor = isDanger
        ? NothingTheme.red
        : isPrimary
            ? NothingTheme.white
            : NothingTheme.border;

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          side: BorderSide(color: borderColor, width: 1.2),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fgColor),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
