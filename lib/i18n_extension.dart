import 'package:flutter/material.dart';

// /////////////////////////////////////////////////////////////////////////////////////////////////

String localize(
  String key,
  Translations translations,
) {
  Map<String, String> translatedStringPerLocale = translations[key];

  if (translatedStringPerLocale == null) {
    Translations.missingKeys
        .add(TranslatedString(locale: translations.defaultLocaleStr, text: key));
    Translations.missingKeyCallback(key, translations.defaultLocaleStr);
    return key;
  }
  //
  else {
    // If the translation key is already in the language we want, use the key itself.
    if (I18n.localeStr == translations.defaultLocaleStr) return key;

    // Else, get the translated string in the language we want.
    String translatedString = translatedStringPerLocale[I18n.localeStr];

    // Return the translated string in the language we want.
    if (translatedString != null) return translatedString;

    // If there's no translated string in the language we want, we'll use the default.
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

class Translations {
  //
  /// All missing keys and translations will be put here.
  /// This may be used in tests to make sure no translations are missing.
  static Set<TranslatedString> missingKeys = {};
  static Set<TranslatedString> missingTranslations = {};

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
      : defaultLanguageStr = defaultLocaleStr.substring(0, 2),
        assert(defaultLocaleStr != null && defaultLocaleStr.trim().isNotEmpty),
        translations = Map<String, Map<String, String>>();

  int get length => translations.length;

  Translations operator +(Map<String, String> translations) {
    assert(this.translations != null);
    var defaultTranslation = translations[defaultLocaleStr];
    if (defaultTranslation == null)
      throw TranslationsException("No default translation for '$defaultLocaleStr'.");
    this.translations[defaultTranslation] = translations;
    return this;
  }

  Map<String, String> operator [](String key) => translations[key];

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
