import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tian_vocab/core/database/behavior_metrics_repository.dart';
import 'package:tian_vocab/core/database/seed_word_repository.dart';
import 'package:tian_vocab/core/models/familiarity_state.dart';
import 'package:tian_vocab/core/models/word_entry.dart';
import 'package:tian_vocab/feature/quick_hit/presentation/quick_hit_screen.dart';
import 'package:tian_vocab/shared/providers/app_providers.dart';

class _GoldenSeedWordRepository extends SeedWordRepository {
  _GoldenSeedWordRepository(this._words);

  final List<WordEntry> _words;

  @override
  Future<List<WordEntry>> loadWords() async => _words;
}

class _GoldenBehaviorMetricsRepository extends BehaviorMetricsRepository {
  _GoldenBehaviorMetricsRepository();

  @override
  Future<Map<int, FamiliarityState>> loadFamiliarityStates() async {
    return <int, FamiliarityState>{};
  }

  @override
  Future<int> getTodaySessionCount(DateTime now) async {
    return 0;
  }

  @override
  Future<double> getTodayAverageReactionMs(DateTime now) async {
    return 0;
  }

  @override
  Future<int> getFamiliarWordCount({double threshold = 0.6}) async {
    return 0;
  }

  @override
  Future<void> recordEncounter({
    required int wordId,
    required DateTime seenAt,
    required int reactionMs,
    required double strength,
    required int encounterCount,
    required bool rewarded,
  }) async {}
}

void main() {
  testWidgets(
    'QuickHit screen goldens',
    (WidgetTester tester) async {
      final seedRepo = _GoldenSeedWordRepository(
        <WordEntry>[
          const WordEntry(
            id: 1,
            term: 'focus',
            meaning: 'tập trung',
            example: 'Focus for ten seconds.',
          ),
        ],
      );

      final metricsRepo = _GoldenBehaviorMetricsRepository();

      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            seedWordRepositoryProvider.overrideWithValue(seedRepo),
            behaviorMetricsRepositoryProvider.overrideWithValue(metricsRepo),
          ],
          child: const MaterialApp(home: QuickHitScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QuickHitScreen),
        matchesGoldenFile('test/goldens/quick_hit_screen.png'),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Reveal meaning'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QuickHitScreen),
        matchesGoldenFile('test/goldens/quick_hit_screen_revealed.png'),
      );
    },
    tags: <String>['golden'],
  );
}
