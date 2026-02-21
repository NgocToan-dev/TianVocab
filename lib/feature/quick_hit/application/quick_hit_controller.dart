import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/behavior_metrics_repository.dart';
import '../../../core/database/seed_word_repository.dart';
import '../../../core/engine/familiarity_engine.dart';
import '../../../core/engine/reward_engine.dart';
import '../../../core/engine/word_engine.dart';
import '../../../core/models/familiarity_state.dart';
import '../../../core/models/word_entry.dart';
import 'quick_hit_state.dart';

class QuickHitController extends StateNotifier<QuickHitState> {
  QuickHitController({
    required SeedWordRepository repository,
    required BehaviorMetricsRepository behaviorMetricsRepository,
    required WordEngine wordEngine,
    required FamiliarityEngine familiarityEngine,
    required RewardEngine rewardEngine,
  })  : _repository = repository,
        _behaviorMetricsRepository = behaviorMetricsRepository,
        _wordEngine = wordEngine,
        _familiarityEngine = familiarityEngine,
        _rewardEngine = rewardEngine,
        super(QuickHitState.initial) {
    _bootstrap();
  }

  final SeedWordRepository _repository;
  final BehaviorMetricsRepository _behaviorMetricsRepository;
  final WordEngine _wordEngine;
  final FamiliarityEngine _familiarityEngine;
  final RewardEngine _rewardEngine;

  List<WordEntry> _pool = const [];
  final Map<int, FamiliarityState> _states = <int, FamiliarityState>{};
  DateTime _shownAt = DateTime.now();

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _pool = await _repository.loadWords();

      final persistedStates =
          await _behaviorMetricsRepository.loadFamiliarityStates();
      _states
        ..clear()
        ..addAll(persistedStates);

      final now = DateTime.now();
      final todayCount = await _behaviorMetricsRepository.getTodaySessionCount(
        now,
      );
      final todayAvgReactionMs =
          await _behaviorMetricsRepository.getTodayAverageReactionMs(now);
      final familiarWordsCount =
          await _behaviorMetricsRepository.getFamiliarWordCount();

      state = state.copyWith(
        sessionCount: todayCount,
        avgReactionMs: todayAvgReactionMs,
        familiarWordsCount: familiarWordsCount,
      );

      _pickNextWord(resetReward: true, incrementSessionCount: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        currentWord: null,
        errorMessage: 'Không thể tải dữ liệu. Hãy thử lại.',
      );
    }
  }

  void retry() {
    _bootstrap();
  }

  void revealMeaning() {
    state = state.copyWith(showMeaning: true);
  }

  void next() {
    final currentWord = state.currentWord;
    var encounteredStrength = 0.2;
    var encounteredCount = 1;
    var reactionMs = 0;

    if (currentWord != null) {
      final now = DateTime.now();
      reactionMs = now.difference(_shownAt).inMilliseconds.clamp(100, 5000);
      final previous = _states[currentWord.id];
      final decayed = previous == null
          ? 0.2
          : _familiarityEngine.decay(
              currentStrength: previous.strength,
              idleTime: now.difference(previous.lastSeenAt),
            );
      final nextStrength = _familiarityEngine.reinforce(
        decayedStrength: decayed,
        reactionMs: reactionMs,
      );
      final evolvedState = (previous ??
              FamiliarityState(
                wordId: currentWord.id,
                strength: 0.2,
                lastSeenAt: now,
                lastReactionMs: reactionMs,
                encounterCount: 0,
              ))
          .evolve(
        seenAt: now,
        reactionMs: reactionMs,
        nextStrength: nextStrength,
      );

      _states[currentWord.id] = evolvedState;
      encounteredStrength = evolvedState.strength;
      encounteredCount = evolvedState.encounterCount;

      unawaited(
        _behaviorMetricsRepository.recordEncounter(
          wordId: currentWord.id,
          seenAt: now,
          reactionMs: reactionMs,
          strength: encounteredStrength,
          encounterCount: encounteredCount,
          rewarded: state.showReward,
        ),
      );
    }

    final previousCount = state.sessionCount;
    final previousAvg = state.avgReactionMs;
    if (reactionMs > 0) {
      final nextCount = previousCount + 1;
      final nextAvg = ((previousAvg * previousCount) + reactionMs) / nextCount;
      final familiarWordsCount =
          _states.values.where((item) => item.strength >= 0.6).length;
      state = state.copyWith(
        avgReactionMs: nextAvg,
        familiarWordsCount: familiarWordsCount,
      );
    }

    _pickNextWord();
  }

  void dismissReward() {
    state = state.copyWith(showReward: false);
  }

  void _pickNextWord({
    bool resetReward = false,
    bool incrementSessionCount = true,
  }) {
    final selected = _wordEngine.selectNext(
      pool: List<WordEntry>.of(_pool),
      states: _states,
      now: DateTime.now(),
    );
    _shownAt = DateTime.now();

    final nextSessionCount =
        incrementSessionCount ? state.sessionCount + 1 : state.sessionCount;
    final shouldReward = resetReward
        ? false
        : _rewardEngine.shouldReward(sessionCount: nextSessionCount);

    state = state.copyWith(
      isLoading: false,
      currentWord: selected,
      showMeaning: false,
      showReward: shouldReward,
      sessionCount: nextSessionCount,
      errorMessage: null,
    );
  }
}
