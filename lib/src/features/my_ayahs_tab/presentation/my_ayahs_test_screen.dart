import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/l10n/app_localizations.dart';

import '../../../core/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/widgets/widgets_index.dart';
import '../../index_tab/domain/models/ayah_key.dart';

/// My Ayahs Test Screen — flashcard test mode for bookmarked ayahs.
/// Hint state: first 3 words + "Reveal full ayah" button
/// Full state: complete ayah + "Missed it" / "Got it" buttons
class MyAyahsTestScreen extends ConsumerStatefulWidget {
  const MyAyahsTestScreen({super.key});

  @override
  ConsumerState<MyAyahsTestScreen> createState() => _MyAyahsTestScreenState();
}

class _MyAyahsTestScreenState extends ConsumerState<MyAyahsTestScreen> {
  late List<(int, int)> _testAyahs; // List of (surah, ayah) tuples
  int _currentIndex = 0;
  bool _revealed = false;
  late int _totalCorrect;
  bool _testComplete = false;

  @override
  void initState() {
    super.initState();
    _totalCorrect = 0;
  }

  void _handleAnswer(bool correct) {
    if (correct) {
      _totalCorrect++;
    }
    if (_currentIndex + 1 >= _testAyahs.length) {
      setState(() => _testComplete = true);
    } else {
      setState(() {
        _currentIndex++;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_testComplete) {
      return _buildCompletionScreen(context, isDark);
    }

    if (_testAyahs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).startTestMode,
            style: GoogleFonts.newsreader(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1B5E20),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final (surah, ayah) = _testAyahs[_currentIndex];
    final ayahDetailAsync = ref.watch(ayahDetailProvider(AyahKey(surah, ayah)));
    final fontSize = ref.watch(arabicFontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1} of ${_testAyahs.length}',
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: AppLocalizations.of(context).exitTest,
                message: AppLocalizations.of(context).yourProgressWillBeLost,
                isDangerous: true,
                onConfirm: () {
                  context.go('/my-ayahs');
                },
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _testAyahs.length,
            minHeight: 3,
          ),
          Expanded(
            child: ayahDetailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (ayahDetail) {
                if (!_revealed) {
                  return _buildHintState(context, ayahDetail, fontSize, isDark);
                } else {
                  return _buildFullState(context, ayahDetail, fontSize, isDark);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintState(
    BuildContext context,
    AyahDetail ayahDetail,
    double fontSize,
    bool isDark,
  ) {
    final firstThreeWords = ayahDetail.words.take(3).toList();
    const dotsText = '· · ·';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'RECALL THE REST',
            style: GoogleFonts.newsreader(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFEDEDE4) : const Color(0xFF20302C),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ...firstThreeWords.map(
                          (w) => Text(
                            w.text,
                            style: GoogleFonts.amiri(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFEDEDE4)
                                  : const Color(0xFF20302C),
                            ),
                          ),
                        ),
                        Text(
                          dotsText,
                          style: GoogleFonts.amiri(
                            fontSize: fontSize,
                            color: isDark
                                ? const Color(0xFFA29F96)
                                : const Color(0xFF5C6B67),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _revealed = true),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Reveal Full Ayah'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullState(
    BuildContext context,
    AyahDetail ayahDetail,
    double fontSize,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ArabicLine(
                words: ayahDetail.words,
                highlights: const [],
                fontSize: fontSize,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Did you get it right?',
            style: GoogleFonts.newsreader(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFEDEDE4) : const Color(0xFF20302C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _handleAnswer(false),
                icon: const Icon(Icons.close),
                label: const Text('Missed It'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA34632), // danger
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleAnswer(true),
                icon: const Icon(Icons.check),
                label: const Text('Got It'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6B62), // teal
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, bool isDark) {
    final percentage = (_totalCorrect / _testAyahs.length * 100)
        .toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Complete',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F6B62).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFF0F6B62), width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        percentage,
                        style: GoogleFonts.newsreader(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F6B62),
                        ),
                      ),
                      Text(
                        '%',
                        style: GoogleFonts.newsreader(
                          fontSize: 20,
                          color: const Color(0xFF0F6B62),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Score: $_totalCorrect / ${_testAyahs.length}',
                style: GoogleFonts.newsreader(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFEDEDE4)
                      : const Color(0xFF20302C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                int.parse(percentage) >= 80
                    ? 'Great job! Keep practicing.'
                    : int.parse(percentage) >= 60
                    ? 'Good effort. Review these ayahs.'
                    : 'Keep studying these challenging ayahs.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFA29F96)
                      : const Color(0xFF5C6B67),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/my-ayahs'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
