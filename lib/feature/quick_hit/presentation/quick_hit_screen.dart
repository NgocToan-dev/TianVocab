import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feature/reward/presentation/reward_banner.dart';
import '../../../shared/providers/app_providers.dart';

class QuickHitScreen extends ConsumerWidget {
  const QuickHitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickHitControllerProvider);
    final controller = ref.read(quickHitControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = state.currentWord;
    if (word == null) {
      return const Scaffold(body: Center(child: Text('No words available')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Hit'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Sessions: ${state.sessionCount}')),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          word.term,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(word.example),
                        const SizedBox(height: 16),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: state.showMeaning ? 1 : 0,
                          child: Text(
                            word.meaning,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: state.showMeaning
                      ? null
                      : controller.revealMeaning,
                  child: const Text('Reveal meaning'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: controller.next,
                  child: const Text('Next quick hit'),
                ),
              ],
            ),
          ),
          if (state.showReward)
            Align(
              alignment: Alignment.topCenter,
              child: RewardBanner(onClose: controller.dismissReward),
            ),
        ],
      ),
    );
  }
}
