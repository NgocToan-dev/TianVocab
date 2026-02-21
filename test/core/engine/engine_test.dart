import 'package:flutter_test/flutter_test.dart';
import 'package:tian_vocab/core/engine/familiarity_engine.dart';
import 'package:tian_vocab/core/engine/word_engine.dart';
import 'package:tian_vocab/core/models/familiarity_state.dart';
import 'package:tian_vocab/core/models/word_entry.dart';

void main() {
  group('FamiliarityEngine', () {
    test('decay reduces strength over idle time', () {
      final engine = FamiliarityEngine();

      final decayed = engine.decay(
        currentStrength: 0.8,
        idleTime: const Duration(hours: 12),
      );

      expect(decayed, lessThan(0.8));
      expect(decayed, greaterThanOrEqualTo(0.05));
    });

    test('reinforce increases strength with faster reaction', () {
      final engine = FamiliarityEngine();

      final fast = engine.reinforce(decayedStrength: 0.3, reactionMs: 300);
      final slow = engine.reinforce(decayedStrength: 0.3, reactionMs: 1800);

      expect(fast, greaterThan(slow));
      expect(fast, inInclusiveRange(0.05, 1.0));
      expect(slow, inInclusiveRange(0.05, 1.0));
    });
  });

  group('WordEngine', () {
    test('prioritizes unseen words first', () {
      const engine = WordEngine();
      final now = DateTime(2026, 2, 21, 10);
      final pool = <WordEntry>[
        const WordEntry(
            id: 1, term: 'known', meaning: 'đã biết', example: 'known'),
        const WordEntry(id: 2, term: 'new', meaning: 'mới', example: 'new'),
      ];
      final states = <int, FamiliarityState>{
        1: FamiliarityState(
          wordId: 1,
          strength: 0.8,
          lastSeenAt: now.subtract(const Duration(minutes: 5)),
          lastReactionMs: 400,
          encounterCount: 5,
        ),
      };

      final selected = engine.selectNext(pool: pool, states: states, now: now);

      expect(selected.id, 2);
    });

    test('throws when pool is empty', () {
      const engine = WordEngine();

      expect(
        () => engine.selectNext(
            pool: <WordEntry>[],
            states: <int, FamiliarityState>{},
            now: DateTime.now()),
        throwsStateError,
      );
    });
  });
}
