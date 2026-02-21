import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/services/local_notification_service.dart';
import '../../core/database/behavior_metrics_repository.dart';
import '../../core/database/seed_word_repository.dart';
import '../../core/engine/familiarity_engine.dart';
import '../../core/engine/reward_engine.dart';
import '../../core/engine/word_engine.dart';
import '../../feature/quick_hit/application/quick_hit_controller.dart';
import '../../feature/quick_hit/application/quick_hit_state.dart';

final seedWordRepositoryProvider = Provider<SeedWordRepository>((ref) {
  return const SeedWordRepository();
});

final wordEngineProvider = Provider<WordEngine>((ref) {
  return const WordEngine();
});

final familiarityEngineProvider = Provider<FamiliarityEngine>((ref) {
  return FamiliarityEngine();
});

final rewardEngineProvider = Provider<RewardEngine>((ref) {
  return RewardEngine();
});

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
});

final behaviorMetricsRepositoryProvider = Provider<BehaviorMetricsRepository>((
  ref,
) {
  return BehaviorMetricsRepository();
});

final quickHitControllerProvider =
    StateNotifierProvider<QuickHitController, QuickHitState>((ref) {
  return QuickHitController(
    repository: ref.read(seedWordRepositoryProvider),
    behaviorMetricsRepository: ref.read(behaviorMetricsRepositoryProvider),
    wordEngine: ref.read(wordEngineProvider),
    familiarityEngine: ref.read(familiarityEngineProvider),
    rewardEngine: ref.read(rewardEngineProvider),
  );
});
