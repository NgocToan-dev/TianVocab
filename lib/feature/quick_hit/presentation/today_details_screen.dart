import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/behavior_metrics_repository.dart';
import '../../../core/models/word_entry.dart';
import '../../../shared/providers/app_providers.dart';

class TodayDetailsScreen extends ConsumerStatefulWidget {
  const TodayDetailsScreen({super.key});

  @override
  ConsumerState<TodayDetailsScreen> createState() => _TodayDetailsScreenState();
}

class _TodayDetailsScreenState extends ConsumerState<TodayDetailsScreen> {
  late final Future<_TodayDetailsViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData(ref);
  }

  Future<_TodayDetailsViewData> _loadData(WidgetRef ref) async {
    final metricsRepo = ref.read(behaviorMetricsRepositoryProvider);
    final wordRepo = ref.read(seedWordRepositoryProvider);

    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      metricsRepo.getRecentDailySessionCounts(now: DateTime.now(), days: 7),
      metricsRepo.getWeakestWords(limit: 5),
      wordRepo.loadWords(),
    ]);

    final sessions = results[0] as List<DailySessionStat>;
    final weakWords = results[1] as List<WeakWordStat>;
    final words = results[2] as List<WordEntry>;

    final wordMap = <int, WordEntry>{
      for (final word in words) word.id: word,
    };

    return _TodayDetailsViewData(
      sessions: sessions,
      weakWords: weakWords,
      wordMap: wordMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today details')),
      body: FutureBuilder<_TodayDetailsViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Không tải được thống kê. Vui lòng thử lại.'),
            );
          }

          final data = snapshot.data!;
          final maxSession = data.sessions.fold<int>(
            1,
            (current, item) => item.count > current ? item.count : current,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text('7-day sessions',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...data.sessions.map((item) {
                final ratio = (item.count / maxSession).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_formatDay(item.day)),
                          Text('${item.count} sessions'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: ratio),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),
              Text('Top weak words',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              if (data.weakWords.isEmpty)
                const Text('Chưa có dữ liệu từ yếu.')
              else
                ...data.weakWords.map((item) {
                  final word = data.wordMap[item.wordId];
                  final label = word == null ? '#${item.wordId}' : word.term;
                  final percent =
                      (item.strength * 100).clamp(0, 100).toStringAsFixed(0);
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    subtitle: Text('encounters: ${item.encounterCount}'),
                    trailing: Text('$percent%'),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  String _formatDay(DateTime day) {
    final d = day.day.toString().padLeft(2, '0');
    final m = day.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}

class _TodayDetailsViewData {
  const _TodayDetailsViewData({
    required this.sessions,
    required this.weakWords,
    required this.wordMap,
  });

  final List<DailySessionStat> sessions;
  final List<WeakWordStat> weakWords;
  final Map<int, WordEntry> wordMap;
}
