class FamiliarityEngine {
  double decay({required double currentStrength, required Duration idleTime}) {
    final minutes = idleTime.inMinutes.clamp(0, 60 * 24 * 30).toDouble();
    final multiplier = 1 / (1 + minutes / 240);
    return (currentStrength * multiplier).clamp(0.05, 1.0);
  }

  double reinforce({required double decayedStrength, required int reactionMs}) {
    final speedBonus = (2000 - reactionMs).clamp(0, 2000) / 2000;
    final next = decayedStrength + (0.1 + 0.25 * speedBonus);
    return next.clamp(0.05, 1.0);
  }
}
