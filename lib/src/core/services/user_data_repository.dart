import 'package:sqflite/sqflite.dart';

import '../models/user_data_models.dart';
import 'user_data_database_helper.dart';

/// Repository for user data operations (favorites, bookmarks, etc).
class UserDataRepository {
  final UserDataDatabaseHelper _databaseHelper;

  UserDataRepository({required this._databaseHelper});

  // ============ Favorites Operations ============

  /// Get all favorite ayahs
  Future<List<FavoriteAyah>> getFavorites() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('favorites', orderBy: 'added_at DESC');
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
  Future<int> addFavorite(int surahId, int ayahNum, {String? note}) async {
    final db = await _databaseHelper.database;
    return db.insert('favorites', {
      'surah_id': surahId,
      'ayah_num': ayahNum,
      'note': note,
      'added_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
  Future<int> updateFavoriteNote(int surahId, int ayahNum, String? note) async {
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

  // ============ My Ayahs Operations ============

  /// Get all my ayahs (bookmarked difficult ayahs)
  Future<List<MyAyahListItem>> getMyAyahs() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('my_ayahs', orderBy: 'created_at DESC');
    return maps.map((map) => MyAyahListItem.fromMap(map)).toList();
  }

  /// Get my ayahs for a specific surah
  Future<List<MyAyahListItem>> getMyAyahsBySurah(int surahId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'my_ayahs',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_num ASC',
    );
    return maps.map((map) => MyAyahListItem.fromMap(map)).toList();
  }

  /// Check if an ayah is in my ayahs
  Future<bool> isInMyAyahs(int surahId, int ayahNum) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'my_ayahs',
      where: 'surah_id = ? AND ayah_num = ?',
      whereArgs: [surahId, ayahNum],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Add ayah to my ayahs
  Future<int> addToMyAyahs(int surahId, int ayahNum, {String? note}) async {
    final db = await _databaseHelper.database;
    return db.insert('my_ayahs', {
      'surah_id': surahId,
      'ayah_num': ayahNum,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Remove ayah from my ayahs
  Future<int> removeFromMyAyahs(int surahId, int ayahNum) async {
    final db = await _databaseHelper.database;
    return db.delete(
      'my_ayahs',
      where: 'surah_id = ? AND ayah_num = ?',
      whereArgs: [surahId, ayahNum],
    );
  }

  /// Update my ayah note
  Future<int> updateMyAyahNote(int surahId, int ayahNum, String? note) async {
    final db = await _databaseHelper.database;
    return db.update(
      'my_ayahs',
      {'note': note},
      where: 'surah_id = ? AND ayah_num = ?',
      whereArgs: [surahId, ayahNum],
    );
  }

  /// Get my ayahs count
  Future<int> getMyAyahsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM my_ayahs');
    return (result.first['count'] as int?) ?? 0;
  }

  /// Clear all my ayahs
  Future<int> clearAllMyAyahs() async {
    final db = await _databaseHelper.database;
    return db.delete('my_ayahs');
  }
}

