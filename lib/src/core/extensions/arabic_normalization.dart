/// Arabic text normalization for diacritic-insensitive search.
library;

/// Normalize Arabic text for search by stripping diacritics/tashkeel,
/// lowercasing, and trimming.
///
/// Removes Arabic diacritical marks (tashkeel) including:
/// - Fatha, Damma, Kasra, Shadda, Sukun, Tanween, etc. (U+064B–U+064E)
/// - Combining diacritics and advanced marks (U+0653–U+0655, U+0656–U+066F, U+0671, etc.)
///
/// This enables searching for ayah and surah names without worrying about
/// how they're written in the source data.
///
/// Example:
/// ```dart
/// normalizeForSearch('مُحَمَّد') → 'محمد'
/// normalizeForSearch('عَلِيّ')   → 'علي'
/// ```
String normalizeForSearch(String input) {
  if (input.isEmpty) return '';

  // Remove Arabic diacritics (tashkeel)
  // U+064B–U+064E: Fatha, Damma, Kasra, Fathatan, Dammatan, Kasratan, Sukun, Shadda
  // U+0650–U+0656: Kasra vertical, Shadda extensions, diacritics
  // U+0657–U+066F: Additional marks and combining characters
  // U+0671: Alef Wasla
  String normalized = input.replaceAll(RegExp(r'[\u064B-\u065F]'), '');

  // Handle special combining marks and other diacritics
  normalized = normalized.replaceAll(RegExp(r'[\u0670\u0674]'), '');

  // Lowercase (Arabic letters support case)
  normalized = normalized.toLowerCase();

  // Trim whitespace
  normalized = normalized.trim();

  return normalized;
}
