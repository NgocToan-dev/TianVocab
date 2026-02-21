import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/word_entry.dart';

class SeedWordRepository {
  const SeedWordRepository();

  Future<List<WordEntry>> loadWords() async {
    final raw = await rootBundle.loadString('assets/seed/words_en_vi.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => WordEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
