/// User-generated data models for the Mutashabihat app.
/// These are stored in a separate writable user_data.db database.

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
