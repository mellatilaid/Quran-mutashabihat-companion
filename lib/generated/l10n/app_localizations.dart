import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفيق المتشابهات'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق لاستكشاف الآيات المتشابهة في القرآن الكريم'**
  String get appDescription;

  /// No description provided for @indexTabLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس'**
  String get indexTabLabel;

  /// No description provided for @favoritesTabLabel.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTabLabel;

  /// No description provided for @myAyahsTabLabel.
  ///
  /// In ar, this message translates to:
  /// **'آياتي'**
  String get myAyahsTabLabel;

  /// No description provided for @profileTabLabel.
  ///
  /// In ar, this message translates to:
  /// **'الملف'**
  String get profileTabLabel;

  /// No description provided for @mutashabihatCompanion.
  ///
  /// In ar, this message translates to:
  /// **'رفيق المتشابهات'**
  String get mutashabihatCompanion;

  /// No description provided for @verses.
  ///
  /// In ar, this message translates to:
  /// **'الآيات'**
  String get verses;

  /// No description provided for @mutashabihat.
  ///
  /// In ar, this message translates to:
  /// **'المتشابهات'**
  String get mutashabihat;

  /// No description provided for @surahListTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة السور'**
  String get surahListTitle;

  /// No description provided for @mostConfusable.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر التباساً'**
  String get mostConfusable;

  /// No description provided for @searchPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سورة'**
  String get searchPlaceholder;

  /// No description provided for @ayahMarkerLabel.
  ///
  /// In ar, this message translates to:
  /// **'آية'**
  String get ayahMarkerLabel;

  /// No description provided for @similarPhrasesFound.
  ///
  /// In ar, this message translates to:
  /// **'عبارات متشابهة موجودة هنا'**
  String get similarPhrasesFound;

  /// No description provided for @tapColoredDot.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على النقطة الملونة لعزل تلك العبارة في الآية أعلاه'**
  String get tapColoredDot;

  /// No description provided for @comparePhrase.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة العبارة'**
  String get comparePhrase;

  /// No description provided for @mnemonicSection.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة ذاكرة'**
  String get mnemonicSection;

  /// No description provided for @myNoteSection.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظتي'**
  String get myNoteSection;

  /// No description provided for @addYourMnemonic.
  ///
  /// In ar, this message translates to:
  /// **'أضف ذاكرة خاصة بك'**
  String get addYourMnemonic;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مفضلة حتى الآن'**
  String get noFavoritesYet;

  /// No description provided for @addFavoritesFromIndexTab.
  ///
  /// In ar, this message translates to:
  /// **'أضف آياتك المفضلة من علامة الفهرس'**
  String get addFavoritesFromIndexTab;

  /// No description provided for @myAyahs.
  ///
  /// In ar, this message translates to:
  /// **'آياتي'**
  String get myAyahs;

  /// No description provided for @noAyahsBookmarked.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بحفظ أي آيات حتى الآن'**
  String get noAyahsBookmarked;

  /// No description provided for @addDifficultAyahs.
  ///
  /// In ar, this message translates to:
  /// **'أضف الآيات الصعبة التي تريد دراستها'**
  String get addDifficultAyahs;

  /// No description provided for @addADifficultAyah.
  ///
  /// In ar, this message translates to:
  /// **'أضف آية صعبة'**
  String get addADifficultAyah;

  /// No description provided for @searchForAyah.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن آية (حرفين أو أكثر)'**
  String get searchForAyah;

  /// No description provided for @searchByTextOrReference.
  ///
  /// In ar, this message translates to:
  /// **'ابحث حسب النص أو \"سورة:آية\"'**
  String get searchByTextOrReference;

  /// No description provided for @noAyahsFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على آيات'**
  String get noAyahsFound;

  /// No description provided for @addYourOwnMnemonic.
  ///
  /// In ar, this message translates to:
  /// **'أضف ذاكرتك الخاصة...'**
  String get addYourOwnMnemonic;

  /// No description provided for @whyIsThisHardToRecall.
  ///
  /// In ar, this message translates to:
  /// **'لماذا من الصعب تذكر هذه الآية؟'**
  String get whyIsThisHardToRecall;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @favoriteAyahs.
  ///
  /// In ar, this message translates to:
  /// **'الآيات المفضلة'**
  String get favoriteAyahs;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @arabicTextSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم النص العربي'**
  String get arabicTextSize;

  /// No description provided for @confidenceBySurah.
  ///
  /// In ar, this message translates to:
  /// **'الثقة حسب السورة'**
  String get confidenceBySurah;

  /// No description provided for @yourProgressByAyah.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر تقدمك حسب السورة هنا بعد إكمال جلسات الاختبار'**
  String get yourProgressByAyah;

  /// No description provided for @progress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم'**
  String get progress;

  /// No description provided for @resetTestHistory.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين سجل الاختبار'**
  String get resetTestHistory;

  /// No description provided for @aboutThisApp.
  ///
  /// In ar, this message translates to:
  /// **'حول هذا التطبيق'**
  String get aboutThisApp;

  /// No description provided for @copyToClipboard.
  ///
  /// In ar, this message translates to:
  /// **'نسخ إلى الحافظة'**
  String get copyToClipboard;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// Error display message
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String errorMessage(String error);

  /// No description provided for @sharedPhrases.
  ///
  /// In ar, this message translates to:
  /// **'العبارات المتشابهة'**
  String get sharedPhrases;

  /// No description provided for @phrase.
  ///
  /// In ar, this message translates to:
  /// **'العبارة'**
  String get phrase;

  /// No description provided for @occurrencesCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المرات'**
  String get occurrencesCount;

  /// No description provided for @occurrences.
  ///
  /// In ar, this message translates to:
  /// **'مرات'**
  String get occurrences;

  /// Format for showing surahs and ayahs count
  ///
  /// In ar, this message translates to:
  /// **'في {surahCount} سور، {ayahCount} آيات'**
  String inSurahsAndAyahs(int surahCount, int ayahCount);

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @noOccurrences.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noOccurrences;

  /// No description provided for @exit.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get exit;

  /// No description provided for @exitTest.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من الاختبار؟'**
  String get exitTest;

  /// No description provided for @yourProgressWillBeLost.
  ///
  /// In ar, this message translates to:
  /// **'سيتم فقدان تقدمك'**
  String get yourProgressWillBeLost;

  /// Progress indicator for test
  ///
  /// In ar, this message translates to:
  /// **'السؤال {number} من {total}'**
  String questionOfTotal(int number, int total);

  /// No description provided for @recallTheRest.
  ///
  /// In ar, this message translates to:
  /// **'تذكر البقية'**
  String get recallTheRest;

  /// No description provided for @revealFullAyah.
  ///
  /// In ar, this message translates to:
  /// **'الكشف عن الآية كاملة'**
  String get revealFullAyah;

  /// No description provided for @didYouGetItRight.
  ///
  /// In ar, this message translates to:
  /// **'هل حصلت على الإجابة الصحيحة؟'**
  String get didYouGetItRight;

  /// No description provided for @missedIt.
  ///
  /// In ar, this message translates to:
  /// **'فاتتني'**
  String get missedIt;

  /// No description provided for @gotIt.
  ///
  /// In ar, this message translates to:
  /// **'نجحت'**
  String get gotIt;

  /// No description provided for @testComplete.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل الاختبار'**
  String get testComplete;

  /// Test score result
  ///
  /// In ar, this message translates to:
  /// **'النتيجة: {correct} من {total}'**
  String score(int correct, int total);

  /// Percentage score
  ///
  /// In ar, this message translates to:
  /// **'{percent}%'**
  String scorePercentage(String percent);

  /// No description provided for @greatJob.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! استمر في الممارسة'**
  String get greatJob;

  /// No description provided for @goodEffort.
  ///
  /// In ar, this message translates to:
  /// **'جهد جيد. أعد مراجعة هذه الآيات'**
  String get goodEffort;

  /// No description provided for @keepStudying.
  ///
  /// In ar, this message translates to:
  /// **'استمر في دراسة هذه الآيات الصعبة'**
  String get keepStudying;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @emptyStateMessage.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة محتوى'**
  String get emptyStateMessage;

  /// No description provided for @startTestMode.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ وضع الاختبار'**
  String get startTestMode;

  /// No description provided for @searchQueryHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن السورة بالاسم'**
  String get searchQueryHint;

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على سور مطابقة'**
  String get searchNoResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
