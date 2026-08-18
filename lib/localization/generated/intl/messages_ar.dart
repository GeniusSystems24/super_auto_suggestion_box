// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(query) => "لا توجد نتائج لـ «${query}»";

  static String m1(query) => "جارٍ البحث عن «${query}»…";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "advancedSearch": MessageLookupByLibrary.simpleMessage("بحث متقدم"),
    "advancedSearchKeyboardHint": MessageLookupByLibrary.simpleMessage(
      "↑ ↓ للتنقل   ⏎ للاختيار   ESC للإغلاق",
    ),
    "create": MessageLookupByLibrary.simpleMessage("إنشاء"),
    "enter": MessageLookupByLibrary.simpleMessage("ENTER"),
    "fix": MessageLookupByLibrary.simpleMessage("تثبيت"),
    "loading": MessageLookupByLibrary.simpleMessage("جارٍ التحميل…"),
    "loadingMore": MessageLookupByLibrary.simpleMessage("جارٍ تحميل المزيد…"),
    "loadingMoreFromServer": MessageLookupByLibrary.simpleMessage(
      "جارٍ تحميل المزيد من الخادم…",
    ),
    "noMatches": MessageLookupByLibrary.simpleMessage("لا توجد نتائج"),
    "noMatchesForQuery": m0,
    "recent": MessageLookupByLibrary.simpleMessage("الأخيرة"),
    "requiredMessage": MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
    "search": MessageLookupByLibrary.simpleMessage("بحث…"),
    "searching": MessageLookupByLibrary.simpleMessage("جارٍ البحث…"),
    "searchingQuery": m1,
    "typeToSearch": MessageLookupByLibrary.simpleMessage("اكتب للبحث"),
    "unfix": MessageLookupByLibrary.simpleMessage("إلغاء التثبيت"),
  };
}
