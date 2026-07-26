import 'package:flutter/material.dart';

/// Favorites Tab Screen - displays user's favorite Ayahs.
/// This is a placeholder that will be populated in Phase 6.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Favorites Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
