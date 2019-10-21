import 'package:flutter/material.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

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

    // If the translation key is already in the language we want, use the key itself.
    if (locale == translations.defaultLocaleStr) return key;

    // Else, get the translated string in the language we want.
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
    var defaultTranslation = translations[defaultLocaleStr];
    if (defaultTranslation == null)
      throw TranslationsException("No default translation for '$defaultLocaleStr'.");
    this.translations[defaultTranslation] = translations;
    return this;
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

//  Map<String, String> operator [](String key) => translations[key];

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
        String key = entry2.key;
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

class I18n extends StatelessWidget {
  //
  static Locale _systemLocale;
  static Locale _forcedLocale;

  static Locale _locale;
  static String _localeStr;

  static Locale get locale => _locale;

  static String get localeStr => _localeStr;

  static void _refresh() {
    _locale = _forcedLocale ?? _systemLocale;
    _localeStr = locale.toString().toLowerCase();
  }

  final Widget child;

  I18n({
    @required this.child,
    Locale locale,
  }) {
    _forcedLocale = locale;
    _refresh();
  }

  I18n.define(Locale locale) : this(child: null, locale: locale);

  @override
  Widget build(BuildContext context) {
    _systemLocale = Localizations.localeOf(context, nullOk: true);
    _refresh();
    return child;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
