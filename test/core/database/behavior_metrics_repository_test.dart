import 'package:flutter_test/flutter_test.dart';
import 'package:tian_vocab/core/database/app_database.dart';
import 'package:tian_vocab/core/database/behavior_metrics_repository.dart';

void main() {
  group('BehaviorMetricsRepository', () {
    late AppDatabase db;
    late BehaviorMetricsRepository repository;

    setUp(() async {
      db = await AppDatabase.inMemory();
      repository = BehaviorMetricsRepository(databaseFactory: () async => db);
    });

    tearDown(() async {
      await db.close();
    });

    test('recordEncounter inserts session and upserts familiarity state',
        () async {
      final seenAt = DateTime(2026, 2, 21, 9, 30);

      await repository.recordEncounter(
        wordId: 10,
        seenAt: seenAt,
        reactionMs: 420,
        strength: 0.45,
        encounterCount: 1,
        rewarded: false,
      );

      await repository.recordEncounter(
        wordId: 10,
        seenAt: seenAt.add(const Duration(minutes: 5)),
        reactionMs: 300,
        strength: 0.70,
        encounterCount: 2,
        rewarded: true,
      );

      final states = await repository.loadFamiliarityStates();

      expect(states.keys, contains(10));
      expect(states[10]!.strength, closeTo(0.70, 0.0001));
      expect(states[10]!.encounterCount, 2);
      expect(states[10]!.lastReactionMs, 300);

      final dayCount = await repository.getTodaySessionCount(
        DateTime(2026, 2, 21, 20),
      );
      expect(dayCount, 2);
    });

    test('getTodaySessionCount excludes events outside selected day', () async {
      await repository.recordEncounter(
        wordId: 1,
        seenAt: DateTime(2026, 2, 21, 8),
        reactionMs: 500,
        strength: 0.3,
        encounterCount: 1,
        rewarded: false,
      );
      await repository.recordEncounter(
        wordId: 2,
        seenAt: DateTime(2026, 2, 22, 8),
        reactionMs: 450,
        strength: 0.35,
        encounterCount: 1,
        rewarded: false,
      );

      final countDay21 = await repository.getTodaySessionCount(
        DateTime(2026, 2, 21, 23, 59),
      );
      final countDay22 = await repository.getTodaySessionCount(
        DateTime(2026, 2, 22, 10),
      );

      expect(countDay21, 1);
      expect(countDay22, 1);
    });
  });
}
