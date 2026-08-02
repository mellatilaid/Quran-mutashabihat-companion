import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/constants/app_colors.dart';
import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:quran_mutashibihat_app/src/core/widgets/confirm_dialog.dart';
import 'package:quran_mutashibihat_app/src/core/widgets/custom_widgets/custom_loading_widget.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/arabic_line.dart';
import '../../../../core/widgets/custom_widgets/custom_error_widget.dart';
import '../../domain/models/ayah_key.dart';

/// Gets the phrase marker color based on phrase index and theme brightness.
/// Cycles through teal, gold, and rose (3-color palette).
Color _getPhraseMarkerColor(int phraseIndex, Brightness brightness) {
  final colorIndex = phraseIndex % 3;
  final isDark = brightness == Brightness.dark;

  return switch (colorIndex) {
    0 => isDark ? AppColors.darkTeal : AppColors.lightTeal,
    1 => isDark ? AppColors.darkGold : AppColors.lightGold,
    _ => isDark ? AppColors.darkRose : AppColors.lightRose,
  }.withValues(alpha: 0.5);
}

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

class AyahDetailsViewBody extends ConsumerStatefulWidget {
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
  ConsumerState<AyahDetailsViewBody> createState() =>
      _AyahDetailsViewBodyState();
}

class _AyahDetailsViewBodyState extends ConsumerState<AyahDetailsViewBody> {
  int? _selectedPhraseId;

  /// Build a map of phrase IDs to their marker colors.
  Map<int, Color> _buildPhraseColorsMap(BuildContext context) {
    final colors = <int, Color>{};
    for (var i = 0; i < widget.ayahDetail.phraseIds.length; i++) {
      final phraseId = widget.ayahDetail.phraseIds[i];
      colors[phraseId] = _getPhraseMarkerColor(i, context.theme.brightness);
    }
    return colors;
  }

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
                phraseColors: _buildPhraseColorsMap(context),
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
                    '${context.l10n.sharedPhrases} (${widget.ayahDetail.phraseIds.length})',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    spacing: 12,
                    children: widget.ayahDetail.phraseIds.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final phraseId = entry.value;
                      final isSelected = _selectedPhraseId == phraseId;
                      final markerColor = _getPhraseMarkerColor(
                        index,
                        Theme.of(context).brightness,
                      );

                      return _PhraseListItem(
                        phraseId: phraseId,
                        markerColor: markerColor,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedPhraseId = isSelected ? null : phraseId;
                          });
                        },
                        onNavigate: () {
                          context.go(
                            '/surah/${widget.surahId}/ayah/${widget.surahId}/${widget.ayahNum}/phrase/$phraseId',
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.tapColoredDot,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Note section
            NoteSection(surahId: widget.surahId, ayahNum: widget.ayahNum),
          ],
        ),
      ),
    );
  }
}

/// Note section widget for editing and displaying ayah notes
class NoteSection extends ConsumerStatefulWidget {
  final int surahId;
  final int ayahNum;

  const NoteSection({super.key, required this.surahId, required this.ayahNum});

  @override
  ConsumerState<NoteSection> createState() => _NoteSectionState();
}

class _NoteSectionState extends ConsumerState<NoteSection> {
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _startEditing(String currentText) {
    setState(() {
      _isEditing = true;
      _noteController.text = currentText;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _noteController.clear();
    });
  }

  void _validateAndSave() {
    final trimmedText = _noteController.text.trim();

    // Reject empty or whitespace-only text
    if (trimmedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).error),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Reject if over 500 chars
    if (trimmedText.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).error),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Save the note
    ref
        .read(userDataRepositoryProvider)
        .saveNote(widget.surahId, widget.ayahNum, trimmedText);

    // Invalidate provider to refresh
    ref.invalidate(noteProvider(AyahKey(widget.surahId, widget.ayahNum)));

    setState(() {
      _isEditing = false;
      _noteController.clear();
    });
  }

  Future<void> _showDeleteConfirm() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppLocalizations.of(context).deleteNote,
      message: AppLocalizations.of(context).deleteNoteConfirm,
      confirmLabel: AppLocalizations.of(context).delete,
      cancelLabel: AppLocalizations.of(context).cancel,
      isDangerous: true,
    );

    if (confirmed) {
      // Delete the note
      await ref
          .read(userDataRepositoryProvider)
          .deleteNote(widget.surahId, widget.ayahNum);

      // Invalidate provider to refresh
      ref.invalidate(noteProvider(AyahKey(widget.surahId, widget.ayahNum)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(
      noteProvider(AyahKey(widget.surahId, widget.ayahNum)),
    );

    return noteAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CustomLoadingWidget()),
      ),
      error: (err, stack) => CustomErrorWidget(errString: 'Error: $err'),
      data: (note) {
        if (_isEditing) {
          // Edit mode
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).editNote,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: null,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).addYourNote,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    counterText: '${_noteController.text.length}/500',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _cancelEditing,
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _validateAndSave,
                      child: Text(AppLocalizations.of(context).save),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (note != null) {
          // Display saved note
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).myNoteSection,
                      style: context.textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEditing(note.noteText),
                          tooltip: AppLocalizations.of(context).editNote,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: context.colorScheme.error,
                          ),
                          onPressed: _showDeleteConfirm,
                          tooltip: AppLocalizations.of(context).deleteNote,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(note.noteText, style: context.textTheme.bodyMedium),
              ],
            ),
          );
        } else {
          // Empty state
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).myNoteSection,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).addYourNote,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _startEditing(''),
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).addNote),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Individual phrase list item with color marker and occurrence count.
class _PhraseListItem extends ConsumerWidget {
  final int phraseId;
  final Color markerColor;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  const _PhraseListItem({
    required this.phraseId,
    required this.markerColor,
    required this.isSelected,
    required this.onTap,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phraseAsync = ref.watch(phraseProvider(phraseId));

    return phraseAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorScheme.error),
        ),
        child: Text(
          context.l10n.errorLoadingPhrase,
          style: context.textTheme.bodyMedium,
        ),
      ),
      data: (phrase) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? markerColor.withValues(alpha: 0.15)
                  : context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? markerColor
                    : context.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Colored dot + phrase text
                Row(
                  children: [
                    // Colored dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phrase text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.l10n.phrase} #$phraseId',
                          style: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${phrase.occurrenceCount} ${phrase.occurrenceCount == 1 ? context.l10n.occurrence : context.l10n.occurrences}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Right: Arrow icon
                GestureDetector(
                  onTap: onNavigate,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
