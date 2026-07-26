import 'package:flutter/material.dart';

/// My Ayahs Tab Screen - displays user's bookmarked Ayahs.
/// This is a placeholder that will be populated in Phase 7.
class MyAyahsScreen extends StatelessWidget {
  const MyAyahsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ayahs'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Text('My Ayahs Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
