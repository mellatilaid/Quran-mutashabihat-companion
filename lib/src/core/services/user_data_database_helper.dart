import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the writable user_data.db database for user-generated content.
/// Separate from the read-only app.db to allow data modifications.
class UserDataDatabaseHelper {
  static const String _dbName = 'user_data.db';
  static const int _dbVersion = 1;

  static final UserDataDatabaseHelper _instance =
      UserDataDatabaseHelper._internal();

  factory UserDataDatabaseHelper() {
    return _instance;
  }

  UserDataDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
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
