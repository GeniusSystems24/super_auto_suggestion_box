// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SuperAutoSuggestionLocalizationAr
    extends SuperAutoSuggestionLocalization {
  SuperAutoSuggestionLocalizationAr([String locale = 'ar']) : super(locale);

  @override
  String get requiredMessage => 'هذا الحقل مطلوب';

  @override
  String get recent => 'الأخيرة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get searching => 'جارٍ البحث…';

  @override
  String searchingQuery(String query) {
    return 'جارٍ البحث عن «$query»…';
  }

  @override
  String get typeToSearch => 'اكتب للبحث';

  @override
  String get noMatches => 'لا توجد نتائج';

  @override
  String noMatchesForQuery(String query) {
    return 'لا توجد نتائج لـ «$query»';
  }

  @override
  String get loadingMore => 'جارٍ تحميل المزيد…';

  @override
  String get loadingMoreFromServer => 'جارٍ تحميل المزيد من الخادم…';

  @override
  String get create => 'إنشاء';

  @override
  String get enter => 'ENTER';

  @override
  String get fix => 'تثبيت';

  @override
  String get unfix => 'إلغاء التثبيت';

  @override
  String get advancedSearch => 'بحث متقدم';

  @override
  String get search => 'بحث…';

  @override
  String get advancedSearchKeyboardHint =>
      '↑ ↓ للتنقل   ⏎ للاختيار   ESC للإغلاق';
}
