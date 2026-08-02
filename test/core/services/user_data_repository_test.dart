import 'package:flutter_test/flutter_test.dart';
import 'package:quran_mutashibihat_app/src/core/services/user_data_database_helper.dart';
import 'package:quran_mutashibihat_app/src/core/services/user_data_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('UserDataRepository - Note Operations', () {
    late UserDataRepository repository;
    late Database inMemoryDb;

    setUp(() async {
      // Initialize FFI for in-memory testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Create in-memory database
      inMemoryDb = await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          // Create favorites table
          await db.execute('''
            CREATE TABLE favorites (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              surah_id INTEGER NOT NULL,
              ayah_num INTEGER NOT NULL,
              note TEXT,
              added_at TEXT NOT NULL,
              UNIQUE(surah_id, ayah_num)
            )
          ''');

          // Create my_ayahs table
          await db.execute('''
            CREATE TABLE my_ayahs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              surah_id INTEGER NOT NULL,
              ayah_num INTEGER NOT NULL,
              note TEXT,
              created_at TEXT NOT NULL,
              UNIQUE(surah_id, ayah_num)
            )
          ''');

          // Create ayah_notes table
          await db.execute('''
            CREATE TABLE ayah_notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              surah_id INTEGER NOT NULL,
              ayah_num INTEGER NOT NULL,
              note_text TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              UNIQUE(surah_id, ayah_num)
            )
          ''');
        },
      );

      // Create repository with in-memory database
      final dbHelper = UserDataDatabaseHelper.withDatabase(inMemoryDb);
      repository = UserDataRepository(databaseHelper: dbHelper);
    });

    tearDown(() async {
      await inMemoryDb.close();
    });

    group('getNote', () {
      test('returns null when no note exists', () async {
        final note = await repository.getNote(1, 1);
        expect(note, isNull);
      });

      test('returns the saved note when it exists', () async {
        const surahId = 1;
        const ayahNum = 5;
        const noteText = 'This is a test note';

        // Save a note
        await repository.saveNote(surahId, ayahNum, noteText);

        // Retrieve it
        final note = await repository.getNote(surahId, ayahNum);

        expect(note, isNotNull);
        expect(note!.surahId, equals(surahId));
        expect(note.ayahNum, equals(ayahNum));
        expect(note.noteText, equals(noteText));
      });

      test('returns different notes for different ayahs', () async {
        const surahId = 2;
        const noteText1 = 'Note for ayah 3';
        const noteText2 = 'Note for ayah 7';

        // Save notes for two different ayahs
        await repository.saveNote(surahId, 3, noteText1);
        await repository.saveNote(surahId, 7, noteText2);

        // Retrieve them separately
        final note1 = await repository.getNote(surahId, 3);
        final note2 = await repository.getNote(surahId, 7);

        expect(note1!.noteText, equals(noteText1));
        expect(note2!.noteText, equals(noteText2));
      });
    });

    group('saveNote', () {
      test('inserts a new note successfully', () async {
        const surahId = 1;
        const ayahNum = 10;
        const noteText = 'My first note';

        final result = await repository.saveNote(surahId, ayahNum, noteText);

        expect(result, isNotNull); // Insert returns row id or 1
        final savedNote = await repository.getNote(surahId, ayahNum);
        expect(savedNote!.noteText, equals(noteText));
      });

      test('replaces existing note on second call (upsert behavior)', () async {
        const surahId = 3;
        const ayahNum = 15;
        const firstText = 'First version';
        const secondText = 'Second version';

        // Save initial note
        await repository.saveNote(surahId, ayahNum, firstText);
        var savedNote = await repository.getNote(surahId, ayahNum);
        expect(savedNote!.noteText, equals(firstText));

        // Save again with different text (upsert)
        await repository.saveNote(surahId, ayahNum, secondText);
        savedNote = await repository.getNote(surahId, ayahNum);

        // Should have only one row, with updated text
        expect(savedNote!.noteText, equals(secondText));
      });

      test('updates updated_at timestamp on subsequent saves', () async {
        const surahId = 4;
        const ayahNum = 20;

        // First save
        await repository.saveNote(surahId, ayahNum, 'First');
        final firstNote = await repository.getNote(surahId, ayahNum);
        final firstTimestamp = firstNote!.updatedAt;

        // Wait a tiny bit to ensure timestamp changes
        await Future.delayed(const Duration(milliseconds: 10));

        // Second save
        await repository.saveNote(surahId, ayahNum, 'Second');
        final secondNote = await repository.getNote(surahId, ayahNum);
        final secondTimestamp = secondNote!.updatedAt;

        // Both timestamps should be valid DateTime objects
        expect(firstTimestamp, isNotNull);
        expect(secondTimestamp, isNotNull);
        // Second timestamp should be >= first timestamp
        expect(
          secondTimestamp.isAfter(firstTimestamp) ||
              secondTimestamp.isAtSameMomentAs(firstTimestamp),
          isTrue,
        );
      });

      test('handles empty and whitespace-only strings', () async {
        // Note: This is allowed at the repository level; UI should validate
        const surahId = 5;

        // Save empty string
        await repository.saveNote(surahId, 1, '');
        var note = await repository.getNote(surahId, 1);
        expect(note!.noteText, equals(''));

        // Save whitespace
        await repository.saveNote(surahId, 2, '   ');
        note = await repository.getNote(surahId, 2);
        expect(note!.noteText, equals('   '));
      });
    });

    group('deleteNote', () {
      test('deletes an existing note and returns 1', () async {
        const surahId = 1;
        const ayahNum = 25;

        // Save a note
        await repository.saveNote(surahId, ayahNum, 'To be deleted');

        // Delete it
        final result = await repository.deleteNote(surahId, ayahNum);
        expect(result, equals(1)); // One row deleted

        // Verify it's gone
        final note = await repository.getNote(surahId, ayahNum);
        expect(note, isNull);
      });

      test('returns 0 when deleting a non-existent note', () async {
        const surahId = 6;
        const ayahNum = 30;

        // Try to delete without saving first
        final result = await repository.deleteNote(surahId, ayahNum);
        expect(result, equals(0)); // No rows deleted
      });

      test('returns 0 when deleting an already-deleted note', () async {
        const surahId = 7;
        const ayahNum = 35;

        // Save then delete
        await repository.saveNote(surahId, ayahNum, 'Delete twice');
        await repository.deleteNote(surahId, ayahNum);

        // Try deleting again
        final secondResult = await repository.deleteNote(surahId, ayahNum);
        expect(secondResult, equals(0)); // No rows deleted this time
      });

      test('only deletes the note for the specified surah/ayah pair', () async {
        const surahId = 8;

        // Save notes for two ayahs
        await repository.saveNote(surahId, 40, 'Note 1');
        await repository.saveNote(surahId, 41, 'Note 2');

        // Delete only the first
        await repository.deleteNote(surahId, 40);

        // First should be gone
        final note1 = await repository.getNote(surahId, 40);
        expect(note1, isNull);

        // Second should still exist
        final note2 = await repository.getNote(surahId, 41);
        expect(note2!.noteText, equals('Note 2'));
      });
    });

    group('Regression: Favorites Operations Still Work', () {
      test(
        'addFavorite and isFavorite work alongside note operations',
        () async {
          const surahId = 1;
          const ayahNum = 50;

          // Add favorite
          await repository.addFavorite(surahId, ayahNum);
          expect(await repository.isFavorite(surahId, ayahNum), isTrue);

          // Save a note for the same ayah
          await repository.saveNote(surahId, ayahNum, 'Important ayah');

          // Favorite should still be there
          expect(await repository.isFavorite(surahId, ayahNum), isTrue);

          // Note should be there
          final note = await repository.getNote(surahId, ayahNum);
          expect(note!.noteText, equals('Important ayah'));
        },
      );

      test('removeFavorite works alongside note operations', () async {
        const surahId = 2;
        const ayahNum = 55;

        // Add both favorite and note
        await repository.addFavorite(surahId, ayahNum);
        await repository.saveNote(surahId, ayahNum, 'Test note');

        // Remove favorite
        await repository.removeFavorite(surahId, ayahNum);

        // Favorite should be gone
        expect(await repository.isFavorite(surahId, ayahNum), isFalse);

        // Note should still be there (independent operation)
        final note = await repository.getNote(surahId, ayahNum);
        expect(note!.noteText, equals('Test note'));
      });

      test('getFavorites returns correct list alongside notes', () async {
        // Add multiple favorites and notes
        await repository.addFavorite(1, 10);
        await repository.addFavorite(2, 20);
        await repository.addFavorite(3, 30);

        await repository.saveNote(1, 10, 'Note 1');
        await repository.saveNote(2, 20, 'Note 2');

        final favorites = await repository.getFavorites();
        expect(favorites, hasLength(3));
        expect(favorites[0].surahId, isIn([1, 2, 3]));
      });

      test('clear all operations do not affect notes', () async {
        // Add favorites and notes
        await repository.addFavorite(1, 60);
        await repository.addFavorite(2, 70);
        await repository.saveNote(1, 60, 'Note A');
        await repository.saveNote(2, 70, 'Note B');

        // Clear favorites
        await repository.clearAllFavorites();

        // Favorites should be gone
        expect(await repository.getFavorites(), isEmpty);

        // Notes should still exist
        expect(await repository.getNote(1, 60), isNotNull);
        expect(await repository.getNote(2, 70), isNotNull);
      });
    });
  });
}
