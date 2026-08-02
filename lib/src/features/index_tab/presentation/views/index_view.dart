import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/build_context_extensions.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/arabic_normalization.dart';

import '../../../../core/models.dart';
import '../../../../core/widgets/custom_widgets/custom_app_bar.dart';
import '../../domain/providers.dart';

/// Screen 1: Surah Index - Lists all 114 surahs with Mutashabihat ayah counts.
class IndexView extends ConsumerWidget {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.mutashabihatCompanion),
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

class SurahsItemListView extends StatefulWidget {
  const SurahsItemListView({super.key, required this.surahs});
  final List<Surah> surahs;

  @override
  State<SurahsItemListView> createState() => _SurahsItemListViewState();
}

class _SurahsItemListViewState extends State<SurahsItemListView> {
  late TextEditingController _searchController;
  late List<Surah> _filteredSurahs;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredSurahs = widget.surahs;
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSurahs() {
    final query = normalizeForSearch(_searchController.text);

    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = widget.surahs;
      } else {
        _filteredSurahs = widget.surahs.where((surah) {
          final normalizedArabic = normalizeForSearch(surah.nameArabic);
          final normalizedSimple = normalizeForSearch(surah.nameSimple);
          return normalizedArabic.contains(query) || normalizedSimple.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.searchQueryHint,
              hintTextDirection: TextDirection.rtl,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        // List or empty state
        Expanded(
          child: _filteredSurahs.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.searchNoResults,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return CustomSurahItem(surah: surah);
                  },
                ),
        ),
      ],
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
