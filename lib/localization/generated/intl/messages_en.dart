// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(query) => "No matches for “${query}”";

  static String m1(query) => "Searching “${query}”…";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "advancedSearch": MessageLookupByLibrary.simpleMessage("Advanced Search"),
    "advancedSearchKeyboardHint": MessageLookupByLibrary.simpleMessage(
      "↑ ↓ TO NAVIGATE   ⏎ TO SELECT   ESC TO CLOSE",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "enter": MessageLookupByLibrary.simpleMessage("ENTER"),
    "fix": MessageLookupByLibrary.simpleMessage("Fix"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading…"),
    "loadingMore": MessageLookupByLibrary.simpleMessage("Loading more…"),
    "loadingMoreFromServer": MessageLookupByLibrary.simpleMessage(
      "Loading more from server…",
    ),
    "noMatches": MessageLookupByLibrary.simpleMessage("No matches"),
    "noMatchesForQuery": m0,
    "recent": MessageLookupByLibrary.simpleMessage("Recent"),
    "requiredMessage": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search…"),
    "searching": MessageLookupByLibrary.simpleMessage("Searching…"),
    "searchingQuery": m1,
    "typeToSearch": MessageLookupByLibrary.simpleMessage("Type to search"),
    "unfix": MessageLookupByLibrary.simpleMessage("Unfix"),
  };
}
