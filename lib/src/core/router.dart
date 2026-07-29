import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/bottom_nav_bar.dart';
import '../features/favorites_tab/presentation/favorites_screen.dart';
import '../features/index_tab/presentation/views/ayah_detail_screen.dart';
import '../features/index_tab/presentation/views/index_screen.dart';
import '../features/index_tab/presentation/views/mutashabihat_ayahs_screen.dart';
import '../features/index_tab/presentation/views/phrase_comparison_screen.dart';
import '../features/my_ayahs_tab/presentation/my_ayahs_add_screen.dart';
import '../features/my_ayahs_tab/presentation/my_ayahs_detail_screen.dart';
import '../features/my_ayahs_tab/presentation/my_ayahs_screen.dart';
import '../features/my_ayahs_tab/presentation/my_ayahs_test_screen.dart';
import '../features/profile_tab/presentation/profile_screen.dart';

/// Scaffold with bottom navigation bar that wraps the tab content.
/// Preserves tab state when switching between tabs.
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// GoRouter configuration with StatefulShellRoute for tab preservation
final router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Index Tab branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const IndexScreen(),
              routes: [
                // Detail routes within Index tab
                GoRoute(
                  path: 'surah/:id',
                  builder: (context, state) => MutashabihatAyahsScreen(
                    surahId: int.parse(state.pathParameters['id']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'ayah/:surahId/:ayahNum',
                      builder: (context, state) => AyahDetailScreen(
                        surahId: int.parse(state.pathParameters['surahId']!),
                        ayahNum: int.parse(state.pathParameters['ayahNum']!),
                      ),
                      routes: [
                        GoRoute(
                          path: 'phrase/:phraseId',
                          builder: (context, state) => PhraseComparisonScreen(
                            phraseId: int.parse(
                              state.pathParameters['phraseId']!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Favorites Tab branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // My Ayahs Tab branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-ayahs',
              builder: (context, state) => const MyAyahsScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const MyAyahsAddScreen(),
                ),
                GoRoute(
                  path: ':surahId/:ayahNum',
                  builder: (context, state) => MyAyahsDetailScreen(
                    surahId: int.parse(state.pathParameters['surahId']!),
                    ayahNum: int.parse(state.pathParameters['ayahNum']!),
                  ),
                ),
                GoRoute(
                  path: 'test',
                  builder: (context, state) => const MyAyahsTestScreen(),
                ),
              ],
            ),
          ],
        ),
        // Profile Tab branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
