import 'package:drift/drift.dart';

import '../models/familiarity_state.dart';
import 'app_database.dart';

class DailySessionStat {
  const DailySessionStat({required this.day, required this.count});

  final DateTime day;
  final int count;
}

class WeakWordStat {
  const WeakWordStat({
    required this.wordId,
    required this.strength,
    required this.encounterCount,
  });

  final int wordId;
  final double strength;
  final int encounterCount;
}

class BehaviorMetricsRepository {
  BehaviorMetricsRepository({Future<AppDatabase> Function()? databaseFactory})
      : _databaseFactory = databaseFactory ?? AppDatabase.instance;

  final Future<AppDatabase> Function() _databaseFactory;
  AppDatabase? _database;

  Future<AppDatabase> _db() async {
    final db = _database;
    if (db != null) {
      return db;
    }
    final opened = await _databaseFactory();
    _database = opened;
    return opened;
  }

  Future<Map<int, FamiliarityState>> loadFamiliarityStates() async {
    final db = await _db();
    final rows = await db
        .customSelect(
          'SELECT word_id, strength, last_seen_at_ms, last_reaction_ms, encounter_count FROM familiarity_state',
        )
        .get();

    final states = <int, FamiliarityState>{};
    for (final row in rows) {
      final state = FamiliarityState(
        wordId: row.read<int>('word_id'),
        strength: row.read<double>('strength'),
        lastSeenAt: DateTime.fromMillisecondsSinceEpoch(
          row.read<int>('last_seen_at_ms'),
        ),
        lastReactionMs: row.read<int>('last_reaction_ms'),
        encounterCount: row.read<int>('encounter_count'),
      );
      states[state.wordId] = state;
    }
    return states;
  }

  Future<int> getTodaySessionCount(DateTime now) async {
    final db = await _db();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).millisecondsSinceEpoch;

    final row = await db.customSelect(
      'SELECT COUNT(*) AS total FROM session_log WHERE seen_at_ms >= ? AND seen_at_ms < ?',
      variables: <Variable<Object>>[
        Variable<Object>(start),
        Variable<Object>(end),
      ],
    ).getSingle();

    return row.read<int>('total');
  }

  Future<double> getTodayAverageReactionMs(DateTime now) async {
    final db = await _db();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).millisecondsSinceEpoch;

    final row = await db.customSelect(
      'SELECT AVG(reaction_ms) AS avg_reaction FROM session_log WHERE seen_at_ms >= ? AND seen_at_ms < ?',
      variables: <Variable<Object>>[
        Variable<Object>(start),
        Variable<Object>(end),
      ],
    ).getSingle();

    final avg = row.data['avg_reaction'];
    if (avg == null) {
      return 0;
    }
    return (avg as num).toDouble();
  }

  Future<int> getFamiliarWordCount({double threshold = 0.6}) async {
    final db = await _db();
    final row = await db.customSelect(
      'SELECT COUNT(*) AS total FROM familiarity_state WHERE strength >= ?',
      variables: <Variable<Object>>[
        Variable<Object>(threshold),
      ],
    ).getSingle();

    return row.read<int>('total');
  }

  Future<List<DailySessionStat>> getRecentDailySessionCounts({
    required DateTime now,
    int days = 7,
  }) async {
    final db = await _db();
    final stats = <DailySessionStat>[];
    final endOfToday = DateTime(now.year, now.month, now.day + 1);

    for (var offset = days - 1; offset >= 0; offset--) {
      final dayStart = DateTime(
        endOfToday.year,
        endOfToday.month,
        endOfToday.day - 1 - offset,
      );
      final dayEnd = DateTime(
        dayStart.year,
        dayStart.month,
        dayStart.day + 1,
      );

      final row = await db.customSelect(
        'SELECT COUNT(*) AS total FROM session_log WHERE seen_at_ms >= ? AND seen_at_ms < ?',
        variables: <Variable<Object>>[
          Variable<Object>(dayStart.millisecondsSinceEpoch),
          Variable<Object>(dayEnd.millisecondsSinceEpoch),
        ],
      ).getSingle();

      stats.add(DailySessionStat(day: dayStart, count: row.read<int>('total')));
    }

    return stats;
  }

  Future<List<WeakWordStat>> getWeakestWords({int limit = 5}) async {
    final db = await _db();
    final rows = await db.customSelect(
      '''
      SELECT word_id, strength, encounter_count
      FROM familiarity_state
      ORDER BY strength ASC, encounter_count ASC
      LIMIT ?
      ''',
      variables: <Variable<Object>>[
        Variable<Object>(limit),
      ],
    ).get();

    return rows
        .map(
          (row) => WeakWordStat(
            wordId: row.read<int>('word_id'),
            strength: row.read<double>('strength'),
            encounterCount: row.read<int>('encounter_count'),
          ),
        )
        .toList(growable: false);
  }

  Future<void> recordEncounter({
    required int wordId,
    required DateTime seenAt,
    required int reactionMs,
    required double strength,
    required int encounterCount,
    required bool rewarded,
  }) async {
    final db = await _db();
    final seenAtMs = seenAt.millisecondsSinceEpoch;

    await db.transaction(() async {
      await db.customStatement(
        'INSERT INTO session_log (word_id, seen_at_ms, reaction_ms, rewarded) VALUES (?, ?, ?, ?)',
        <Object>[wordId, seenAtMs, reactionMs, rewarded ? 1 : 0],
      );

      await db.customStatement(
        '''
        INSERT INTO familiarity_state (
          word_id,
          strength,
          last_seen_at_ms,
          last_reaction_ms,
          encounter_count
        ) VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(word_id) DO UPDATE SET
          strength = excluded.strength,
          last_seen_at_ms = excluded.last_seen_at_ms,
          last_reaction_ms = excluded.last_reaction_ms,
          encounter_count = excluded.encounter_count
        ''',
        <Object>[wordId, strength, seenAtMs, reactionMs, encounterCount],
      );
    });
  }
}
