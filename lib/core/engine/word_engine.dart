import '../models/familiarity_state.dart';
import '../models/word_entry.dart';

class WordEngine {
  const WordEngine();

  WordEntry selectNext({
    required List<WordEntry> pool,
    required Map<int, FamiliarityState> states,
    required DateTime now,
  }) {
    if (pool.isEmpty) {
      throw StateError('Word pool is empty.');
    }

    pool.sort(
      (a, b) =>
          _score(a, states[a.id], now).compareTo(_score(b, states[b.id], now)),
    );
    return pool.first;
  }

  double _score(WordEntry word, FamiliarityState? state, DateTime now) {
    if (state == null) {
      return -1;
    }
    final idleMinutes = now
        .difference(state.lastSeenAt)
        .inMinutes
        .clamp(0, 100000)
        .toDouble();
    final strengthPenalty = state.strength * 2;
    final recencyBonus = idleMinutes / 60;
    final speedPenalty = (state.lastReactionMs / 2000).clamp(0, 2).toDouble();
    return strengthPenalty + speedPenalty - recencyBonus;
  }
}
