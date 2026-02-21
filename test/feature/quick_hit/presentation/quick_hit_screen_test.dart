import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tian_vocab/core/database/behavior_metrics_repository.dart';
import 'package:tian_vocab/core/database/seed_word_repository.dart';
import 'package:tian_vocab/core/engine/reward_engine.dart';
import 'package:tian_vocab/core/models/familiarity_state.dart';
import 'package:tian_vocab/core/models/word_entry.dart';
import 'package:tian_vocab/feature/quick_hit/presentation/quick_hit_screen.dart';
import 'package:tian_vocab/shared/providers/app_providers.dart';

class FakeSeedWordRepository extends SeedWordRepository {
  FakeSeedWordRepository(this._words);

  final List<WordEntry> _words;

  @override
  Future<List<WordEntry>> loadWords() async => _words;
}

class FakeBehaviorMetricsRepository extends BehaviorMetricsRepository {
  FakeBehaviorMetricsRepository({required this.todayCount});

  final int todayCount;
  final List<int> recordedWordIds = <int>[];

  @override
  Future<Map<int, FamiliarityState>> loadFamiliarityStates() async {
    return <int, FamiliarityState>{};
  }

  @override
  Future<int> getTodaySessionCount(DateTime now) async {
    return todayCount;
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
  }) async {
    recordedWordIds.add(wordId);
  }
}

class AlwaysRewardEngine extends RewardEngine {
  AlwaysRewardEngine();

  @override
  bool shouldReward({required int sessionCount}) => true;
}

void main() {
  testWidgets('opens Today details from app bar icon', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final fakeBehaviorMetrics = FakeBehaviorMetricsRepository(todayCount: 0);
    final fakeSeedWords = FakeSeedWordRepository(
      <WordEntry>[
        const WordEntry(
          id: 1,
          term: 'focus',
          meaning: 'tập trung',
          example: 'Focus for ten seconds.',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          seedWordRepositoryProvider.overrideWithValue(fakeSeedWords),
          behaviorMetricsRepositoryProvider.overrideWithValue(
            fakeBehaviorMetrics,
          ),
        ],
        child: const MaterialApp(home: QuickHitScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Today details'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('reveal/next flow updates UI and shows reward banner', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final fakeBehaviorMetrics = FakeBehaviorMetricsRepository(todayCount: 0);
    final fakeSeedWords = FakeSeedWordRepository(
      <WordEntry>[
        const WordEntry(
          id: 1,
          term: 'focus',
          meaning: 'tập trung',
          example: 'Focus for ten seconds.',
        ),
        const WordEntry(
          id: 2,
          term: 'adapt',
          meaning: 'thích nghi',
          example: 'She adapts quickly.',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          seedWordRepositoryProvider.overrideWithValue(fakeSeedWords),
          behaviorMetricsRepositoryProvider.overrideWithValue(
            fakeBehaviorMetrics,
          ),
          rewardEngineProvider.overrideWithValue(AlwaysRewardEngine()),
        ],
        child: const MaterialApp(home: QuickHitScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick Hit'), findsOneWidget);
    expect(find.text('Sessions: 0'), findsOneWidget);

    final revealButtonFinder = find.widgetWithText(
      FilledButton,
      'Reveal meaning',
    );
    await tester.ensureVisible(revealButtonFinder);
    final revealBeforeTap = tester.widget<FilledButton>(revealButtonFinder);
    expect(revealBeforeTap.onPressed, isNotNull);

    await tester.tap(revealButtonFinder);
    await tester.pump(const Duration(milliseconds: 250));

    final revealAfterTap = tester.widget<FilledButton>(revealButtonFinder);
    expect(revealAfterTap.onPressed, isNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Next quick hit'));
    await tester.pumpAndSettle();

    expect(find.text('Sessions: 1'), findsOneWidget);
    expect(find.text('Nice hit! +Dopamine'), findsOneWidget);
    expect(fakeBehaviorMetrics.recordedWordIds, hasLength(1));

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Nice hit! +Dopamine'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });
}
