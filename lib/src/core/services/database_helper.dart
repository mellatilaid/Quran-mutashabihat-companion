import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Opens (and, on first launch, installs) the bundled `app.db` asset.
///
/// `app.db` is prebuilt offline by `import_mutashabihat.py` and ships in
/// the app as a read-only asset (add it under `assets/db/app.db` and
/// declare it in pubspec.yaml). sqflite can't query a database straight
/// out of the asset bundle, so on first run we copy it into the app's
/// writable documents directory and open it from there.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _assetPath = 'assets/db/app.db';
  static const _dbFileName = 'app.db';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbFileName);

    final alreadyInstalled = await File(dbPath).exists();
    if (!alreadyInstalled) {
      final bytes = await rootBundle.load(_assetPath);
      final buffer = bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      );
      await File(dbPath).writeAsBytes(buffer, flush: true);
    }

    // Open read-only: app.db is a static, prebuilt dataset. The app never
    // writes to it (favorites/mnemonic tips from SDD §7 should live in a
    // *separate* writable db, not this one, so re-installing app.db on
    // an update never wipes user data).
    return openDatabase(dbPath, readOnly: true);
  }
}
