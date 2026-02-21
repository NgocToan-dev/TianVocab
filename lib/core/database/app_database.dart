import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase._(super.executor);

  static Future<AppDatabase> inMemory() async {
    final db = AppDatabase._(NativeDatabase.memory());
    await db._migrate();
    return db;
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  int get schemaVersion => 1;

  static AppDatabase? _instance;

  static Future<AppDatabase> instance() async {
    final cached = _instance;
    if (cached != null) {
      return cached;
    }

    final executor = await _openExecutor();
    final db = AppDatabase._(executor);
    await db._migrate();
    _instance = db;
    return db;
  }

  static Future<QueryExecutor> _openExecutor() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbFile = File('${documentsDir.path}/tian_vocab.sqlite');
    return NativeDatabase.createInBackground(dbFile);
  }

  Future<void> _migrate() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS session_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        seen_at_ms INTEGER NOT NULL,
        reaction_ms INTEGER NOT NULL,
        rewarded INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_session_seen_at
      ON session_log (seen_at_ms)
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS familiarity_state (
        word_id INTEGER PRIMARY KEY,
        strength REAL NOT NULL,
        last_seen_at_ms INTEGER NOT NULL,
        last_reaction_ms INTEGER NOT NULL,
        encounter_count INTEGER NOT NULL
      )
    ''');
  }
}
