import 'package:flutter/material.dart';

/// Profile Tab Screen - displays user settings and preferences.
/// This is a placeholder that will be populated in Phase 8.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Profile Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
