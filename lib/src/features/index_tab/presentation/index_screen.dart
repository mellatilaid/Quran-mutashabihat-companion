import 'package:flutter/material.dart';

/// Index Tab Screen - displays list of all Surahs with Mutashabihat counts.
/// This is a placeholder that will be populated in Phase 5.
class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Index Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
