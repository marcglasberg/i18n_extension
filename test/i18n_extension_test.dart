import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

void main() {
  //

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Empty translations.", () {
    I18n.define(Locale("en_us"));

    var t = Translations("en_us");
    expect(t.length, 0);
    expect(t.translations, {});
    expect(
        t.toString(),
        '\n'
        'Translations: ---------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Add translation in English only.", () {
    I18n.define(Locale("en_us"));
    var t = Translations("en_us") + {"en_us": "Hi."};
    expect(t.length, 1);
    expect(t.translations, {
      'Hi.': {'en_us': 'Hi.'}
    });
    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | Hi.\n'
        '-----------------------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Add translation in many languages.", () {
    I18n.define(Locale("en_us"));

    var t = Translations("en_us") +
        {
          "cs_cz": "Ahoj.",
          "en_us": "Hi.",
          "en_uk": "Hi.",
          "pt_br": "Olá.",
          "es": "Hola.",
        };

    expect(t.length, 1);

    expect(t.translations, {
      "Hi.": {
        "en_us": "Hi.",
        "en_uk": "Hi.",
        "cs_cz": "Ahoj.",
        "pt_br": "Olá.",
        "es": "Hola.",
      }
    });

    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | Hi.\n'
        '  en_uk | Hi.\n'
        '  cs_cz | Ahoj.\n'
        '  es    | Hola.\n'
        '  pt_br | Olá.\n'
        '-----------------------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Add 2 translations in a single language.", () {
    I18n.define(Locale("en_us"));

    var t = Translations("en_us") +
        {
          "en_us": "Hi.",
        } +
        {
          "en_us": "Goodbye.",
        };

    expect(t.length, 2);

    expect(t.translations, {
      "Hi.": {
        "en_us": "Hi.",
      },
      "Goodbye.": {
        "en_us": "Goodbye.",
      }
    });

    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | Hi.\n'
        '-----------------------------\n'
        '  en_us | Goodbye.\n'
        '-----------------------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Add 2 translations in many languages.", () {
    I18n.define(Locale("en_us"));

    var t = Translations("en_us") +
        {
          "en_us": "Hi.",
          "pt_br": "Olá.",
        } +
        {
          "en_us": "Goodbye.",
          "pt_br": "Adeus.",
        };

    expect(t.length, 2);

    expect(t.translations, {
      "Hi.": {
        "en_us": "Hi.",
        "pt_br": "Olá.",
      },
      "Goodbye.": {
        "en_us": "Goodbye.",
        "pt_br": "Adeus.",
      }
    });

    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | Hi.\n'
        '  pt_br | Olá.\n'
        '-----------------------------\n'
        '  en_us | Goodbye.\n'
        '  pt_br | Adeus.\n'
        '-----------------------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Translate manually.", () {
    //
    var t = Translations("en_us") +
        {
          "en_us": "Hi.",
          "pt_br": "Olá.",
        } +
        {
          "en_us": "Goodbye.",
          "pt_br": "Adeus.",
        };

    I18n.define(Locale("en_us"));
    expect(localize("Hi.", t), "Hi.");
    expect(localize("Goodbye", t), "Goodbye");

    I18n.define(Locale("pt_br"));
    expect(localize("Hi.", t), "Olá.");
    expect(localize("Goodbye.", t), "Adeus.");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Translate using the extension.", () {
    //
    I18n.define(Locale("en_us"));
    expect("Hi.".i18n, "Hi.");
    expect("Goodbye.".i18n, "Goodbye.");
    expect("XYZ".i18n, "XYZ");

    I18n.define(Locale("pt_br"));
    expect("Hi.".i18n, "Olá.");
    expect("Goodbye.".i18n, "Adeus.");
    expect("XYZ".i18n, "XYZ");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Record missing keys and missing translations.", () {
    //
    // ---------------

    // 1) Search for a key which exists, and the translation also exists.

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();
    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations, isEmpty);

    I18n.define(Locale("en_us"));
    expect("Hi.".i18n, "Hi.");

    I18n.define(Locale("pt_br"));
    expect("Hi.".i18n, "Olá.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations, isEmpty);

    // ---------------

    // 2) Search for a key which does NOT exist.

    I18n.define(Locale("en_us"));
    expect("Unknown text".i18n, "Unknown text");

    expect(Translations.missingKeys.length, 1);
    expect(Translations.missingKeys[0].locale, "en_us");
    expect(Translations.missingKeys[0].text, "Unknown text");
    expect(Translations.missingTranslations, isEmpty);

    // ---------------

    // 3) Search for a key which exists, but the translation in the locale does NOT.

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    I18n.define(Locale("xx_yy"));
    expect("Hi.".i18n, "Hi.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations[0].locale, "en_us");
    expect(Translations.missingTranslations[0].text, "Hi.");

    // ---------------
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("You must provide the translation in the default language.", () {
    //
    expect(() => Translations("en_us") + {"pt_br": "Olá."},
        throwsA(TranslationsException("No default translation for 'en_us'.")));
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}

extension Localization on String {
  //
  static var t = Translations("en_us") +
      {
        "en_us": "Hi.",
        "cs_cz": "Zdravím tě",
        "en_uk": "Hi.",
        "pt_br": "Olá.",
        "es": "Hola.",
      } +
      {
        "en_us": "Goodbye.",
        "pt_br": "Adeus.",
        "cs_cz": "Sbohem.",
        "en_uk": "Goodbye.",
        "es": "Adiós.",
      } +
      {
        "en_us": "XYZ",
      };

  String get i18n => localize(this, t);
}
