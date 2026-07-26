import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ayah marker widget with gold star and Arabic-Indic numeral.
/// 26px size with 10-point star.
class AyahMarker extends StatelessWidget {
  final int ayahNumber;

  const AyahMarker({super.key, required this.ayahNumber});

  /// Convert Western numeral to Arabic-Indic numeral.
  String _toArabicIndic(int number) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicIndic[int.parse(digit)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gold star background (10-point)
          Icon(
            Icons.star,
            size: 26,
            color: const Color(0xFFB8862E), // gold
          ),
          // Arabic-Indic numeral
          Text(
            _toArabicIndic(ayahNumber),
            style: GoogleFonts.amiri(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
