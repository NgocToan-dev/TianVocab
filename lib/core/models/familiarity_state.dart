class FamiliarityState {
  const FamiliarityState({
    required this.wordId,
    required this.strength,
    required this.lastSeenAt,
    required this.lastReactionMs,
    required this.encounterCount,
  });

  final int wordId;
  final double strength;
  final DateTime lastSeenAt;
  final int lastReactionMs;
  final int encounterCount;

  FamiliarityState evolve({
    required DateTime seenAt,
    required int reactionMs,
    required double nextStrength,
  }) {
    return FamiliarityState(
      wordId: wordId,
      strength: nextStrength,
      lastSeenAt: seenAt,
      lastReactionMs: reactionMs,
      encounterCount: encounterCount + 1,
    );
  }
}
