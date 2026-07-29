import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/l10n/app_localizations.dart';

import '../../../core/providers/providers.dart';
import '../../../core/widgets/arabic_line.dart';
import '../../../core/widgets/pill_badge.dart';

/// Screen 3: Ayah Detail - Shows a single ayah with word-level phrase highlighting.
class AyahDetailScreen extends ConsumerStatefulWidget {
  final int surahId;
  final int ayahNum;

  const AyahDetailScreen({
    super.key,
    required this.surahId,
    required this.ayahNum,
  });

  @override
  ConsumerState<AyahDetailScreen> createState() => _AyahDetailScreenState();
}

class _AyahDetailScreenState extends ConsumerState<AyahDetailScreen> {
  int? _selectedPhraseId;

  @override
  Widget build(BuildContext context) {
    final ayahKey = AyahKey(widget.surahId, widget.ayahNum);
    final ayahAsync = ref.watch(ayahDetailProvider(ayahKey));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/surah/${widget.surahId}'),
        ),
        title: Text(
          '${widget.surahId}:${widget.ayahNum}',
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: ayahAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ayah) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Ayah text with highlighted words
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B2422)
                      : const Color(0xFFFBF7EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3428)
                        : const Color(0xFFE2DAC7),
                  ),
                ),
                child: ArabicLine(
                  words: ayah.words,
                  highlights: ayah.highlights,
                  activePhraseId: _selectedPhraseId,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),

              // Phrase list
              if (ayah.phraseIds.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).sharedPhrases,
                      style: GoogleFonts.newsreader(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFEDEDE4)
                            : const Color(0xFF20302C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ayah.phraseIds.map((phraseId) {
                        final isSelected = _selectedPhraseId == phraseId;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPhraseId = isSelected ? null : phraseId;
                            });
                          },
                          child: PillBadge(
                            label:
                                '${AppLocalizations.of(context).phrase} $phraseId',
                            color: isSelected
                                ? const Color(0xFF0F6B62)
                                : const Color(0xFF0F6B62),
                            tone: isSelected
                                ? PillBadgeTone.solid
                                : PillBadgeTone.soft,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Show comparison for selected phrase
                    if (_selectedPhraseId != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go(
                            '/surah/${widget.surahId}/ayah/${widget.surahId}/${widget.ayahNum}/phrase/$_selectedPhraseId',
                          );
                        },
                        icon: const Icon(Icons.compare_arrows),
                        label: Text(AppLocalizations.of(context).comparePhrase),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
