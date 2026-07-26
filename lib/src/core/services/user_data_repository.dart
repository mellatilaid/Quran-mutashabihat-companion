import 'package:sqflite/sqflite.dart';
import '../models/user_data_models.dart';
import 'user_data_database_helper.dart';

/// Repository for user data operations (favorites, bookmarks, etc).
class UserDataRepository {
  final UserDataDatabaseHelper _databaseHelper;

  UserDataRepository({required UserDataDatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  // ============ Favorites Operations ============

  /// Get all favorite ayahs
  Future<List<FavoriteAyah>> getFavorites() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'favorites',
      orderBy: 'added_at DESC',
    );
    return maps.map((map) => FavoriteAyah.fromMap(map)).toList();
  }

  /// Get favorites for a specific surah
  Future<List<FavoriteAyah>> getFavoritesBySurah(int surahId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'favorites',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_num ASC',
    );
    return maps.map((map) => FavoriteAyah.fromMap(map)).toList();
  }

  /// Check if an ayah is in favorites
  Future<bool> isFavorite(int surahId, int ayahNum) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'favorites',
      where: 'surah_id = ? AND ayah_num = ?',
      whereArgs: [surahId, ayahNum],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Add favorite ayah
  Future<int> addFavorite(
    int surahId,
    int ayahNum, {
    String? note,
  }) async {
    final db = await _databaseHelper.database;
    return db.insert(
      'favorites',
      {
        'surah_id': surahId,
        'ayah_num': ayahNum,
        'note': note,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove favorite ayah
  Future<int> removeFavorite(int surahId, int ayahNum) async {
    final db = await _databaseHelper.database;
    return db.delete(
      'favorites',
      where: 'surah_id = ? AND ayah_num = ?',
      whereArgs: [surahId, ayahNum],
    );
  }

  /// Update favorite note
  Future<int> updateFavoriteNote(
    int surahId,
    int ayahNum,
    String? note,
  ) async {
    final db = await _databaseHelper.database;
    return db.update(
      'favorites',
      {'note': note},
      where: 'surah_id = ? AND ayah_num = ?',
      whereArgs: [surahId, ayahNum],
    );
  }

  /// Get favorite count
  Future<int> getFavoriteCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
    return (result.first['count'] as int?) ?? 0;
  }

  /// Clear all favorites
  Future<int> clearAllFavorites() async {
    final db = await _databaseHelper.database;
    return db.delete('favorites');
  }
}
