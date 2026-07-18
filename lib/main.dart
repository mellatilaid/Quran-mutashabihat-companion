import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/files/example_usage.dart';

void main() async {
  // 1. Ensure Flutter engine bindings are initialized
  // (Crucial because our database service runs native platform channels before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // 2. Wrap the root widget in a ProviderScope so Riverpod can manage state
    const ProviderScope(child: MutashabihatApp()),
  );
}

class MutashabihatApp extends StatelessWidget {
  const MutashabihatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mutashabihat Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B5E20), // Spiritual Quranic Green
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF004D40),
          background: const Color(0xFFF9FAFB), // Clean off-white background
        ),
        // Configure global typography settings with Amiri font for proper Arabic support
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.amiri(),
          bodyMedium: GoogleFonts.amiri(),
          bodySmall: GoogleFonts.amiri(),
          displayLarge: GoogleFonts.amiri(),
          displayMedium: GoogleFonts.amiri(),
          displaySmall: GoogleFonts.amiri(),
          headlineLarge: GoogleFonts.amiri(),
          headlineMedium: GoogleFonts.amiri(),
          headlineSmall: GoogleFonts.amiri(),
          titleLarge: GoogleFonts.amiri(),
          titleMedium: GoogleFonts.amiri(),
          titleSmall: GoogleFonts.amiri(),
          labelLarge: GoogleFonts.amiri(),
          labelMedium: GoogleFonts.amiri(),
          labelSmall: GoogleFonts.amiri(),
        ),
      ),
      home: const SurahIndexScreen(),
    );
  }
}
