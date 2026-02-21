import 'dart:math';

class RewardEngine {
  RewardEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  bool shouldReward({required int sessionCount}) {
    const baseRate = 0.25;
    final pityBoost = sessionCount % 5 == 0 ? 0.2 : 0.0;
    final threshold = (baseRate + pityBoost).clamp(0.0, 0.9);
    return _random.nextDouble() < threshold;
  }
}
