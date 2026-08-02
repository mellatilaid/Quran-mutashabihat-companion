import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:quran_mutashibihat_app/src/core/widgets/custom_widgets/custom_loading_widget.dart';
import 'package:quran_mutashibihat_app/src/core/widgets/confirm_dialog.dart';

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
            const SizedBox(height: 24),

            // Note section
            NoteSection(
              surahId: widget.surahId,
              ayahNum: widget.ayahNum,
            ),
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

  const NoteSection({
    super.key,
    required this.surahId,
    required this.ayahNum,
  });

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
    ref.read(userDataRepositoryProvider).saveNote(
      widget.surahId,
      widget.ayahNum,
      trimmedText,
    );
    
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
      await ref.read(userDataRepositoryProvider).deleteNote(
        widget.surahId,
        widget.ayahNum,
      );

      // Invalidate provider to refresh
      ref.invalidate(noteProvider(AyahKey(widget.surahId, widget.ayahNum)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync =
        ref.watch(noteProvider(AyahKey(widget.surahId, widget.ayahNum)));

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
                Text(
                  note.noteText,
                  style: context.textTheme.bodyMedium,
                ),
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
                color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.colorScheme.onSurfaceVariant),
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
