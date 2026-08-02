// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رفيق المتشابهات';

  @override
  String get appDescription =>
      'تطبيق لاستكشاف الآيات المتشابهة في القرآن الكريم';

  @override
  String get indexTabLabel => 'الفهرس';

  @override
  String get favoritesTabLabel => 'المفضلة';

  @override
  String get myAyahsTabLabel => 'آياتي';

  @override
  String get profileTabLabel => 'الملف';

  @override
  String get mutashabihatCompanion => 'رفيق المتشابهات';

  @override
  String get verses => 'الآيات';

  @override
  String get mutashabihat => 'المتشابهات';

  @override
  String get surahListTitle => 'قائمة السور';

  @override
  String get mostConfusable => 'الأكثر التباساً';

  @override
  String get searchPlaceholder => 'ابحث عن سورة';

  @override
  String get ayahMarkerLabel => 'آية';

  @override
  String get similarPhrasesFound => 'عبارات متشابهة موجودة هنا';

  @override
  String get tapColoredDot =>
      'اضغط على النقطة الملونة لعزل تلك العبارة في الآية أعلاه';

  @override
  String get comparePhrase => 'مقارنة العبارة';

  @override
  String get mnemonicSection => 'نصيحة ذاكرة';

  @override
  String get myNoteSection => 'ملاحظتي';

  @override
  String get addYourMnemonic => 'أضف ذاكرة خاصة بك';

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavoritesYet => 'لا توجد مفضلة حتى الآن';

  @override
  String get addFavoritesFromIndexTab => 'أضف آياتك المفضلة من علامة الفهرس';

  @override
  String get myAyahs => 'آياتي';

  @override
  String get noAyahsBookmarked => 'لم تقم بحفظ أي آيات حتى الآن';

  @override
  String get addDifficultAyahs => 'أضف الآيات الصعبة التي تريد دراستها';

  @override
  String get addADifficultAyah => 'أضف آية صعبة';

  @override
  String get searchForAyah => 'ابحث عن آية (حرفين أو أكثر)';

  @override
  String get searchByTextOrReference => 'ابحث حسب النص أو \"سورة:آية\"';

  @override
  String get noAyahsFound => 'لم يتم العثور على آيات';

  @override
  String get addYourOwnMnemonic => 'أضف ذاكرتك الخاصة...';

  @override
  String get whyIsThisHardToRecall => 'لماذا من الصعب تذكر هذه الآية؟';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get favoriteAyahs => 'الآيات المفضلة';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get arabicTextSize => 'حجم النص العربي';

  @override
  String get confidenceBySurah => 'الثقة حسب السورة';

  @override
  String get yourProgressByAyah =>
      'سيظهر تقدمك حسب السورة هنا بعد إكمال جلسات الاختبار';

  @override
  String get progress => 'التقدم';

  @override
  String get resetTestHistory => 'إعادة تعيين سجل الاختبار';

  @override
  String get aboutThisApp => 'حول هذا التطبيق';

  @override
  String get copyToClipboard => 'نسخ إلى الحافظة';

  @override
  String get share => 'مشاركة';

  @override
  String get copied => 'تم النسخ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get loading => 'جاري التحميل';

  @override
  String get error => 'خطأ';

  @override
  String errorMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get sharedPhrases => 'العبارات المتشابهة';

  @override
  String get phrase => 'العبارة';

  @override
  String phraseNumber(int id) {
    return 'العبارة #$id';
  }

  @override
  String get occurrence => 'مرة';

  @override
  String get occurrences => 'مرات';

  @override
  String occurrenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مرات',
      one: 'مرة',
    );
    return '$count $_temp0';
  }

  @override
  String get errorLoadingPhrase => 'خطأ في تحميل العبارة';

  @override
  String get occurrencesCount => 'عدد المرات';

  @override
  String inSurahsAndAyahs(int surahCount, int ayahCount) {
    return 'في $surahCount سور، $ayahCount آيات';
  }

  @override
  String get location => 'الموقع';

  @override
  String get noOccurrences => 'لا توجد نتائج';

  @override
  String get exit => 'خروج';

  @override
  String get exitTest => 'الخروج من الاختبار؟';

  @override
  String get yourProgressWillBeLost => 'سيتم فقدان تقدمك';

  @override
  String questionOfTotal(int number, int total) {
    return 'السؤال $number من $total';
  }

  @override
  String get recallTheRest => 'تذكر البقية';

  @override
  String get revealFullAyah => 'الكشف عن الآية كاملة';

  @override
  String get didYouGetItRight => 'هل حصلت على الإجابة الصحيحة؟';

  @override
  String get missedIt => 'فاتتني';

  @override
  String get gotIt => 'نجحت';

  @override
  String get testComplete => 'اكتمل الاختبار';

  @override
  String score(int correct, int total) {
    return 'النتيجة: $correct من $total';
  }

  @override
  String scorePercentage(String percent) {
    return '$percent%';
  }

  @override
  String get greatJob => 'أحسنت! استمر في الممارسة';

  @override
  String get goodEffort => 'جهد جيد. أعد مراجعة هذه الآيات';

  @override
  String get keepStudying => 'استمر في دراسة هذه الآيات الصعبة';

  @override
  String get done => 'تم';

  @override
  String get emptyStateMessage => 'ابدأ بإضافة محتوى';

  @override
  String get startTestMode => 'ابدأ وضع الاختبار';

  @override
  String get searchQueryHint => 'ابحث عن السورة بالاسم';

  @override
  String get searchNoResults => 'لم يتم العثور على سور مطابقة';

  @override
  String get addToFavorites => 'أضف إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get favoriteAdded => 'تمت إضافة الآية إلى المفضلة';

  @override
  String get favoriteRemoved => 'تم إزالة الآية من المفضلة';

  @override
  String get addNote => 'أضف ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get saveNote => 'حفظ الملاحظة';

  @override
  String get deleteNote => 'حذف الملاحظة';

  @override
  String get addYourNote => 'أضف ملاحظتك هنا...';

  @override
  String noteCharacterCount(int count) {
    return '$count/500';
  }

  @override
  String get deleteNoteConfirm => 'هل تريد حذف هذه الملاحظة؟';

  @override
  String get noteDeletedSuccessfully => 'تم حذف الملاحظة بنجاح';
}
