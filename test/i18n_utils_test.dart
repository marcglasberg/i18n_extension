import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';

void main() {
  //
  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Observe locale changes.", () {
    int count = 0;
    Locale _oldLocale, _newLocale;

    I18n.observeLocale = ({Locale oldLocale, Locale newLocale}) {
      count++;
      _oldLocale = oldLocale;
      _newLocale = newLocale;
    };

    //

    expect(_oldLocale, isNull);
    expect(_newLocale, isNull);
    expect(count, 0);

    I18n.define(Locale("en", "US"));
    expect(_oldLocale.toString(), "null");
    expect(_newLocale.toString(), "en_US");
    expect(count, 1);

    I18n.define(Locale("pt", "BR"));
    expect(_oldLocale.toString(), "en_US");
    expect(_newLocale.toString(), "pt_BR");
    expect(count, 2);

    I18n.define(null);
    expect(_oldLocale.toString(), "pt_BR");
    expect(_newLocale.toString(), "null");
    expect(count, 3);

    I18n.define(null);
    expect(count, 3);

    I18n.define(Locale("pt", "BR"));
    expect(count, 4);

    I18n.define(Locale("pt", "BR"));
    expect(count, 4);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Get the normalize Locale.", () {
    expect(I18n.normalizeLocale(Locale("en", "US")), "en_us");
    expect(I18n.normalizeLocale(Locale("EN_US")), "en_us");
    expect(I18n.normalizeLocale(Locale("en_US")), "en_us");
    expect(I18n.normalizeLocale(Locale("EN_us")), "en_us");
    expect(I18n.normalizeLocale(Locale("En_Us")), "en_us");
    expect(I18n.normalizeLocale(Locale("_EN_US_")), "en_us");
    expect(I18n.normalizeLocale(Locale("EN_US_")), "en_us");
    expect(I18n.normalizeLocale(Locale("_EN_US")), "en_us");
    expect(I18n.normalizeLocale(Locale(" EN_US ")), "en_us");
    expect(I18n.normalizeLocale(Locale(" EN_US")), "en_us");
    expect(I18n.normalizeLocale(Locale("EN_US ")), "en_us");
    expect(I18n.normalizeLocale(Locale("EN_US _ ")), "en_us");
    expect(I18n.normalizeLocale(Locale("_ EN_US _ ")), "en_us");
    expect(I18n.normalizeLocale(Locale("_ eN_uS _ ")), "en_us");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Get the language from the Locale.", () {
    expect(I18n.getLanguageFromLocale(Locale("en", "US")), "en");
    expect(I18n.getLanguageFromLocale(Locale("EN", "US")), "en");
    expect(I18n.getLanguageFromLocale(Locale("en", "US")), "en");
    expect(I18n.getLanguageFromLocale(Locale("EN", "us")), "en");
    expect(I18n.getLanguageFromLocale(Locale("En", "Us")), "en");
    expect(I18n.getLanguageFromLocale(Locale("EN", "US_")), "en");
    expect(I18n.getLanguageFromLocale(Locale(" EN", "US ")), "en");
    expect(I18n.getLanguageFromLocale(Locale(" EN", "US")), "en");
    expect(I18n.getLanguageFromLocale(Locale("EN", "_US ")), "en");
    expect(I18n.getLanguageFromLocale(Locale("EN ", " US _ ")), "en");
    expect(I18n.getLanguageFromLocale(Locale("  EN ", "_US _ ")), "en");
    expect(I18n.getLanguageFromLocale(Locale(" eN ", " uS _ ")), "en");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Don't allow underscores in the language code.", () {
    expect(
        () => I18n.define(Locale("pt_BR")),
        throwsA(TranslationsException(
            "Language code 'pt_BR' is invalid: Contains an underscore character.")));

    expect(
        () => I18n.define(Locale("pt_")),
        throwsA(TranslationsException(
            "Language code 'pt_' is invalid: Contains an underscore character.")));
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}
