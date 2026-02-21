import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feature/quick_hit/presentation/quick_hit_screen.dart';
import '../shared/providers/app_providers.dart';

class TianVocabApp extends ConsumerStatefulWidget {
  const TianVocabApp({super.key});

  @override
  ConsumerState<TianVocabApp> createState() => _TianVocabAppState();
}

class _TianVocabAppState extends ConsumerState<TianVocabApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(localNotificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tian Vocab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const QuickHitScreen(),
    );
  }
}
