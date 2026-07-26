import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pill badge tone variants.
enum PillBadgeTone { solid, soft, outline }

/// Pill badge widget with 3 tone variants.
/// Uses Inter 11px 600 with full radius.
class PillBadge extends StatelessWidget {
  final String label;
  final Color color;
  final PillBadgeTone tone;

  const PillBadge({
    Key? key,
    required this.label,
    required this.color,
    this.tone = PillBadgeTone.solid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (tone) {
      case PillBadgeTone.solid:
        backgroundColor = color;
        textColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case PillBadgeTone.soft:
        backgroundColor = color.withValues(alpha: 0.15);
        textColor = color;
        borderColor = Colors.transparent;
        break;
      case PillBadgeTone.outline:
        backgroundColor = Colors.transparent;
        textColor = color;
        borderColor = color;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(999), // full radius
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

