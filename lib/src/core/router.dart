import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder screens
class SurahIndexScreen extends StatelessWidget {
  const SurahIndexScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Surah Index')));
}

class MutashabihatAyahsScreen extends StatelessWidget {
  final int surahId;
  const MutashabihatAyahsScreen({super.key, required this.surahId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Ayahs: $surahId')));
}

class AyahDetailScreen extends StatelessWidget {
  final int surahId;
  final int ayahNum;
  const AyahDetailScreen({
    super.key,
    required this.surahId,
    required this.ayahNum,
  });
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Ayah: $surahId:$ayahNum')));
}

class PhraseComparisonScreen extends StatelessWidget {
  final int phraseId;
  const PhraseComparisonScreen({super.key, required this.phraseId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Phrase: $phraseId')));
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Favorites')));
}

class MyAyahsScreen extends StatelessWidget {
  const MyAyahsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('My Ayahs')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile')));
}

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SurahIndexScreen()),
    GoRoute(
      path: '/surah/:id',
      builder: (context, state) => MutashabihatAyahsScreen(
        surahId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/ayah/:surahId/:ayahNum',
      builder: (context, state) => AyahDetailScreen(
        surahId: int.parse(state.pathParameters['surahId']!),
        ayahNum: int.parse(state.pathParameters['ayahNum']!),
      ),
    ),
    GoRoute(
      path: '/phrase/:phraseId',
      builder: (context, state) => PhraseComparisonScreen(
        phraseId: int.parse(state.pathParameters['phraseId']!),
      ),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/my-ayahs',
      builder: (context, state) => const MyAyahsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
