import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

void main() {
  //
  test("Observe locale changes.", () {
    int count = 0;
    Locale? _oldLocale, _newLocale;

    I18n.observeLocale = ({required Locale oldLocale, required Locale newLocale}) {
      count++;
      _oldLocale = oldLocale;
      _newLocale = newLocale;
    };

    // ---

    expect(_oldLocale, isNull);
    expect(_newLocale, isNull);
    expect(count, 0);

    /// This won’t call the [observeLocale] function because the
    /// [I18n.defaultLocale] is already Locale('en', 'US').
    I18n.define(const Locale('en', 'US'));
    expect(_oldLocale, isNull);
    expect(_newLocale, isNull);
    expect(count, 0);

    /// Change the locale and call the observer.
    I18n.define(const Locale('pt', 'BR'));
    expect(_oldLocale.toString(), "en_US");
    expect(_newLocale.toString(), "pt_BR");
    expect(count, 1);

    /// Back to [I18n.defaultLocale].
    I18n.define(null);
    expect(_oldLocale.toString(), "pt_BR");
    expect(_newLocale.toString(), "en_US");
    expect(count, 2);

    /// This won’t call the [observeLocale] function because the
    /// [I18n.defaultLocale] is already Locale('en', 'US').
    I18n.define(null);
    expect(count, 2);

    /// Change the locale and call the observer.
    I18n.define(const Locale('pt', 'BR'));
    expect(count, 3);

    /// This won’t call the [observeLocale] function because the
    /// locale is already "pt_BR".
    I18n.define(const Locale('pt', 'BR'));
    expect(count, 3);
  });

  test("Get the normalize Locale.", () {
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale('en', 'US')), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("EN_US")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("en_US")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("EN_us")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("En_Us")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("_EN_US_")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("EN_US_")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("_EN_US")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale(" EN_US ")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale(" EN_US")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("EN_US ")), "en_us");
    expect(I18n.localeStringAsLowercaseAndUnderscore(const Locale("EN_US _ ")), "en_us");
    expect(
        I18n.localeStringAsLowercaseAndUnderscore(const Locale("_ EN_US _ ")), "en_us");
    expect(
        I18n.localeStringAsLowercaseAndUnderscore(const Locale("_ eN_uS _ ")), "en_us");
  });

  test("Get the language from the Locale.", () {
    expect(I18n.getLanguageOnlyFromLocale(const Locale('en', 'US')), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale('en', 'US')), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale('en', 'US')), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale('en', 'US')), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale('en', 'US')), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale("EN", "US_")), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale(" EN", "US ")), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale(" EN", "US")), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale("EN", "_US ")), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale("EN ", " US _ ")), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale("  EN ", "_US _ ")), "en");
    expect(I18n.getLanguageOnlyFromLocale(const Locale(" eN ", " uS _ ")), "en");
  });

  test("I18n.define may sometimes fix a malformed locale", () {
    //
    var validLocale = const Locale('pt', 'BR');
    var invalidLocale1 = const Locale('pt', 'br');
    var invalidLocale2 = const Locale('pt_BR');
    var invalidLocale3 = const Locale('pt_');

    I18n.define(validLocale);
    expect(I18n.locale.languageCode, "pt");
    expect(I18n.locale.scriptCode, isNull);
    expect(I18n.locale.countryCode, "BR");

    I18n.define(invalidLocale1);
    expect(I18n.locale.languageCode, "pt");
    expect(I18n.locale.scriptCode, isNull);
    expect(I18n.locale.countryCode, "BR");

    I18n.define(invalidLocale2);
    expect(I18n.locale.languageCode, "pt");
    expect(I18n.locale.scriptCode, isNull);
    expect(I18n.locale.countryCode, "BR");

    I18n.define(invalidLocale3);
    expect(I18n.locale.languageCode, "pt");
    expect(I18n.locale.scriptCode, isNull);
    expect(I18n.locale.countryCode, isNull);
  });

  test(
      "Is Locale normalized? No it's not. "
      "That's why I normalize it as lowercase.", () {
    expect(const Locale('pt', 'BR').toString(), "pt_BR");
    expect(const Locale('pt', 'BR').format(), "pt-BR");
    expect(const Locale('pt', 'BR'), const Locale('pt', 'BR'));
    expect(const Locale('pt', 'BR'), isNot(const Locale('PT', 'BR')));
    expect(const Locale('pt', 'BR'), isNot(const Locale('pt', 'br')));
  });
}
