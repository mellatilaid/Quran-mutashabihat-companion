import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Manages the writable user_data.db database for user-generated content.
/// Separate from the read-only app.db to allow data modifications.
class UserDataDatabaseHelper {
  static const String _dbName = 'user_data.db';
  static const int _dbVersion = 2;

  static final UserDataDatabaseHelper _instance =
      UserDataDatabaseHelper._internal();

  factory UserDataDatabaseHelper() {
    return _instance;
  }

  /// Test-only factory for dependency injection.
  /// Allows tests to pass a mock/in-memory database directly.
  factory UserDataDatabaseHelper.withDatabase(Database db) {
    final helper = UserDataDatabaseHelper._internal();
    helper._injectedDatabase = db;
    return helper;
  }

  UserDataDatabaseHelper._internal();

  // Static database for production use (singleton)
  static Database? _database;

  // Instance database for test injection
  Database? _injectedDatabase;

  Future<Database> get database async {
    // Return injected database if this instance was created via withDatabase
    if (_injectedDatabase != null) return _injectedDatabase!;

    // Otherwise use the static singleton database
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create favorites table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_num INTEGER NOT NULL,
        note TEXT,
        added_at TEXT NOT NULL,
        UNIQUE(surah_id, ayah_num)
      )
    ''');

    // Create index on surah_id for faster queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favorites_surah_id ON favorites(surah_id)
    ''');

    // Create my_ayahs table for bookmarked difficult ayahs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS my_ayahs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_num INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(surah_id, ayah_num)
      )
    ''');

    // Create index on surah_id for my_ayahs
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_my_ayahs_surah_id ON my_ayahs(surah_id)
    ''');

    // Create ayah_notes table for personal notes on ayahs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ayah_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_num INTEGER NOT NULL,
        note_text TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(surah_id, ayah_num)
      )
    ''');

    // Create index on surah_id for ayah_notes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_ayah_notes_surah_id ON ayah_notes(surah_id)
    ''');
  }

  /// Handle database migrations when version changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create ayah_notes table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ayah_notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          surah_id INTEGER NOT NULL,
          ayah_num INTEGER NOT NULL,
          note_text TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(surah_id, ayah_num)
        )
      ''');

      // Create index on surah_id
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_ayah_notes_surah_id ON ayah_notes(surah_id)
      ''');
    }
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reset the database (for testing)
  Future<void> reset() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = join(documentsDir.path, _dbName);
    await deleteDatabase(path);
    _database = null;
  }
}
