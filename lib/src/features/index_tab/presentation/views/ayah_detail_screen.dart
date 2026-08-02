import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:quran_mutashibihat_app/src/core/widgets/custom_widgets/custom_loading_widget.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/arabic_line.dart';
import '../../../../core/widgets/custom_widgets/custom_error_widget.dart';
import '../../../../core/widgets/pill_badge.dart';
import '../../domain/models/ayah_key.dart';

/// Screen 3: Ayah Detail - Shows a single ayah with word-level phrase highlighting.
class AyahDetailScreen extends ConsumerWidget {
  final int surahId;
  final int ayahNum;

  const AyahDetailScreen({
    super.key,
    required this.surahId,
    required this.ayahNum,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahKey = AyahKey(surahId, ayahNum);
    final ayahAsync = ref.watch(ayahDetailProvider(ayahKey));
    final isFavoriteAsync = ref.watch(isFavoriteProvider((surahId, ayahNum)));

    return Scaffold(
      appBar: AppBar(
        title: Text('$surahId:$ayahNum'),
        elevation: 0,
        actions: [
          isFavoriteAsync.when(
            loading: () =>
                const SizedBox.square(dimension: 48, child: SizedBox()),
            error: (err, stack) =>
                const SizedBox.square(dimension: 48, child: SizedBox()),
            data: (isFavorite) {
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? context.colorScheme.error
                      : context.colorScheme.onSurfaceVariant,
                ),
                tooltip: isFavorite
                    ? AppLocalizations.of(context).removeFromFavorites
                    : AppLocalizations.of(context).addToFavorites,
                onPressed: () async {
                  final userDataRepository = ref.read(
                    userDataRepositoryProvider,
                  );

                  if (isFavorite) {
                    await userDataRepository.removeFavorite(surahId, ayahNum);
                  } else {
                    await userDataRepository.addFavorite(surahId, ayahNum);
                  }

                  // Invalidate the favorite providers to update UI
                  ref.invalidate(isFavoriteProvider((surahId, ayahNum)));
                  ref.invalidate(favoritesProvider);
                },
              );
            },
          ),
        ],
      ),
      body: ayahAsync.when(
        loading: () => CustomLoadingWidget(),
        error: (err, stack) => CustomErrorWidget(errString: 'Error: $err'),
        data: (ayah) => AyahDetailsViewBody(
          ayahDetail: ayah,
          surahId: surahId,
          ayahNum: ayahNum,
        ),
      ),
    );
  }
}

class AyahDetailsViewBody extends StatefulWidget {
  const AyahDetailsViewBody({
    super.key,
    required this.ayahDetail,
    required this.surahId,
    required this.ayahNum,
  });

  final AyahDetail ayahDetail;
  final int surahId;
  final int ayahNum;

  @override
  State<AyahDetailsViewBody> createState() => _AyahDetailsViewBodyState();
}

class _AyahDetailsViewBodyState extends State<AyahDetailsViewBody> {
  int? _selectedPhraseId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ayah text with highlighted words
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              child: ArabicLine(
                words: widget.ayahDetail.words,
                highlights: widget.ayahDetail.highlights,
                activePhraseId: _selectedPhraseId,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),

            // Phrase list
            if (widget.ayahDetail.phraseIds.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.sharedPhrases,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.ayahDetail.phraseIds.map((phraseId) {
                      final isSelected = _selectedPhraseId == phraseId;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPhraseId = isSelected ? null : phraseId;
                          });
                        },
                        child: PillBadge(
                          label: '${context.l10n.phrase} $phraseId',
                          color: context.colorScheme.primary,
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
                      label: Text(context.l10n.comparePhrase),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
