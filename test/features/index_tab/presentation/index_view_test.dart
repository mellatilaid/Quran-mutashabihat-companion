import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:quran_mutashibihat_app/src/features/index_tab/presentation/views/index_view.dart';

// Mock data for testing
final _mockSurahs = [
  Surah(
    id: 1,
    nameArabic: 'الفَاتِحَة',
    nameSimple: 'Al-Fatihah',
    versesCount: 7,
    mutashabihatAyahCount: 2,
  ),
  Surah(
    id: 2,
    nameArabic: 'البَقَرَة',
    nameSimple: 'Al-Baqarah',
    versesCount: 286,
    mutashabihatAyahCount: 48,
  ),
  Surah(
    id: 3,
    nameArabic: 'آل عِمْرَان',
    nameSimple: 'Ali Imran',
    versesCount: 200,
    mutashabihatAyahCount: 28,
  ),
  Surah(
    id: 4,
    nameArabic: 'النِّسَاء',
    nameSimple: 'An-Nisa',
    versesCount: 176,
    mutashabihatAyahCount: 18,
  ),
];

Widget buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      home: child,
    ),
  );
}

void main() {
  group('IndexView Search Tests', () {
    testWidgets('renders search field and all surahs initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Verify search field is rendered
      expect(find.byType(TextField), findsOneWidget);

      // Verify all 4 surahs are displayed
      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(CustomSurahItem), findsNWidgets(4));
    });

    testWidgets('filters surahs by Arabic name', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Type "فاتح" (Fatih without diacritics) to filter
      await tester.enterText(find.byType(TextField), 'فاتح');
      await tester.pumpAndSettle();

      // Should show only Al-Fatihah
      expect(find.byType(CustomSurahItem), findsOneWidget);
      expect(find.text('الفَاتِحَة'), findsOneWidget);
    });

    testWidgets('filters surahs by English name', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Type "Baq" to filter by English name
      await tester.enterText(find.byType(TextField), 'Baq');
      await tester.pumpAndSettle();

      // Should show only Al-Baqarah
      expect(find.byType(CustomSurahItem), findsOneWidget);
      expect(find.text('البَقَرَة'), findsOneWidget);
    });

    testWidgets('shows empty state when no surahs match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Type a non-matching query
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.byType(CustomSurahItem), findsNothing);
      expect(find.text('لم يتم العثور على سور مطابقة'), findsOneWidget);
    });

    testWidgets('clears filter and restores full list when search is cleared',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Type a query to filter
      await tester.enterText(find.byType(TextField), 'فاتح');
      await tester.pumpAndSettle();
      expect(find.byType(CustomSurahItem), findsOneWidget);

      // Clear the search field by tapping the clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Should restore all 4 surahs
      expect(find.byType(CustomSurahItem), findsNWidgets(4));
    });

    testWidgets('handles partial Arabic matching with diacritic stripping',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Type "نسا" (Nisa without diacritics)
      await tester.enterText(find.byType(TextField), 'نسا');
      await tester.pumpAndSettle();

      // Should match "النِّسَاء" (diacritics will be stripped for comparison)
      expect(find.byType(CustomSurahItem), findsOneWidget);
      expect(find.text('النِّسَاء'), findsOneWidget);
    });

    testWidgets('maintains search state while scrolling',
        (WidgetTester tester) async {
      // Create a longer list to test scrolling
      final longList = [
        ..._mockSurahs,
        Surah(
          id: 5,
          nameArabic: 'المَائِدَة',
          nameSimple: 'Al-Maidah',
          versesCount: 120,
          mutashabihatAyahCount: 15,
        ),
      ];

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: longList),
          ),
        ),
      );

      // Type a query
      await tester.enterText(find.byType(TextField), 'ما');
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.byType(CustomSurahItem), findsWidgets);

      // Scroll within the list
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Filter should still be active
      final visibleSurahs = find.byType(CustomSurahItem);
      expect(visibleSurahs, findsWidgets);
    });

    testWidgets('clear button appears only when search field has text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SurahsItemListView(surahs: _mockSurahs),
          ),
        ),
      );

      // Initially, clear button should not be visible
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // Clear button should now be visible
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Clear the field
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Clear button should be gone again
      expect(find.byIcon(Icons.clear), findsNothing);
    });
  });
}
