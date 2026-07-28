import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/providers.dart';
import '../../../core/widgets/widgets_index.dart';

/// My Ayahs Detail Screen — plain ayah view with personal notes.
/// Unlike AyahDetailScreen, this shows no Mutashabihat highlights.
class MyAyahsDetailScreen extends ConsumerStatefulWidget {
  final int surahId;
  final int ayahNum;

  const MyAyahsDetailScreen({
    super.key,
    required this.surahId,
    required this.ayahNum,
  });

  @override
  ConsumerState<MyAyahsDetailScreen> createState() =>
      _MyAyahsDetailScreenState();
}

class _MyAyahsDetailScreenState extends ConsumerState<MyAyahsDetailScreen> {
  late TextEditingController _noteController;
  bool _isEditingNote = false;

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

  @override
  Widget build(BuildContext context) {
    final ayahDetailAsync = ref.watch(
      ayahDetailProvider(AyahKey(widget.surahId, widget.ayahNum)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surah ${widget.surahId} — Ayah ${widget.ayahNum}',
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/my-ayahs'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement delete with undo
            },
          ),
        ],
      ),
      body: ayahDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ayahDetail) {
          final fontSize = ref.watch(arabicFontSizeProvider);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ayah card (plain, no highlights)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AyahMarker(ayahNumber: widget.ayahNum),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ArabicLine(
                              words: ayahDetail.words,
                              highlights: const [],
                              fontSize: fontSize,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // My Note section
              Text(
                'My Note',
                style: GoogleFonts.newsreader(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFEDEDE4)
                      : const Color(0xFF20302C),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isEditingNote
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _noteController,
                              maxLines: 4,
                              minLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Why is this one hard to recall?',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Save note to database
                                setState(() => _isEditingNote = false);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Save'),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() => _isEditingNote = true);
                          },
                          child: _noteController.text.isEmpty
                              ? Text(
                                  'Add your own notes...',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark
                                        ? const Color(0xFFA29F96)
                                        : const Color(0xFF5C6B67),
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _noteController.text,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: isDark
                                            ? const Color(0xFFEDEDE4)
                                            : const Color(0xFF20302C),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ShareNoteButton(
                                      textToCopy: _noteController.text,
                                    ),
                                  ],
                                ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
