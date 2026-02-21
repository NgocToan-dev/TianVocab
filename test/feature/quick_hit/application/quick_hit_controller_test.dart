import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tian_vocab/core/database/behavior_metrics_repository.dart';
import 'package:tian_vocab/core/database/seed_word_repository.dart';
import 'package:tian_vocab/core/engine/familiarity_engine.dart';
import 'package:tian_vocab/core/engine/reward_engine.dart';
import 'package:tian_vocab/core/engine/word_engine.dart';
import 'package:tian_vocab/core/models/familiarity_state.dart';
import 'package:tian_vocab/core/models/word_entry.dart';
import 'package:tian_vocab/feature/quick_hit/application/quick_hit_controller.dart';

class FakeSeedWordRepository extends SeedWordRepository {
  FakeSeedWordRepository(this._words);

  final List<WordEntry> _words;

  @override
  Future<List<WordEntry>> loadWords() async => _words;
}

class RecordedEncounter {
  RecordedEncounter({
    required this.wordId,
    required this.reactionMs,
    required this.strength,
    required this.encounterCount,
    required this.rewarded,
  });

  final int wordId;
  final int reactionMs;
  final double strength;
  final int encounterCount;
  final bool rewarded;
}

class FakeBehaviorMetricsRepository extends BehaviorMetricsRepository {
  FakeBehaviorMetricsRepository({
    required this.persistedStates,
    required this.todayCount,
  });

  final Map<int, FamiliarityState> persistedStates;
  final int todayCount;
  final List<RecordedEncounter> encounters = <RecordedEncounter>[];
  Completer<void>? _recordCompleter;

  Future<void> waitForRecord() async {
    final completer = _recordCompleter;
    if (completer != null) {
      await completer.future;
    }
  }

  @override
  Future<Map<int, FamiliarityState>> loadFamiliarityStates() async {
    return persistedStates;
  }

  @override
  Future<int> getTodaySessionCount(DateTime now) async {
    return todayCount;
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
    _recordCompleter = Completer<void>();
    encounters.add(
      RecordedEncounter(
        wordId: wordId,
        reactionMs: reactionMs,
        strength: strength,
        encounterCount: encounterCount,
        rewarded: rewarded,
      ),
    );
    _recordCompleter!.complete();
  }
}

Future<void> waitForBootstrap(QuickHitController controller) async {
  for (var i = 0; i < 30; i++) {
    if (!controller.state.isLoading) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  fail('QuickHitController bootstrap timeout');
}

void main() {
  final words = <WordEntry>[
    const WordEntry(
      id: 1,
      term: 'adapt',
      meaning: 'thích nghi',
      example: 'She adapts quickly.',
    ),
    const WordEntry(
      id: 2,
      term: 'focus',
      meaning: 'tập trung',
      example: 'Focus for ten seconds.',
    ),
  ];

  test('bootstrap loads words and today session count from repository',
      () async {
    final fakeMetrics = FakeBehaviorMetricsRepository(
      persistedStates: <int, FamiliarityState>{},
      todayCount: 3,
    );

    final controller = QuickHitController(
      repository: FakeSeedWordRepository(words),
      behaviorMetricsRepository: fakeMetrics,
      wordEngine: const WordEngine(),
      familiarityEngine: FamiliarityEngine(),
      rewardEngine: RewardEngine(random: Random(1)),
    );

    await waitForBootstrap(controller);

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.currentWord, isNotNull);
    expect(controller.state.sessionCount, 3);
  });

  test('next increments session and records encounter', () async {
    final fakeMetrics = FakeBehaviorMetricsRepository(
      persistedStates: <int, FamiliarityState>{},
      todayCount: 0,
    );

    final controller = QuickHitController(
      repository: FakeSeedWordRepository(words),
      behaviorMetricsRepository: fakeMetrics,
      wordEngine: const WordEngine(),
      familiarityEngine: FamiliarityEngine(),
      rewardEngine: RewardEngine(random: Random(3)),
    );

    await waitForBootstrap(controller);
    final firstWordId = controller.state.currentWord!.id;

    controller.next();
    await fakeMetrics.waitForRecord();

    expect(controller.state.sessionCount, 1);
    expect(fakeMetrics.encounters, hasLength(1));
    expect(fakeMetrics.encounters.first.wordId, firstWordId);
    expect(fakeMetrics.encounters.first.encounterCount, 1);
    expect(
        fakeMetrics.encounters.first.reactionMs, inInclusiveRange(100, 5000));
  });

  test('revealMeaning toggles meaning visibility', () async {
    final fakeMetrics = FakeBehaviorMetricsRepository(
      persistedStates: <int, FamiliarityState>{},
      todayCount: 0,
    );

    final controller = QuickHitController(
      repository: FakeSeedWordRepository(words),
      behaviorMetricsRepository: fakeMetrics,
      wordEngine: const WordEngine(),
      familiarityEngine: FamiliarityEngine(),
      rewardEngine: RewardEngine(random: Random(5)),
    );

    await waitForBootstrap(controller);
    expect(controller.state.showMeaning, isFalse);

    controller.revealMeaning();

    expect(controller.state.showMeaning, isTrue);
  });

  test(
    'bootstrap with persisted states still picks unseen word first in controller flow',
    () async {
      final now = DateTime(2026, 2, 21, 10, 0);
      final fakeMetrics = FakeBehaviorMetricsRepository(
        persistedStates: <int, FamiliarityState>{
          1: FamiliarityState(
            wordId: 1,
            strength: 0.85,
            lastSeenAt: now.subtract(const Duration(minutes: 10)),
            lastReactionMs: 350,
            encounterCount: 8,
          ),
        },
        todayCount: 2,
      );

      final controller = QuickHitController(
        repository: FakeSeedWordRepository(words),
        behaviorMetricsRepository: fakeMetrics,
        wordEngine: const WordEngine(),
        familiarityEngine: FamiliarityEngine(),
        rewardEngine: RewardEngine(random: Random(7)),
      );

      await waitForBootstrap(controller);

      expect(controller.state.sessionCount, 2);
      expect(controller.state.currentWord, isNotNull);
      expect(controller.state.currentWord!.id, 2);

      controller.next();
      await fakeMetrics.waitForRecord();

      expect(fakeMetrics.encounters, hasLength(1));
      expect(fakeMetrics.encounters.first.wordId, 2);
    },
  );
}
