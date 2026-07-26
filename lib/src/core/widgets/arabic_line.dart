import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models.dart';

/// Arabic line widget with RTL Wrap and phrase highlighting support.
/// Displays words with HighlightRange support, diffAt underline, and activePhraseId filtering.
class ArabicLine extends StatelessWidget {
  final List<QuranWord> words;
  final List<HighlightRange> highlights;
  final int? activePhraseId;
  final int? diffAt;
  final double fontSize;
  final TextDirection textDirection;

  const ArabicLine({
    super.key,
    required this.words,
    this.highlights = const [],
    this.activePhraseId,
    this.diffAt,
    this.fontSize = 20.0,
    this.textDirection = TextDirection.rtl,
  });

  bool _isActivePhraseHighlighted(int wordIndex) {
    if (activePhraseId == null) return false;
    return highlights.any(
      (h) =>
          h.phraseId == activePhraseId &&
          wordIndex >= h.wordFrom &&
          wordIndex <= h.wordTo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = const Color(0xFFFECC84); // amber for highlights
    final diffColor = isDark
        ? const Color(0xFFE89BB4)
        : const Color(0xFF9C4E68); // rose

    return Directionality(
      textDirection: textDirection,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: List.generate(words.length, (index) {
          final word = words[index];
          final isActive = _isActivePhraseHighlighted(index);
          final isDiff = diffAt == index;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? highlightColor : Colors.transparent,
              border: isDiff
                  ? Border(bottom: BorderSide(color: diffColor, width: 2))
                  : Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              word.text,
              style: GoogleFonts.amiri(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? const Color(0xFFEDEDE4)
                    : const Color(0xFF20302C),
              ),
            ),
          );
        }),
      ),
    );
  }
}
