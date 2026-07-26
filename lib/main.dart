import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_mutashibihat_app/src/app.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  // (Crucial because our database service runs native platform channels before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Wrap the root widget in a ProviderScope so Riverpod can manage state
    const ProviderScope(child: MutashabihatApp()),
  );
}
