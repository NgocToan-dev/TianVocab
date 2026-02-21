import '../../../core/models/word_entry.dart';

class QuickHitState {
  const QuickHitState({
    required this.isLoading,
    required this.currentWord,
    required this.showMeaning,
    required this.showReward,
    required this.sessionCount,
  });

  final bool isLoading;
  final WordEntry? currentWord;
  final bool showMeaning;
  final bool showReward;
  final int sessionCount;

  QuickHitState copyWith({
    bool? isLoading,
    WordEntry? currentWord,
    bool? showMeaning,
    bool? showReward,
    int? sessionCount,
  }) {
    return QuickHitState(
      isLoading: isLoading ?? this.isLoading,
      currentWord: currentWord ?? this.currentWord,
      showMeaning: showMeaning ?? this.showMeaning,
      showReward: showReward ?? this.showReward,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }

  static const initial = QuickHitState(
    isLoading: true,
    currentWord: null,
    showMeaning: false,
    showReward: false,
    sessionCount: 0,
  );
}
