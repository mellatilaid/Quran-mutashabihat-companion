import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';
import '../models.dart';

/// Arabic line widget with RTL Wrap and phrase highlighting support.
/// Displays words with HighlightRange support, diffAt underline, and activePhraseId filtering.
class ArabicLine extends StatelessWidget {
  final List<QuranWord> words;
  final List<HighlightRange> highlights;
  final int? activePhraseId;
  final Map<int, Color>? phraseColors;
  final int? diffAt;
  final double fontSize;
  final TextDirection textDirection;

  const ArabicLine({
    super.key,
    required this.words,
    this.highlights = const [],
    this.activePhraseId,
    this.phraseColors,
    this.diffAt,
    this.fontSize = 20.0,
    this.textDirection = TextDirection.rtl,
  });

  /// Returns highlight color for a word if it matches activePhraseId.
  /// Uses phraseColors if available, otherwise returns tertiary color.
  Color? _getActiveHighlightColor(int wordIndex) {
    if (activePhraseId == null) return null;

    final highlight = highlights.firstWhere(
      (h) =>
          h.phraseId == activePhraseId &&
          wordIndex >= h.wordFrom &&
          wordIndex <= h.wordTo,
      orElse: () => HighlightRange(wordFrom: -1, wordTo: -1, phraseId: -1),
    );

    if (highlight.phraseId == -1) return null; // No match found

    // Use phrase-specific color if available
    return phraseColors?[activePhraseId];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: List.generate(words.length, (index) {
          final word = words[index];
          final highlightColor = _getActiveHighlightColor(index);
          final isActive = highlightColor != null;
          final isDiff = diffAt == index;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? highlightColor : Colors.transparent,
              border: isDiff
                  ? Border(
                      bottom: BorderSide(
                        color: context.colorScheme.error,
                        width: 2,
                      ),
                    )
                  : Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              word.text,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: fontSize,
                color: context.colorScheme.onSurface,
              ),
            ),
          );
        }),
      ),
    );
  }
}
