// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tian_vocab/core/database/behavior_metrics_repository.dart';
import 'package:tian_vocab/core/database/seed_word_repository.dart';
import 'package:tian_vocab/core/models/familiarity_state.dart';
import 'package:tian_vocab/core/models/word_entry.dart';

import 'package:tian_vocab/app/app.dart';
import 'package:tian_vocab/shared/providers/app_providers.dart';

class _SmokeSeedRepo extends SeedWordRepository {
  @override
  Future<List<WordEntry>> loadWords() async {
    return const <WordEntry>[
      WordEntry(
        id: 1,
        term: 'focus',
        meaning: 'tập trung',
        example: 'Focus for ten seconds.',
      ),
    ];
  }
}

class _SmokeMetricsRepo extends BehaviorMetricsRepository {
  @override
  Future<Map<int, FamiliarityState>> loadFamiliarityStates() async {
    return <int, FamiliarityState>{};
  }

  @override
  Future<int> getTodaySessionCount(DateTime now) async {
    return 0;
  }

  @override
  Future<double> getTodayAverageReactionMs(DateTime now) async {
    return 0;
  }

  @override
  Future<int> getFamiliarWordCount({double threshold = 0.6}) async {
    return 0;
  }

  @override
  Future<void> recordEncounter({
    required int wordId,
    required DateTime seenAt,
    required int reactionMs,
    required double strength,
    required int encounterCount,
    required bool rewarded,
  }) async {}
}

void main() {
  testWidgets('App renders quick hit screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          seedWordRepositoryProvider.overrideWithValue(_SmokeSeedRepo()),
          behaviorMetricsRepositoryProvider.overrideWithValue(
            _SmokeMetricsRepo(),
          ),
        ],
        child: const TianVocabApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quick Hit'), findsOneWidget);
  });
}
