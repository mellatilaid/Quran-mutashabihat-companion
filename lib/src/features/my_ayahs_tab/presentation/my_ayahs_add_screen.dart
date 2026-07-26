import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';

import '../../../core/providers.dart';

/// My Ayahs Add Screen — search and bookmark difficult ayahs.
class MyAyahsAddScreen extends ConsumerStatefulWidget {
  const MyAyahsAddScreen({super.key});

  @override
  ConsumerState<MyAyahsAddScreen> createState() => _MyAyahsAddScreenState();
}

class _MyAyahsAddScreenState extends ConsumerState<MyAyahsAddScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchController.text.trim();
    final searchResultsAsync = query.length >= 2
        ? ref.watch(searchAyahsProvider(query))
        : const AsyncValue.data([]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).addADifficultAyah,
          style: GoogleFonts.newsreader(
            fontSize: 20,
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by text or "surah:ayah"',
                hintStyle: GoogleFonts.inter(
                  color: isDark
                      ? const Color(0xFFA29F96)
                      : const Color(0xFF5C6B67),
                ),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              loading: () => query.isEmpty
                  ? Center(
                      child: Text(
                        'Search for an ayah (2+ characters)',
                        style: GoogleFonts.inter(
                          color: isDark
                              ? const Color(0xFFA29F96)
                              : const Color(0xFF5C6B67),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (results) {
                if (results.isEmpty && query.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No ayahs found',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? const Color(0xFFA29F96)
                            : const Color(0xFF5C6B67),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final ayah = results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ayah.surah}:${ayah.ayah}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xFFA29F96)
                                          : const Color(0xFF5C6B67),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ayah.text,
                                    style: GoogleFonts.amiri(
                                      fontSize: 17,
                                      color: isDark
                                          ? const Color(0xFFEDEDE4)
                                          : const Color(0xFF20302C),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () async {
                                // Use the provider's add method which updates state automatically
                                await ref
                                    .read(myAyahsProvider.notifier)
                                    .addAyah(ayah.surah, ayah.ayah);
                                if (context.mounted) {
                                  context.go('/my-ayahs');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
