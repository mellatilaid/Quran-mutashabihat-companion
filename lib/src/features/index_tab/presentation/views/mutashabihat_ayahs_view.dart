import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/providers/providers.dart';

/// Screen 2: Mutashabihat Ayahs - Lists ayahs in a surah that contain shared phrases.
class MutashabihatAyahsView extends ConsumerWidget {
  final int surahId;

  const MutashabihatAyahsView({super.key, required this.surahId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(mutashabihatAyahsProvider(surahId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'سورة $surahId',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ayahs) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: ayahs.length,
          itemBuilder: (context, index) {
            final ayah = ayahs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                title: Text(
                  ayah.text,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Ayah ${ayah.ayah}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  context.go('/surah/$surahId/ayah/$surahId/${ayah.ayah}');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
