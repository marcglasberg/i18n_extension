import 'package:flutter/material.dart';

import 'i18n_widget.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

/// To localize a translatable string, pass its [key] and the [translations] object.
/// The locale may also be passed, but if it's null the locale in [I18n.localeStr] will be used.
String localize(
  String key,
  ITranslations translations, {
  String locale,
}) {
  Map<String, String> translatedStringPerLocale = translations[key];

  if (translatedStringPerLocale == null) {
    if (Translations.recordMissingKeys)
      Translations.missingKeys
          .add(TranslatedString(locale: translations.defaultLocaleStr, text: key));

    Translations.missingKeyCallback(key, translations.defaultLocaleStr);

    return key;
  }
  //
  else {
    locale = locale ?? I18n.localeStr;

    if (locale == null) throw TranslationsException("The locale is not defined.");

    // Get the translated string in the language we want.
    String translatedString = translatedStringPerLocale[locale];

    // Return the translated string in the language we want.
    if (translatedString != null) return translatedString;

    // If there's no translated string in the language we want, we'll use the default.

    if (Translations.recordMissingTranslations)
      Translations.missingTranslations
          .add(TranslatedString(locale: translations.defaultLocaleStr, text: key));

    Translations.missingTranslationCallback(key, translations.defaultLocaleStr);

    return key;
  }
}

/// Returns the translated version for the number.
/// After getting the version, substring %d will be replaced with the value.
String localizeNumber(
  int value,
  String key,
  ITranslations translations, {
  String locale,
}) {
  assert(value != null);

  Map<String, String> versions = localizeAllVersions(key, translations, locale: locale);

  String text;

  /// For number(0), returns the version 0, otherwise the version many, otherwise the unversioned.
  if (value == 0)
    text = versions["0"] ?? versions["M"] ?? versions[null];

  /// For number(1), returns the version 1, otherwise the unversioned.
  else if (value == 1)
    text = versions["1"] ?? versions[null];

  /// For number(2), returns the version 2, otherwise the version many, otherwise the unversioned.
  else if (value == 2)
    text = versions["2"] ?? versions["M"] ?? versions[null];

  /// For number(<0 or >2), returns the version many, otherwise the unversioned.
  else
    text = versions[value.toString()] ?? versions["M"] ?? versions[null];

  // ---

  if (text == null) throw TranslationsException("No version found found.");

  text = text.replaceAll("%d", value.toString());

  return text;
}

String localizeVersion(
  String version,
  String key,
  ITranslations translations, {
  String locale,
}) {
  String total = localize(key, translations, locale: locale);
  if (!total.startsWith("·"))
    throw TranslationsException("This text has no versions for '$version'.");
  List<String> parts = total.split("·");
  for (int i = 2; i < parts.length; i++) {
    var part = parts[i];
    List<String> par = part.split("→");
    if (par.length != 2 || par[0].isEmpty || par[1].isEmpty)
      throw TranslationsException("Invalid text version for '$part'.");
    String _version = par[0];
    String text = par[1];
    if (_version == version) return text;
  }
  throw TranslationsException("NAO ENCONTROU!!!");
}

/// Returns a map of all translated strings, where versions are the keys.
/// In special, the unversioned text is returned indexed with a null key.
Map<String, String> localizeAllVersions(
  String key,
  ITranslations translations, {
  String locale,
}) {
  String total = localize(key, translations, locale: locale);
  if (!total.startsWith("·")) throw TranslationsException("This text has no versions.");

  Map<String, String> all = {null: total};

  List<String> parts = total.split("·");
  for (int i = 2; i < parts.length; i++) {
    var part = parts[i];
    List<String> par = part.split("→");
    if (par.length != 2 || par[0].isEmpty || par[1].isEmpty)
      throw TranslationsException("Invalid text version for '$part'.");
    String version = par[0];
    String text = par[1];
    all[version] = text;
  }

  return all;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class TranslatedString {
  //
  final String locale;
  final String text;

  TranslatedString({
    @required this.locale,
    @required this.text,
  });

  /// TranslatedString in the default locale will come first.
  /// Then, come the other TranslatedStrings with the same language as the default locale.
  /// Then, come the other TranslatedStrings, in alphabetic order.
  static int Function(TranslatedString, TranslatedString) comparable(String defaultLocaleStr) =>
      (ts1, ts2) {
        if (ts1.locale == defaultLocaleStr) return -1;
        if (ts2.locale == defaultLocaleStr) return 1;

        var defaultLanguageStr = defaultLocaleStr.substring(0, 2);

        if (ts1.locale.startsWith(defaultLanguageStr) && !ts2.locale.startsWith(defaultLocaleStr))
          return -1;

        if (ts2.locale.startsWith(defaultLanguageStr) && !ts1.locale.startsWith(defaultLocaleStr))
          return 1;

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

// /////////////////////////////////////////////////////////////////////////////////////////////////

class TranslationsException {
  String msg;

  TranslationsException(this.msg);

  @override
  String toString() => msg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationsException && runtimeType == other.runtimeType && msg == other.msg;

  @override
  int get hashCode => msg.hashCode;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

abstract class ITranslations {
  Map<String, Map<String, String>> get translations;

  String get defaultLocaleStr;

  String get defaultLanguageStr;

  int get length;

  Map<String, String> operator [](String key) => translations[key];
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class Translations extends ITranslations {
  //
  /// All missing keys and translations will be put here.
  /// This may be used in tests to make sure no translations are missing.
  static Set<TranslatedString> missingKeys = {};
  static Set<TranslatedString> missingTranslations = {};

  static bool recordMissingKeys = true;
  static bool recordMissingTranslations = true;

  /// Replace this to log missing keys.
  static void Function(String, String) missingKeyCallback =
      (key, locale) => print("➜ Translation key in '$locale' is missing: \"$key\".");

  /// Replace this to log missing translations.
  static void Function(String, String) missingTranslationCallback =
      (key, locale) => print("➜ There are no translations in '$locale' for \"$key\".");

  Map<String, Map<String, String>> translations;
  final String defaultLocaleStr;
  final String defaultLanguageStr;

  Translations(this.defaultLocaleStr)
      : assert(defaultLocaleStr != null && defaultLocaleStr.trim().isNotEmpty),
        defaultLanguageStr = defaultLocaleStr.substring(0, 2),
        translations = Map<String, Map<String, String>>();

  static TranslationsByLocale byLocale(String defaultLocaleStr) =>
      TranslationsByLocale._(defaultLocaleStr);

  int get length => translations.length;

  Translations operator +(Map<String, String> translations) {
    assert(this.translations != null);
    // ---
    var defaultTranslation = translations[defaultLocaleStr];

    if (defaultTranslation == null)
      throw TranslationsException("No default translation for '$defaultLocaleStr'.");

    String key = _getKey(defaultTranslation);

    this.translations[key] = translations;
    return this;
  }

  /// If the translation does NOT start with "·", the translation is the key.
  /// Otherwise, if the translation is something like "·MyKey·0→abc·1→def" the key is "Mykey".
  static String _getKey(String translation) {
    if (translation.startsWith("·")) {
      List<String> parts = translation.split("·");
      return parts[1];
    } else
      return translation;
  }

  /// Combine this translation with another translation.
  Translations operator *(ITranslations translationsByLocale) {
    if (translationsByLocale.defaultLocaleStr != defaultLocaleStr)
      throw TranslationsException("Can't combine translations with different default locales: "
          "'$defaultLocaleStr' and '${translationsByLocale.defaultLocaleStr}'.");
    // ---

    for (MapEntry<String, Map<String, String>> entry in translationsByLocale.translations.entries) {
      var key = entry.key;
      for (MapEntry<String, String> entry2 in entry.value.entries) {
        String locale = entry2.key;
        String translatedString = entry2.value;
        add(locale: locale, key: key, translatedString: translatedString);
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
        text += "  ${translatedString.locale.padRight(5)} | ${translatedString.text}\n";
      }
      text += "-----------------------------\n";
    }
    return text;
  }

  List<TranslatedString> _translatedStrings(Map<String, String> translation) => translation.entries
      .map((entry) => TranslatedString(locale: entry.key, text: entry.value))
      .toList()
        ..sort(TranslatedString.comparable(defaultLocaleStr));

  void add({
    @required String locale,
    @required String key,
    @required String translatedString,
  }) {
    if (locale == null || locale.isEmpty) throw TranslationsException("Missing locale.");
    if (key == null || key.isEmpty) throw TranslationsException("Missing key.");
    if (translatedString == null || translatedString.isEmpty)
      throw TranslationsException("Missing translatedString.");
    // ---

    Map<String, String> _translations = translations[key];
    if (_translations == null) {
      _translations = {};
      translations[key] = _translations;
    }
    _translations[locale] = translatedString;
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class TranslationsByLocale extends ITranslations {
  final Translations byKey;

  Map<String, Map<String, String>> get translations => byKey.translations;

  TranslationsByLocale._(String defaultLocaleStr) : byKey = Translations(defaultLocaleStr);

  TranslationsByLocale operator +(Map<String, Map<String, String>> translations) {
    for (MapEntry<String, Map<String, String>> entry in translations.entries) {
      String locale = entry.key;
      for (MapEntry<String, String> entry2 in entry.value.entries) {
        String key = Translations._getKey(entry2.key);
        String translatedString = entry2.value;
        byKey.add(locale: locale, key: key, translatedString: translatedString);
      }
    }
    return this;
  }

  /// Combine this translation with another translation.
  TranslationsByLocale operator *(ITranslations translationsByLocale) {
    if (translationsByLocale.defaultLocaleStr != defaultLocaleStr)
      throw TranslationsException("Can't combine translations with different default locales: "
          "'$defaultLocaleStr' and '${translationsByLocale.defaultLocaleStr}'.");
    // ---

    for (MapEntry<String, Map<String, String>> entry in translationsByLocale.translations.entries) {
      var key = entry.key;
      for (MapEntry<String, String> entry2 in entry.value.entries) {
        String locale = entry2.key;
        String translatedString = entry2.value;
        byKey.add(locale: locale, key: key, translatedString: translatedString);
      }
    }
    return this;
  }

  List<TranslatedString> _translatedStrings(Map<String, String> translation) =>
      byKey._translatedStrings(translation);

  @override
  String get defaultLanguageStr => byKey.defaultLanguageStr;

  @override
  String get defaultLocaleStr => byKey.defaultLocaleStr;

  @override
  int get length => byKey.length;

  @override
  String toString() => byKey.toString();
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

extension Localization on String {
  //
  String versioned(String identifier, String text) {
    assert(identifier != null);
    assert(text != null);
    return ((!this.startsWith("·")) ? "·" : "") + "$this·$identifier→$text";
  }

  String zero(String text) => versioned("0", text);

  String one(String text) => versioned("1", text);

  String two(String text) => versioned("2", text);

  String times(int numberOfTimes, String text) {
    assert(numberOfTimes != null && (numberOfTimes < 0 || numberOfTimes > 2));
    return versioned(numberOfTimes.toString(), text);
  }

  String many(String text) => versioned("M", text);
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
