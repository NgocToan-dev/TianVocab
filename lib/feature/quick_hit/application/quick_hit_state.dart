import '../../../core/models/word_entry.dart';

class QuickHitState {
  static const Object _unset = Object();

  const QuickHitState({
    required this.isLoading,
    required this.currentWord,
    required this.showMeaning,
    required this.showReward,
    required this.sessionCount,
    required this.avgReactionMs,
    required this.familiarWordsCount,
    required this.errorMessage,
  });

  final bool isLoading;
  final WordEntry? currentWord;
  final bool showMeaning;
  final bool showReward;
  final int sessionCount;
  final double avgReactionMs;
  final int familiarWordsCount;
  final String? errorMessage;

  QuickHitState copyWith({
    bool? isLoading,
    Object? currentWord = _unset,
    bool? showMeaning,
    bool? showReward,
    int? sessionCount,
    double? avgReactionMs,
    int? familiarWordsCount,
    Object? errorMessage = _unset,
  }) {
    return QuickHitState(
      isLoading: isLoading ?? this.isLoading,
      currentWord: identical(currentWord, _unset)
          ? this.currentWord
          : currentWord as WordEntry?,
      showMeaning: showMeaning ?? this.showMeaning,
      showReward: showReward ?? this.showReward,
      sessionCount: sessionCount ?? this.sessionCount,
      avgReactionMs: avgReactionMs ?? this.avgReactionMs,
      familiarWordsCount: familiarWordsCount ?? this.familiarWordsCount,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const initial = QuickHitState(
    isLoading: true,
    currentWord: null,
    showMeaning: false,
    showReward: false,
    sessionCount: 0,
    avgReactionMs: 0,
    familiarWordsCount: 0,
    errorMessage: null,
  );
}
