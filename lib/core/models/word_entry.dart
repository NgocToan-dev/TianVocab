class WordEntry {
  const WordEntry({
    required this.id,
    required this.term,
    required this.meaning,
    required this.example,
  });

  final int id;
  final String term;
  final String meaning;
  final String example;

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      id: json['id'] as int,
      term: json['term'] as String,
      meaning: json['meaning'] as String,
      example: json['example'] as String,
    );
  }
}
