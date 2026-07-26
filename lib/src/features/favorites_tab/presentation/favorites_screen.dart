import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';

import '../../../core/providers.dart';

/// Favorites Tab Screen - displays user's favorite Ayahs.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).favorites,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: isDark
                        ? const Color(0xFFA29F96)
                        : const Color(0xFF5C6B67),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).noFavoritesYet,
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFEDEDE4)
                          : const Color(0xFF20302C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).addFavoritesFromIndexTab,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFA29F96)
                          : const Color(0xFF5C6B67),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Icon(
                    Icons.favorite,
                    color: const Color(0xFF9C4E68), // rose
                  ),
                  title: Text(
                    '${favorite.surahId}:${favorite.ayahNum}',
                    style: GoogleFonts.newsreader(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFEDEDE4)
                          : const Color(0xFF20302C),
                    ),
                  ),
                  subtitle: favorite.note != null
                      ? Text(
                          favorite.note!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFA29F96)
                                : const Color(0xFF5C6B67),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'Added ${favorite.addedAt.toString().split(' ')[0]}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFA29F96)
                                : const Color(0xFF5C6B67),
                          ),
                        ),
                  onTap: () {
                    context.go(
                      '/surah/${favorite.surahId}/ayah/${favorite.surahId}/${favorite.ayahNum}',
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: Implement edit note functionality
                      } else if (value == 'delete') {
                        // TODO: Implement delete from favorites
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Note'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
