/// User-generated data models for the Mutashabihat app.
/// These are stored in a separate writable user_data.db database.
library;

class FavoriteAyah {
  final int id; // Primary key
  final int surahId;
  final int ayahNum;
  final String? note;
  final DateTime addedAt;

  FavoriteAyah({
    required this.id,
    required this.surahId,
    required this.ayahNum,
    this.note,
    required this.addedAt,
  });

  /// Create from database map
  factory FavoriteAyah.fromMap(Map<String, dynamic> map) {
    return FavoriteAyah(
      id: map['id'] as int,
      surahId: map['surah_id'] as int,
      ayahNum: map['ayah_num'] as int,
      note: map['note'] as String?,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_num': ayahNum,
      'note': note,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Create copy with modified fields
  FavoriteAyah copyWith({
    int? id,
    int? surahId,
    int? ayahNum,
    String? note,
    DateTime? addedAt,
  }) {
    return FavoriteAyah(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNum: ayahNum ?? this.ayahNum,
      note: note ?? this.note,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() =>
      'FavoriteAyah(id: $id, surah: $surahId, ayah: $ayahNum, note: $note, addedAt: $addedAt)';
}

/// MyAyahListItem — bookmark for difficult ayahs with personal notes.
class MyAyahListItem {
  final int id;
  final int surahId;
  final int ayahNum;
  final String? note;
  final DateTime createdAt;

  MyAyahListItem({
    required this.id,
    required this.surahId,
    required this.ayahNum,
    this.note,
    required this.createdAt,
  });

  /// Create from database map
  factory MyAyahListItem.fromMap(Map<String, dynamic> map) {
    return MyAyahListItem(
      id: map['id'] as int,
      surahId: map['surah_id'] as int,
      ayahNum: map['ayah_num'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_num': ayahNum,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create copy with modified fields
  MyAyahListItem copyWith({
    int? id,
    int? surahId,
    int? ayahNum,
    String? note,
    DateTime? createdAt,
  }) {
    return MyAyahListItem(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNum: ayahNum ?? this.ayahNum,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'MyAyahListItem(id: $id, surah: $surahId, ayah: $ayahNum, note: $note, createdAt: $createdAt)';
}

/// AyahNote — personal note attached to a single ayah.
/// Stored separately from favorites for independent management.
class AyahNote {
  final int id; // Primary key
  final int surahId;
  final int ayahNum;
  final String noteText;
  final DateTime updatedAt;

  AyahNote({
    required this.id,
    required this.surahId,
    required this.ayahNum,
    required this.noteText,
    required this.updatedAt,
  });

  /// Create from database map
  factory AyahNote.fromMap(Map<String, dynamic> map) {
    return AyahNote(
      id: map['id'] as int,
      surahId: map['surah_id'] as int,
      ayahNum: map['ayah_num'] as int,
      noteText: map['note_text'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_num': ayahNum,
      'note_text': noteText,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with modified fields
  AyahNote copyWith({
    int? id,
    int? surahId,
    int? ayahNum,
    String? noteText,
    DateTime? updatedAt,
  }) {
    return AyahNote(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNum: ayahNum ?? this.ayahNum,
      noteText: noteText ?? this.noteText,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AyahNote(id: $id, surah: $surahId, ayah: $ayahNum, noteText: $noteText, updatedAt: $updatedAt)';
}
