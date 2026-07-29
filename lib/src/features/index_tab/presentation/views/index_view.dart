import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_mutashibihat_app/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/build_context_extensions.dart';

import '../../../../core/models.dart';
import '../../domain/providers.dart';

/// Screen 1: Surah Index - Lists all 114 surahs with Mutashabihat ayah counts.
class IndexView extends ConsumerWidget {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.mutashabihatCompanion,
          style: context.textTheme.displayMedium?.copyWith(),
        ),
        elevation: 0,
      ),
      body: surahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: context.textTheme.bodyMedium),
        ),
        data: (surahs) => SurahsItemListView(surahs: surahs),
      ),
    );
  }
}

class SurahsItemListView extends StatelessWidget {
  const SurahsItemListView({super.key, required this.surahs});
  final List<Surah> surahs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return CustomSurahItem(surah: surah);
      },
    );
  }
}

class CustomSurahItem extends StatelessWidget {
  const CustomSurahItem({super.key, required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          surah.nameArabic,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          '${surah.versesCount} ${AppLocalizations.of(context).verses} • ${surah.mutashabihatAyahCount} ${AppLocalizations.of(context).mutashabihat}',
          style: context.textTheme.labelSmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            surah.nameSimple,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ),
        onTap: () {
          context.go('/surah/${surah.id}');
        },
      ),
    );
  }
}
