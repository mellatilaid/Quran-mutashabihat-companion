import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_mutashibihat_app/revirpod_play_arround/test_providers.dart';

class RevirpodTestScreen extends ConsumerWidget {
  const RevirpodTestScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final helloWorldProvier = ref.watch(helloWorldProvider);
    return Scaffold(body: Center(child: Text(helloWorldProvier)));
  }
}
