import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/services/database_helper.dart';

/// All read queries against app.db, one method per screen (plus a couple
/// of shared helpers). Keeping every query in one place makes it easy to
/// see exactly how the SDD's data flow (§3) maps to SQL.
class IndexRepo {
  IndexRepo({Database? database}) : _dbOverride = database;

  final Database? _dbOverride;

  Future<Database> get _db async =>
      _dbOverride ?? await DatabaseHelper.instance.database;

  // ---------------------------------------------------------------------
  // Screen 1 — Surah Index
  // ---------------------------------------------------------------------

  /// All 114 surahs, each annotated with how many of its ayahs contain
  /// Mutashabihat (DISTINCT ayahs in phrase_occurrences, per SDD §5).
  Future<List<Surah>> getSurahs() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT s.id,
             s.name_arabic,
             s.name_simple,
             s.verses_count,
             COUNT(DISTINCT po.ayah) AS mutashabihat_ayah_count
      FROM surahs s
      LEFT JOIN phrase_occurrences po ON po.surah = s.id
      GROUP BY s.id
      ORDER BY s.id
    ''');
    return rows.map(Surah.fromMap).toList();
  }

  // ---------------------------------------------------------------------
  // Screen 2 — Mutashabihat Ayahs in a Surah (plain text, no highlighting)
  // ---------------------------------------------------------------------

  Future<List<AyahListItem>> getMutashabihatAyahs(int surah) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '''
      SELECT a.surah, a.ayah, a.text
      FROM ayahs a
      WHERE a.surah = ?
        AND a.ayah IN (
          SELECT DISTINCT ayah FROM phrase_occurrences WHERE surah = ?
        )
      ORDER BY a.ayah
    ''',
      [surah, surah],
    );
    return rows.map(AyahListItem.fromMap).toList();
  }

  // ---------------------------------------------------------------------
  // Screen 3 — Ayah Details (one ayah, its words, its highlight ranges)
  // ---------------------------------------------------------------------

  Future<AyahDetail> getAyahDetail(int surah, int ayah) async {
    final db = await _db;

    final wordRows = await db.rawQuery(
      '''
      SELECT word, text FROM words
      WHERE surah = ? AND ayah = ?
      ORDER BY word
    ''',
      [surah, ayah],
    );

    final highlightRows = await db.rawQuery(
      '''
      SELECT phrase_id, word_from, word_to FROM phrase_occurrences
      WHERE surah = ? AND ayah = ?
    ''',
      [surah, ayah],
    );

    final words = wordRows.map(QuranWord.fromMap).toList();
    final maxWordIndex = words.isEmpty
        ? 0
        : words.map((w) => w.wordIndex).reduce((a, b) => a > b ? a : b);

    // Defensive clamp: one known row in the source dataset (phrase 4970,
    // ayah 48:10) references a word_to past the ayah's actual word count.
    // Clamping avoids an out-of-range highlight silently no-op'ing or,
    // worse, a UI index error, without needing to special-case that row.
    final highlights = highlightRows.map(HighlightRange.fromMap).map((h) {
      if (h.wordTo <= maxWordIndex) return h;
      return HighlightRange(
        phraseId: h.phraseId,
        wordFrom: h.wordFrom,
        wordTo: maxWordIndex,
      );
    }).toList();

    return AyahDetail(
      surah: surah,
      ayah: ayah,
      words: words,
      highlights: highlights,
    );
  }

  // ---------------------------------------------------------------------
  // Screen 4 — Phrase Comparison (every occurrence of one phrase)
  // ---------------------------------------------------------------------

  Future<Phrase> getPhrase(int phraseId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '''
      SELECT id, surah_count, ayah_count, occurrence_count
      FROM phrases WHERE id = ?
    ''',
      [phraseId],
    );
    return Phrase.fromMap(rows.first);
  }

  Future<List<PhraseOccurrenceDetail>> getPhraseComparison(int phraseId) async {
    final db = await _db;

    final occurrenceRows = await db.rawQuery(
      '''
      SELECT surah, ayah, word_from, word_to
      FROM phrase_occurrences
      WHERE phrase_id = ?
      ORDER BY surah, ayah
    ''',
      [phraseId],
    );

    final results = <PhraseOccurrenceDetail>[];
    for (final row in occurrenceRows) {
      final surah = row['surah'] as int;
      final ayah = row['ayah'] as int;
      final wordFrom = row['word_from'] as int;
      final wordTo = row['word_to'] as int;

      final wordRows = await db.rawQuery(
        '''
        SELECT word, text FROM words
        WHERE surah = ? AND ayah = ?
        ORDER BY word
      ''',
        [surah, ayah],
      );
      final words = wordRows.map(QuranWord.fromMap).toList();
      final maxWordIndex = words.isEmpty
          ? 0
          : words.map((w) => w.wordIndex).reduce((a, b) => a > b ? a : b);

      results.add(
        PhraseOccurrenceDetail(
          surah: surah,
          ayah: ayah,
          wordFrom: wordFrom,
          wordTo: wordTo > maxWordIndex ? maxWordIndex : wordTo,
          words: words,
        ),
      );
    }
    return results;
  }

  // --------- Search Ayahs (for My Ayahs Add Screen) ---------

  /// Search ayahs by text or surah:ayah reference
  /// Returns AyahListItem results limited to 50
  Future<List<AyahListItem>> searchAyahs(String query) async {
    if (query.isEmpty) return [];

    final db = await _db;

    // First try to parse as "surah:ayah" format
    if (query.contains(':')) {
      final parts = query.split(':');
      if (parts.length == 2) {
        final surahParsed = int.tryParse(parts[0].trim());
        final ayahParsed = int.tryParse(parts[1].trim());
        if (surahParsed != null && ayahParsed != null) {
          final rows = await db.query(
            'ayahs',
            where: 'surah = ? AND ayah = ?',
            whereArgs: [surahParsed, ayahParsed],
            limit: 1,
          );
          if (rows.isNotEmpty) {
            return [AyahListItem.fromMap(rows.first)];
          }
          return [];
        }
      }
    }

    // Otherwise search by Arabic text (case-insensitive substring match)
    final rows = await db.query(
      'ayahs',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      limit: 50,
      orderBy: 'surah ASC, ayah ASC',
    );
    return rows.map(AyahListItem.fromMap).toList();
  }
}
