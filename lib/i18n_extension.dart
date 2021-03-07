import 'package:sprintf/sprintf.dart';

import 'i18n_widget.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

// /////////////////////////////////////////////////////////////////////////////

/// To localize a translatable string, pass its [key] and the [translations]
/// object.
///
/// The locale may also be passed, but if it's null the locale in
/// [I18n.localeStr] will be used. If [I18n.localeStr] is not yet defined,
/// it will use the default locale of the translation in [I18n.defaultLocale].
///
/// Fallback order:
/// - If the translation to the exact locale is found, this will be returned.
/// - Otherwise, it tries to return a translation for the general language of
///   the locale.
/// - Otherwise, it tries to return a translation for any locale with that
///   language.
/// - Otherwise, it tries to return the key itself (which is the translation
///   for the default locale).
///
/// Example 1:
/// If "pt_br" is asked, and "pt_br" is available, return for "pt_br".
///
/// Example 2:
/// If "pt_br" is asked, "pt_br" is not available, and "pt" is available,
/// return for "pt".
///
/// Example 3:
/// If "pt_mo" is asked, "pt_mo" and "pt" are not available, but "pt_br" is,
/// return for "pt_br".
///
String localize(
  String key,
  ITranslations translations, {
  String? locale,
}) {
  Map<String, String>? translatedStringPerLocale = translations[key];

  if (translatedStringPerLocale == null) {
    if (Translations.recordMissingKeys)
      Translations.missingKeys.add(
          TranslatedString(locale: translations.defaultLocaleStr, text: key));

    Translations.missingKeyCallback(key, translations.defaultLocaleStr);

    return key;
  }
  //
  else {
    locale = _effectiveLocale(locale);

    if (locale == "null")
      throw TranslationsException(
          "Locale is the 4 letter string 'null', which is invalid.");

    // Get the translated string in the language we want.
    String? translatedString = translatedStringPerLocale[locale];

    // Return the translated string in the language we want.
    if (translatedString != null) return translatedString;

    // If there's no translated string in the locale, record it.
    if (Translations.recordMissingTranslations &&
        locale != translations.defaultLocaleStr) {
      Translations.missingTranslations
          .add(TranslatedString(locale: locale, text: key));
      Translations.missingTranslationCallback(key, locale);
    }

    // ---

    var lang = _language(locale);

    // Try finding the translation in the general language. Note: If the locale
    // is already general, it was already searched, so no need to do it again.
    if (!_isGeneral(locale)) {
      translatedString = translatedStringPerLocale[lang];
      if (translatedString != null) return translatedString;
    }

    // Try finding the translation in any local with that language.
    for (MapEntry<String, String> entry in translatedStringPerLocale.entries) {
      if (lang == _language(entry.key)) return entry.value;
    }

    // If nothing is found, return the value or key,
    // that is the translation in the default locale.
    return translatedStringPerLocale[translations.defaultLocaleStr] ?? key;
  }
}

/// This simply records the given key as a missing translation with unknown
/// locale.
String recordKey(String key) {
  if (Translations.recordMissingKeys)
    Translations.missingKeys.add(TranslatedString(locale: "", text: key));

  Translations.missingKeyCallback(key, "");

  return key;
}

/// "pt" is a general locale, because is just a language, while "pt_br" is not.
bool _isGeneral(String locale) => locale.length == 2 && !locale.contains("_");

/// The language must be the first 2 chars, otherwise this won't work.
String _language(String locale) => locale.substring(0, 2);

String localizeFill(String text, List<Object> params) => sprintf(text, params);

/// Returns the translated version for the plural modifier.
/// After getting the version, substring %d will be replaced with the modifier.
///
/// Note: This will try to get the most specific plural modifier. For example,
/// `.two` is more specific than `.many`.
///
/// If no applicable modifier can be found, it will default to the unversioned
/// string. For example, this: `"a".zero("b").four("c:")` will default to `"a"`
/// for 1, 2, 3, or more than 5 elements.
///
String localizePlural(
  int modifier,
  String key,
  ITranslations translations, {
  String? locale,
}) {
  locale = locale?.toLowerCase();

  Map<String?, String> versions =
      localizeAllVersions(key, translations, locale: locale);

  String? text;

  /// For plural(0), returns the version 0, otherwise the version the version
  /// 0-1, otherwise the version many, otherwise the unversioned.
  if (modifier == 0)
    text = versions["0"] ?? versions["F"] ?? versions["M"] ?? versions[null];

  /// For plural(1), returns the version 1, otherwise the version the version
  /// 0-1, otherwise the version the version 1-many, otherwise the unversioned.
  else if (modifier == 1)
    text = versions["1"] ?? versions["F"] ?? versions["R"] ?? versions[null];

  /// For plural(2), returns the version 2, otherwise the version 2-3-4,
  /// otherwise the version many/1-many, otherwise the unversioned.
  else if (modifier == 2)
    text = versions["2"] ??
        versions["C"] ??
        versions["M"] ??
        versions["R"] ??
        versions[null];

  /// For plural(3), returns the version 3, otherwise the version 2-3-4,
  /// otherwise the version many/1-many, otherwise the unversioned.
  else if (modifier == 3)
    text = versions["3"] ??
        versions["C"] ??
        versions["M"] ??
        versions["R"] ??
        versions[null];

  /// For plural(4), returns the version 4, otherwise the version 2-3-4,
  /// otherwise the version many/1-many, otherwise the unversioned.
  else if (modifier == 4)
    text = versions["4"] ??
        versions["C"] ??
        versions["M"] ??
        versions["R"] ??
        versions[null];

  /// For plural(5), returns the version 5, otherwise the version many/1-many,
  /// otherwise the unversioned.
  else if (modifier == 5)
    text = versions["5"] ?? versions["M"] ?? versions["R"] ?? versions[null];

  /// For plural(6), returns the version 6, otherwise the version many/1-many,
  /// otherwise the unversioned.
  else if (modifier == 6)
    text = versions["6"] ?? versions["M"] ?? versions["R"] ?? versions[null];

  /// For plural(10), returns the version 10, otherwise the version many/1-many,
  /// For plural(10), returns the version 10, otherwise the version many/1-many,
  /// otherwise the unversioned.
  else if (modifier == 10)
    text = versions["T"] ?? versions["M"] ?? versions["R"] ?? versions[null];

  /// For plural(<0 or >2), returns the version many/1-many,
  /// otherwise the unversioned.
  else
    text = versions[modifier.toString()] ??
        versions["M"] ??
        versions["R"] ??
        versions[null];

  // ---

  if (text == null)
    throw TranslationsException("No version found "
        "(modifier: $modifier, "
        "key: '$key', "
        "locale: '${_effectiveLocale(locale)}').");

  text = text.replaceAll("%d", modifier.toString());

  return text;
}

/// Return the localized string, according to key and modifier.
///
/// You may pass any type of object to the modifier, but it will to a
/// `toString()` in it and use that. So make sure your object has a suitable
/// string representation.
///
String localizeVersion(
  Object modifier,
  String key,
  ITranslations translations, {
  String? locale,
}) {
  locale = locale?.toLowerCase();

  String total = localize(key, translations, locale: locale);

  if (!total.startsWith(_splitter1))
    throw TranslationsException(
        "This text has no version for modifier '$modifier' "
        "(modifier: $modifier, "
        "key: '$key', "
        "locale: '${_effectiveLocale(locale)}').");

  List<String> parts = total.split(_splitter1);

  for (int i = 2; i < parts.length; i++) {
    var part = parts[i];
    List<String> par = part.split(_splitter2);
    if (par.length != 2 || par[0].isEmpty || par[1].isEmpty)
      throw TranslationsException("Invalid text version for '$part'.");
    String _modifier = par[0];
    String text = par[1];
    if (_modifier == modifier.toString()) return text;
  }

  throw TranslationsException(
      "This text has no version for modifier '$modifier' "
      "(modifier: $modifier, "
      "key: '$key', "
      "locale: '${_effectiveLocale(locale)}').");
}

/// Returns a map of all translated strings, where modifiers are the keys.
/// In special, the unversioned text is indexed with a `null` key.
Map<String?, String> localizeAllVersions(
  String key,
  ITranslations translations, {
  String? locale,
}) {
  locale = locale?.toLowerCase();
  String total = localize(key, translations, locale: locale);

  if (!total.startsWith(_splitter1)) {
    return {null: total};
  }

  List<String> parts = total.split(_splitter1);
  if (parts.isEmpty) return {null: key};

  Map<String?, String> all = {null: parts[1]};

  for (int i = 2; i < parts.length; i++) {
    var part = parts[i];
    List<String> par = part.split(_splitter2);
    String version = par[0];
    String text = (par.length == 2) ? par[1] : "";

    if (version.isEmpty)
      throw TranslationsException("Invalid text version for '$part' "
          "(key: '$key', "
          "locale: '${_effectiveLocale(locale)}').");

    all[version] = text;
  }

  return all;
}

String _effectiveLocale(String? locale) =>
    locale?.toLowerCase() ?? I18n.localeStr;

const _splitter1 = "\uFFFF";
const _splitter2 = "\uFFFE";

// /////////////////////////////////////////////////////////////////////////////

class TranslatedString {
  //
  final String locale;
  final String text;

  TranslatedString({
    required this.locale,
    required this.text,
  });

  /// TranslatedString in the default locale will come first.
  /// Then, comes the other TranslatedStrings with the same language as the
  /// default locale.
  /// Then, comes the other TranslatedStrings, in alphabetic order.
  static int Function(TranslatedString, TranslatedString) comparable(
    String defaultLocaleStr,
  ) =>
      (ts1, ts2) {
        if (ts1.locale == defaultLocaleStr) return -1;
        if (ts2.locale == defaultLocaleStr) return 1;

        var defaultLanguageStr = defaultLocaleStr.substring(0, 2);

        if (ts1.locale.startsWith(defaultLanguageStr) &&
            !ts2.locale.startsWith(defaultLocaleStr)) return -1;

        if (ts2.locale.startsWith(defaultLanguageStr) &&
            !ts1.locale.startsWith(defaultLocaleStr)) return 1;

        return ts1.locale.compareTo(ts2.locale);
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslatedString &&
          runtimeType == other.runtimeType &&
          locale == other.locale &&
          text == other.text;

  @override
  int get hashCode => locale.hashCode ^ text.hashCode;
}

// /////////////////////////////////////////////////////////////////////////////

class TranslationsException {
  String msg;

  TranslationsException(this.msg);

  @override
  String toString() => msg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationsException &&
          runtimeType == other.runtimeType &&
          msg == other.msg;

  @override
  int get hashCode => msg.hashCode;
}

// /////////////////////////////////////////////////////////////////////////////

abstract class ITranslations {
  const ITranslations();

  Map<String, Map<String, String>> get translations;

  String get defaultLocaleStr;

  String get defaultLanguageStr =>
      Translations.trim(defaultLocaleStr).substring(0, 2);

  int get length;

  Map<String, String>? operator [](String key) => translations[key];
}

// /////////////////////////////////////////////////////////////////////////////

class Translations extends ITranslations {
  //
  /// All missing keys and translations will be put here.
  /// This may be used in tests to make sure no translations are missing.
  static Set<TranslatedString> missingKeys = {};
  static Set<TranslatedString> missingTranslations = {};

  static bool recordMissingKeys = true;
  static bool recordMissingTranslations = true;

  /// Replace this to log missing keys.
  static void Function(String, String) missingKeyCallback = (key, locale) =>
      print("➜ Translation key in '$locale' is missing: \"$key\".");

  /// Replace this to log missing translations.
  static void Function(String, String) missingTranslationCallback =
      (key, locale) =>
          print("➜ There are no translations in '$locale' for \"$key\".");

  @override
  final Map<String, Map<String, String>> translations;

  @override
  final String defaultLocaleStr;

  /// The default [Translations] constructor builds an empty translations
  /// object, that can be filled with translations with the [+] operator.
  /// For example:
  ///
  /// ```
  /// static final t = Translations("en_us") +
  ///       const {
  ///         "en_us": "i18n Demo",
  ///         "pt_br": "Demonstração i18n",
  ///       };
  /// ```
  ///
  /// Se also: [Translations.from], which responds better to hot reload.
  ///
  Translations(String defaultLocaleStr)
      : assert(trim(defaultLocaleStr).isNotEmpty),
        defaultLocaleStr = trim(defaultLocaleStr),
        translations = <String, Map<String, String>>{};

  /// The [Translations.from] constructor allows you to define the translations
  /// as a const object, all at once. This not only is a little bit more
  /// efficient, but it's also better for "hot reload", since a const variable
  /// will respond to hot reloads, while final variables will not.
  ///
  /// ```
  /// static const t = Translations.from(
  ///    "en_us",
  ///    {
  ///      "i18n Demo": {
  ///        "en_us": "i18n Demo",
  ///        "pt_br": "Demonstração i18n",
  ///      }
  ///    },
  /// );
  /// ```
  ///
  const Translations.from(this.defaultLocaleStr, this.translations);

  static String trim(String locale) {
    locale = locale.trim();

    while (locale.endsWith("_"))
      locale = locale.substring(0, locale.length - 1);

    return locale;
  }

  static TranslationsByLocale byLocale(String defaultLocaleStr) =>
      TranslationsByLocale._(defaultLocaleStr);

  @override
  int get length => translations.length;

  Translations operator +(Map<String, String> translations) {
    //
    var defaultTranslation = translations[defaultLocaleStr];

    if (defaultTranslation == null)
      throw TranslationsException(
          "No default translation for '$defaultLocaleStr'.");

    String key = _getKey(defaultTranslation);

    this.translations[key] = translations;
    return this;
  }

  /// If the translation does NOT start with _splitter2, the translation is the
  /// key. Otherwise, if the translation is something like "·MyKey·0→abc·1→def"
  /// the key is "MyKey".
  static String _getKey(String translation) {
    if (translation.startsWith(_splitter1)) {
      List<String> parts = translation.split(_splitter1);
      return parts[1];
    } else
      return translation;
  }

  /// Combine this translation with another translation.
  Translations operator *(ITranslations translationsByLocale) {
    //
    if (translationsByLocale.defaultLocaleStr != defaultLocaleStr)
      throw TranslationsException(
          "Can't combine translations with different default locales: "
          "'$defaultLocaleStr' and "
          "'${translationsByLocale.defaultLocaleStr}'.");

    for (MapEntry<String, Map<String, String>> entry
        in translationsByLocale.translations.entries) {
      var key = entry.key;
      for (MapEntry<String, String> entry2 in entry.value.entries) {
        String locale = entry2.key;
        String translatedString = entry2.value;
        addTranslation(
            locale: locale, key: key, translatedString: translatedString);
      }
    }
    return this;
  }

  @override
  String toString() {
    String text = "\nTranslations: ---------------\n";
    for (MapEntry<String, Map<String, String>> entry in translations.entries) {
      Map<String, String> translation = entry.value;
      for (var translatedString in _translatedStrings(translation)) {
        text += "  ${translatedString.locale.padRight(5)}"
            " | "
            "${_prettify(translatedString.text)}\n";
      }
      text += "-----------------------------\n";
    }
    return text;
  }

  /// This prettifies versioned strings (that have modifiers).
  String _prettify(String translation) {
    if (!translation.startsWith(_splitter1)) return translation;

    List<String> parts = translation.split(_splitter1);

    String result = parts[1];

    for (int i = 2; i < parts.length; i++) {
      var part = parts[i];
      List<String> par = part.split(_splitter2);
      if (par.length != 2 || par[0].isEmpty || par[1].isEmpty)
        return translation;
      String modifier = par[0];
      String text = par[1];
      result += "\n          $modifier → $text";
    }
    return result;
  }

  List<TranslatedString> _translatedStrings(Map<String, String> translation) =>
      translation.entries
          .map(
              (entry) => TranslatedString(locale: entry.key, text: entry.value))
          .toList()
            ..sort(TranslatedString.comparable(defaultLocaleStr));

  /// Add a [key]/[translatedString] pair to the translations.
  /// You must provide non-empty [locale] and [key], but the [translatedString]
  /// may be empty (for the case when some text shouldn't be displayed in some
  /// language).
  ///
  /// If [locale] or [key] are empty, an error is thrown.
  /// However, if both the [key] and [translatedString] are empty,
  /// the method will ignore it and won't throw any errors.
  ///
  void addTranslation({
    required String locale,
    required String key,
    required String translatedString,
  }) {
    if (locale.isEmpty) throw TranslationsException("Missing locale.");
    if (key.isEmpty) {
      if (translatedString.isEmpty) return;
      throw TranslationsException("Missing key.");
    }

    // ---

    Map<String, String>? _translations = translations[key];
    if (_translations == null) {
      _translations = {};
      translations[key] = _translations;
    }
    _translations[locale] = translatedString;
  }
}

// /////////////////////////////////////////////////////////////////////////////

class TranslationsByLocale extends ITranslations {
  final Translations byKey;

  @override
  Map<String, Map<String, String>> get translations => byKey.translations;

  TranslationsByLocale._(String defaultLocaleStr)
      : byKey = Translations(defaultLocaleStr);

  TranslationsByLocale operator +(
      Map<String, Map<String, String>> translations) {
    for (MapEntry<String, Map<String, String>> entry in translations.entries) {
      String locale = entry.key;
      for (MapEntry<String, String> entry2 in entry.value.entries) {
        String key = Translations._getKey(entry2.key);
        String translatedString = entry2.value;
        byKey.addTranslation(
          locale: locale,
          key: key,
          translatedString: translatedString,
        );
      }
    }
    return this;
  }

  /// Combine this translation with another translation.
  TranslationsByLocale operator *(ITranslations translationsByLocale) {
    if (translationsByLocale.defaultLocaleStr != defaultLocaleStr)
      throw TranslationsException(
          "Can't combine translations with different default locales: "
          "'$defaultLocaleStr' and "
          "'${translationsByLocale.defaultLocaleStr}'.");
    // ---

    for (MapEntry<String, Map<String, String>> entry
        in translationsByLocale.translations.entries) {
      var key = entry.key;
      for (MapEntry<String, String> entry2 in entry.value.entries) {
        String locale = entry2.key;
        String translatedString = entry2.value;
        byKey.addTranslation(
          locale: locale,
          key: key,
          translatedString: translatedString,
        );
      }
    }
    return this;
  }

  // @override
  // String get defaultLanguageStr => byKey.defaultLanguageStr;

  @override
  String get defaultLocaleStr => byKey.defaultLocaleStr;

  @override
  int get length => byKey.length;

  @override
  String toString() => byKey.toString();
}

// /////////////////////////////////////////////////////////////////////////////

extension Localization on String {
  //
  String modifier(Object identifier, String text) {
    return ((!startsWith(_splitter1)) ? _splitter1 : "") +
        "${this}$_splitter1$identifier$_splitter2$text";
  }

  /// Plural modifier for zero elements.
  String zero(String text) => modifier("0", text);

  /// Plural modifier for 1 element.
  String one(String text) => modifier("1", text);

  /// Plural modifier for 2 elements.
  String two(String text) => modifier("2", text);

  /// Plural modifier for 3 elements.
  String three(String text) => modifier("3", text);

  /// Plural modifier for 4 elements.
  String four(String text) => modifier("4", text);

  /// Plural modifier for 5 elements.
  String five(String text) => modifier("5", text);

  /// Plural modifier for 6 elements.
  String six(String text) => modifier("6", text);

  /// Plural modifier for 10 elements.
  String ten(String text) => modifier("T", text);

  /// Plural modifier for any number of elements, except 0, 1 and 2.
  String times(int numberOfTimes, String text) {
    assert(numberOfTimes < 0 || numberOfTimes > 2);
    return modifier(numberOfTimes, text);
  }

  /// Plural modifier for 2, 3 or 4 elements (especially for Czech language).
  String twoThreeFour(String text) => modifier("C", text);

  /// Plural modifier for 1 or more elements.
  /// In other words, it includes any number of elements except zero.
  String oneOrMore(String text) => modifier("R", text);

  /// Plural modifier for 0 or 1 elements.
  String zeroOne(String text) => modifier("F", text);

  /// Plural modifier for any number of elements, except 1.
  /// Note: [many] includes 0 elements, but it's less specific
  /// than [zero] and [zeroOne].
  String many(String text) => modifier("M", text);
}

// /////////////////////////////////////////////////////////////////////////////
