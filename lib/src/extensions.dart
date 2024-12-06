import 'dart:ui';

import 'package:i18n_extension_core/i18n_extension_core.dart';

extension LocaleFromStringExtension on String {
  //

  /// Use [toLocale] to convert a [String] containing a valid BCP47 language tag
  /// to a [Locale] object.
  ///
  /// If the string is not a valid BCP47 language, [toLocale] will try to fix it.
  /// However, it will only fix the most common errors, by removing spaces,
  /// converting underscores to hyphens, and normalizing the case.
  /// If it can't fix it, it will return an invalid [Locale], or maybe `Locale('und')`,
  /// meaning the locale is undefined.
  ///
  /// See also: [StringFromLocaleExtension.format].
  ///
  Locale toLocale() {
    //                                                 ¶
    String? locale = DefaultLocale.normalizeLocale(this);

    if (locale == null) return const Locale('und');

    final parts = locale.split('-').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return const Locale('und');

    // BCP47 language tags are generally in the form:
    // `language[-script][-region][-variants]`, e.g. "en-Latn-US".
    final languageCode = parts.first.toLowerCase();
    String? scriptCode;
    String? countryCode;

    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      // If scriptCode not found yet and part seems like a script code
      // (4 letters, first uppercase, rest lowercase).
      if (scriptCode == null &&
          part.length == 4 &&
          part[0].toUpperCase() == part[0] &&
          part.substring(1).toLowerCase() == part.substring(1)) {
        scriptCode = part;
      }
      // If countryCode not found yet and part is a two-letter uppercase region code.
      else if (countryCode == null && part.length == 2 && part.toUpperCase() == part) {
        countryCode = part;
      }
    }

    // Doesn't happen in practice.
    if (languageCode.isEmpty) return const Locale('und');

    return Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }
}

extension StringFromLocaleExtension on Locale {
  //

  /// Use [format] to return the string representation of the Locale as a valid
  /// BCP47 language tag (compatible with the Unicode Locale Identifier (ULI) syntax).
  /// If the locale is not valid, [format] may return an invalid tag, or may return
  /// an empty "und" (undefined).
  ///
  /// The language code, script code, and country code will be separated by a hyphen,
  /// and any lowercase/uppercase issues will be fixed.
  ///
  /// Using [format] is recommended over [toString] and [toLanguageTag] (natively
  /// provided by the `Locale` class). In detail:
  ///
  /// - [format] returns the string representation of the Locale as a valid BCP47
  /// language tag, fixing any lowercase/uppercase issues and separating components with
  /// a hyphen. Allows specifying a different separator. For example,
  /// `Locale('en', 'us').format()` returns `en-US`, and
  /// `Locale('en', 'US').format(separator: '|')` returns `en|US`.
  ///
  /// - [toString] returns the language, script and country codes separated by an
  /// underscore. For example, `Locale('en', 'us').toString()` returns `en_us`
  /// and `Locale('en', 'US').toString()` returns `en_US`.
  ///
  /// - [toLanguageTag] returns the language code and the country code separated by a
  /// hyphen, but does not fix case. For example, `Locale('en', 'us').toLanguageTag()`
  /// returns `en-us`, and `Locale('en', 'US').toLanguageTag()` returns `en-US`.
  ///
  /// See also: [LocaleFromStringExtension.toLocale].
  ///
  String format({String? separator}) {
    String? languageTag = DefaultLocale.normalizeLocale(toLanguageTag());

    if ((languageTag != null) && (separator != null))
      languageTag = languageTag.replaceAll('-', separator);

    if (languageTag == null || languageTag.isEmpty) return 'und';

    return languageTag;
  }
}
