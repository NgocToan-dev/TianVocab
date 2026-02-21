import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feature/reward/presentation/reward_banner.dart';
import '../../../shared/providers/app_providers.dart';
import 'today_details_screen.dart';

class QuickHitScreen extends ConsumerWidget {
  const QuickHitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickHitControllerProvider);
    final controller = ref.read(quickHitControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quick Hit')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: controller.retry,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final word = state.currentWord;
    if (word == null) {
      return const Scaffold(body: Center(child: Text('No words available')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Hit'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Today details',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TodayDetailsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.insights_outlined),
          ),
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
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Today avg: ${state.avgReactionMs.toStringAsFixed(0)}ms',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Familiar: ${state.familiarWordsCount}',
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed:
                      state.showMeaning ? null : controller.revealMeaning,
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
