import 'package:flutter_test/flutter_test.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/arabic_normalization.dart';

void main() {
  group('normalizeForSearch', () {
    test('strips Fatha, Damma, Kasra (basic diacritics)', () {
      expect(normalizeForSearch('مُحَمَّد'), 'محمد');
      expect(normalizeForSearch('عَلِيّ'), 'علي');
      // Note: 'الْقُرْآن' has "آن" (Alef with Madda + Noon), which normalizes to "ان"
      expect(normalizeForSearch('الْقُرْآن'), 'القران');
    });

    test('strips Tanween (Fathatan, Dammatan, Kasratan)', () {
      expect(normalizeForSearch('رَحْمَٰن'), 'رحمن');
      expect(normalizeForSearch('بِسْمٍ'), 'بسم');
      expect(normalizeForSearch('الْحَمْدُ'), 'الحمد');
    });

    test('strips Shadda and other advanced marks', () {
      expect(normalizeForSearch('يَآ أَيُّهَا'), 'يا ايها');
      expect(normalizeForSearch('إِنَّ'), 'ان');
    });

    test('removes combining diacritical marks', () {
      expect(normalizeForSearch('مَكَّة'), 'مكة');
      expect(normalizeForSearch('جَنَّة'), 'جنة');
    });

    test('handles mixed case (lowercases input)', () {
      // Assuming lowercase doesn't change much for Arabic,
      // but the function should not throw and produce consistent output
      expect(normalizeForSearch('الله'), 'الله');
    });

    test('trims whitespace', () {
      expect(normalizeForSearch('  محمد  '), 'محمد');
      expect(normalizeForSearch('\tعلي\n'), 'علي');
      expect(normalizeForSearch('  السَّلَام  '), 'السلام');
    });

    test('handles empty string', () {
      expect(normalizeForSearch(''), '');
    });

    test('handles string with only whitespace', () {
      expect(normalizeForSearch('   '), '');
      expect(normalizeForSearch('\n\t '), '');
    });

    test('substring matching scenarios (normalized versions)', () {
      // User types 'محمد' (with or without diacritics)
      final stored = normalizeForSearch('مُحَمَّد');
      final query = normalizeForSearch('محمد');
      expect(stored, query);
      expect(stored.contains(query), true);

      // Partial match after normalization
      final storedFull = normalizeForSearch('الْقُرْآن الْكَرِيم');
      final queryPart = normalizeForSearch('قُرْآن');
      expect(storedFull.contains(queryPart), true);
    });

    test('preserves Arabic letters (no letter removal)', () {
      expect(
        normalizeForSearch('بسم الله الرحمن الرحيم'),
        'بسم الله الرحمن الرحيم',
      );
    });

    test('handles Alef Wasla and special marks', () {
      // U+0671 (Alef Wasla) → U+0627 (regular Alef)
      expect(normalizeForSearch('ٱلله'), 'الله');
    });

    test('handles Alef with Madda and other Alef variants', () {
      // U+0622 (Alef with Madda) → U+0627 (regular Alef)
      expect(normalizeForSearch('آية'), 'اية');
      // U+0623 (Alef with Hamza) → U+0627
      expect(normalizeForSearch('أمر'), 'امر');
      // U+0625 (Alef with Hamza below) → U+0627
      expect(normalizeForSearch('إله'), 'اله');
    });

    test('real-world surah names with diacritics', () {
      expect(normalizeForSearch('سُورَة الْفَاتِحَة'), 'سورة الفاتحة');
      expect(normalizeForSearch('سُورَة الْبَقَرَة'), 'سورة البقرة');
      // "آل" (Alef with Madda + Lam) normalizes to "ال" (regular Alef + Lam)
      expect(normalizeForSearch('سُورَة آل عِمْرَان'), 'سورة ال عمران');
    });

    test('case-insensitive comparison after normalization', () {
      final norm1 = normalizeForSearch('فَاتِحَة');
      // Both should be normalized to the same base form
      expect(norm1, equals(norm1.toLowerCase()));
    });
  });
}
