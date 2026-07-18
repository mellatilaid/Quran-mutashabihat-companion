/// Data models for the Mutashabihat Companion app.
///
/// These mirror the tables in app.db:
///   surahs, ayahs, words, phrases, phrase_occurrences, ayah_phrases

/// Screen 1 — Surah Index row.
class Surah {
  final int id;
  final String nameArabic;
  final String nameSimple;
  final int versesCount;
  final int mutashabihatAyahCount;

  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.versesCount,
    required this.mutashabihatAyahCount,
  });

  factory Surah.fromMap(Map<String, Object?> map) {
    return Surah(
      id: map['id'] as int,
      nameArabic: map['name_arabic'] as String,
      nameSimple: map['name_simple'] as String,
      versesCount: map['verses_count'] as int,
      mutashabihatAyahCount: (map['mutashabihat_ayah_count'] as int?) ?? 0,
    );
  }
}

/// Screen 2 — a single row in the "Mutashabihat ayahs in this surah" list.
/// Plain text, no highlighting.
class AyahListItem {
  final int surah;
  final int ayah;
  final String text;

  const AyahListItem({
    required this.surah,
    required this.ayah,
    required this.text,
  });

  factory AyahListItem.fromMap(Map<String, Object?> map) {
    return AyahListItem(
      surah: map['surah'] as int,
      ayah: map['ayah'] as int,
      text: map['text'] as String,
    );
  }
}

/// A single word of an ayah, with word-index for ordering/highlighting.
class QuranWord {
  final int wordIndex;
  final String text;

  const QuranWord({required this.wordIndex, required this.text});

  factory QuranWord.fromMap(Map<String, Object?> map) {
    return QuranWord(
      wordIndex: map['word'] as int,
      text: map['text'] as String,
    );
  }
}

/// A [word_from, word_to] inclusive range that should be highlighted,
/// tagged with which phrase it belongs to (several phrases can appear
/// in the same ayah, so a word can theoretically belong to more than one).
class HighlightRange {
  final int phraseId;
  final int wordFrom;
  final int wordTo;

  const HighlightRange({
    required this.phraseId,
    required this.wordFrom,
    required this.wordTo,
  });

  bool contains(int wordIndex) => wordIndex >= wordFrom && wordIndex <= wordTo;

  factory HighlightRange.fromMap(Map<String, Object?> map) {
    return HighlightRange(
      phraseId: map['phrase_id'] as int,
      wordFrom: map['word_from'] as int,
      wordTo: map['word_to'] as int,
    );
  }
}

/// Screen 3 — full detail for one tapped ayah: its words plus the
/// highlight ranges to paint over them, plus which phrase ids are involved
/// (so the UI can render a tappable list below the ayah).
class AyahDetail {
  final int surah;
  final int ayah;
  final List<QuranWord> words;
  final List<HighlightRange> highlights;

  const AyahDetail({
    required this.surah,
    required this.ayah,
    required this.words,
    required this.highlights,
  });

  /// Which phrase ids (deduplicated, in first-appearance order) are present
  /// in this ayah — used to build the "Similar phrases found here" list.
  List<int> get phraseIds {
    final seen = <int>{};
    final ordered = <int>[];
    for (final h in highlights) {
      if (seen.add(h.phraseId)) ordered.add(h.phraseId);
    }
    return ordered;
  }

  /// True if [wordIndex] should be painted as highlighted, optionally
  /// restricted to a single [phraseId] (e.g. when the user has tapped one
  /// specific phrase chip to isolate it visually).
  bool isHighlighted(int wordIndex, {int? phraseId}) {
    return highlights.any((h) =>
        h.contains(wordIndex) && (phraseId == null || h.phraseId == phraseId));
  }
}

/// Screen 4 — one occurrence of the selected phrase, ready to render
/// with its own highlighted words.
class PhraseOccurrenceDetail {
  final int surah;
  final int ayah;
  final int wordFrom;
  final int wordTo;
  final List<QuranWord> words;

  const PhraseOccurrenceDetail({
    required this.surah,
    required this.ayah,
    required this.wordFrom,
    required this.wordTo,
    required this.words,
  });

  bool isHighlighted(int wordIndex) =>
      wordIndex >= wordFrom && wordIndex <= wordTo;
}

/// Metadata about a phrase itself (used as a header on Screen 4).
class Phrase {
  final int id;
  final int surahCount;
  final int ayahCount;
  final int occurrenceCount;

  const Phrase({
    required this.id,
    required this.surahCount,
    required this.ayahCount,
    required this.occurrenceCount,
  });

  factory Phrase.fromMap(Map<String, Object?> map) {
    return Phrase(
      id: map['id'] as int,
      surahCount: map['surah_count'] as int,
      ayahCount: map['ayah_count'] as int,
      occurrenceCount: map['occurrence_count'] as int,
    );
  }
}
