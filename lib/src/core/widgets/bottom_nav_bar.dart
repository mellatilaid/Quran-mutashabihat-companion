import 'package:flutter/material.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/build_context_extensions.dart';

/// App bottom navigation bar with 4 tabs.
/// 64px height with teal active indicator and Inter 11px labels.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: context.colorScheme.surface,
      selectedItemColor: context.colorScheme.primary,
      unselectedItemColor: context.colorScheme.onSurfaceVariant,
      selectedLabelStyle: context.textTheme.labelSmall,
      unselectedLabelStyle: context.textTheme.labelSmall,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: context.l10n.indexTabLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: context.l10n.favoritesTabLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: context.l10n.myAyahsTabLabel,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: context.l10n.profileTabLabel,
        ),
      ],
    );
  }
}
