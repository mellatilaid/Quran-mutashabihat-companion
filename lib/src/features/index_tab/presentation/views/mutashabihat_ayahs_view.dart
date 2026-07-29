import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:quran_mutashibihat_app/src/core/widgets/custom_widgets/custom_app_bar.dart';

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
      appBar: CustomAppBar(
        title: '${context.l10n.surahListTitle} $surahId',
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ayahs) =>
            AyahsSimilatritiesListView(surahId: surahId, ayahs: ayahs),
      ),
    );
  }
}

class AyahsSimilatritiesListView extends StatelessWidget {
  const AyahsSimilatritiesListView({
    super.key,
    required this.ayahs,
    required this.surahId,
  });

  final int surahId;
  final List<AyahListItem> ayahs; // Placeholder for actual data

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.dimensionsTheme.paddingHelpIndication,
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        final ayah = ayahs[index];
        return CustomAyahItem(ayah: ayah, surahId: surahId);
      },
    );
  }
}

class CustomAyahItem extends StatelessWidget {
  const CustomAyahItem({super.key, required this.ayah, required this.surahId});

  final AyahListItem ayah;
  final int surahId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: context.dimensionsTheme.paddingHelpIndication,
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
          '${context.l10n.ayahMarkerLabel} ${ayah.ayah}',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          context.go('/surah/$surahId/ayah/$surahId/${ayah.ayah}');
        },
      ),
    );
  }
}
