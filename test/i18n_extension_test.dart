import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';

void main() {
  //
  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Empty translations.", () {
    I18n.define(Locale("en", "US"));

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
    I18n.define(Locale("en", "US"));
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
    I18n.define(Locale("en", "US"));

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
    I18n.define(Locale("en", "US"));

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

  test("Add 2 translations in 2 languages.", () {
    I18n.define(Locale("en", "US"));

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

  test("Translations with versions.", () {
    I18n.define(Locale("en", "US"));

    var t = Translations("en_us") +
        {
          "en_us": "MyString".zero("Zero").one("One").two("Two").many("many"),
          "pt_br": "MinhaString".zero("Zero").one("Um").two("Dois").many("Muitos"),
        };

    expect(t.length, 1);

    expect(t.translations, {
      "MyString": {
        "en_us": "\uFFFFMyString\uFFFF0\uFFFEZero\uFFFF1\uFFFEOne\uFFFF2\uFFFETwo\uFFFFM\uFFFEmany",
        "pt_br":
            "\uFFFFMinhaString\uFFFF0\uFFFEZero\uFFFF1\uFFFEUm\uFFFF2\uFFFEDois\uFFFFM\uFFFEMuitos",
      },
    });

    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | MyString\n'
        '          0 → Zero\n'
        '          1 → One\n'
        '          2 → Two\n'
        '          M → many\n'
        '  pt_br | MinhaString\n'
        '          0 → Zero\n'
        '          1 → Um\n'
        '          2 → Dois\n'
        '          M → Muitos\n'
        '-----------------------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Combine 2 translations.", () {
    I18n.define(Locale("en", "US"));

    var t1 = Translations("en_us") +
        {
          "en_us": "Hi.",
          "pt_br": "Olá.",
        };

    var t2 = Translations("en_us") +
        {
          "en_us": "Goodbye.",
          "pt_br": "Adeus.",
        };

    var t = t1 * t2;

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

  test("Add 2 translations in 3 languages, by locale.", () {
    I18n.define(Locale("en", "US"));

    var t = Translations.byLocale("en_us") +
        {
          "en_us": {
            "Hi.": "Hi.",
            "Goodbye.": "Goodbye.",
          },
          "es_es": {
            "Hi.": "Hola.",
            "Goodbye.": "Adiós.",
          }
        } +
        {
          "pt_br": {
            "Hi.": "Olá.",
            "Goodbye.": "Adeus.",
          }
        };

    expect(t.length, 2);

    expect(t.translations, {
      "Hi.": {
        "en_us": "Hi.",
        "es_es": "Hola.",
        "pt_br": "Olá.",
      },
      "Goodbye.": {
        "en_us": "Goodbye.",
        "es_es": "Adiós.",
        "pt_br": "Adeus.",
      }
    });

    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | Hi.\n'
        '  es_es | Hola.\n'
        '  pt_br | Olá.\n'
        '-----------------------------\n'
        '  en_us | Goodbye.\n'
        '  es_es | Adiós.\n'
        '  pt_br | Adeus.\n'
        '-----------------------------\n');
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Combine 2 translations by locale.", () {
    I18n.define(Locale("en", "US"));

    TranslationsByLocale t1 = Translations.byLocale("en_us") +
        {
          "en_us": {
            "Hi.": "Hi.",
            "Goodbye.": "Goodbye.",
          },
          "es_es": {
            "Hi.": "Hola.",
            "Goodbye.": "Adiós.",
          }
        };

    TranslationsByLocale t2 = Translations.byLocale("en_us") +
        {
          "pt_br": {
            "Hi.": "Olá.",
            "Goodbye.": "Adeus.",
          }
        };

    var t = t1 * t2;

    expect(t.length, 2);

    expect(t.translations, {
      "Hi.": {
        "en_us": "Hi.",
        "es_es": "Hola.",
        "pt_br": "Olá.",
      },
      "Goodbye.": {
        "en_us": "Goodbye.",
        "es_es": "Adiós.",
        "pt_br": "Adeus.",
      }
    });

    expect(
        t.toString(),
        '\nTranslations: ---------------\n'
        '  en_us | Hi.\n'
        '  es_es | Hola.\n'
        '  pt_br | Olá.\n'
        '-----------------------------\n'
        '  en_us | Goodbye.\n'
        '  es_es | Adiós.\n'
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

    I18n.define(Locale("en", "US"));
    expect(localize("Hi.", t), "Hi.");
    expect(localize("Goodbye", t), "Goodbye");

    I18n.define(Locale("pt", "BR"));
    expect(localize("Hi.", t), "Olá.");
    expect(localize("Goodbye.", t), "Adeus.");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Translate using the extension.", () {
    //
    I18n.define(Locale("en", "US"));
    expect("Hi.".i18n, "Hi.");
    expect("Goodbye.".i18n, "Goodbye.");
    expect("XYZ".i18n, "XYZ");

    I18n.define(Locale("pt", "BR"));
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

    I18n.define(Locale("en", "US"));
    expect("Hi.".i18n, "Hi.");

    I18n.define(Locale("pt", "BR"));
    expect("Hi.".i18n, "Olá.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations, isEmpty);

    // ---------------

    // 2) Search for a key which does NOT exist.

    I18n.define(Locale("en", "US"));
    expect("Unknown text".i18n, "Unknown text");

    expect(Translations.missingKeys.length, 1);
    expect(Translations.missingKeys.single.locale, "en_us");
    expect(Translations.missingKeys.single.text, "Unknown text");
    expect(Translations.missingTranslations, isEmpty);

    // ---------------

    // 3) Search for a key which exists, but the translation in the locale does NOT.

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    I18n.define(Locale("xx", "yy"));
    expect("Hi.".i18n, "Hi.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations.single.locale, "xx_yy");
    expect(Translations.missingTranslations.single.text, "Hi.");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Don't record unnecessary missing translations with the Translation.byLocale constructor.",
      () {
    //
    // ---------------

    // 1) You CAN provide the translations "by locale" in the default locale, if you want.

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    var t1 = Translations.byLocale("en_us") +
        {
          "en_us": {"Hi.": "Hi."},
          "es_es": {"Hi.": "Hola."}
        };

    I18n.define(Locale("en", "US"));
    expect(localize("Hi.", t1), "Hi.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations, isEmpty);

    // ---------------

    // 2) But you don't NEED to to provide the translations "by locale" in the default locale.

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    var t2 = Translations.byLocale("en_us") +
        {
          "es_es": {"Hi.": "Hola."}
        };

    I18n.define(Locale("en", "US"));
    expect(localize("Hi.", t2), "Hi.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations, isEmpty);

    // ---------------

    // 3) However, note this doesn't reduce boilerplate when using the regular constructor,
    // since it uses the default locale translation as key.

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    var t3 = Translations("en_us") +
        {
          "en_us": "Hi.",
          "es_es": "Hola.",
        };

    I18n.define(Locale("en", "US"));
    expect(localize("Hi.", t3), "Hi.");

    expect(Translations.missingKeys, isEmpty);
    expect(Translations.missingTranslations, isEmpty);

    expect(() => Translations("en_us") + {"es_es": "Hola."},
        throwsA(TranslationsException("No default translation for 'en_us'.")));

    // ---------------
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("You must provide the translation in the default language.", () {
    //
    expect(() => Translations("en_us") + {"pt_br": "Olá."},
        throwsA(TranslationsException("No default translation for 'en_us'.")));

    expect(() => Translations("en_us") + {"pt_br": "Olá."},
        throwsA(TranslationsException("No default translation for 'en_us'.")));
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Translations with version.", () {
    //
    var text = "MyKey".modifier("x", "abc");
    expect(text, "\uFFFFMyKey\uFFFFx\uFFFEabc");

    text = "MyKey".modifier("x", "abc").modifier("y", "def");
    expect(text, "\uFFFFMyKey\uFFFFx\uFFFEabc\uFFFFy\uFFFEdef");

    text = "MyKey".zero("abc").one("def").two("ghi").many("jkl").times(5, "mno");
    expect(text,
        "\uFFFFMyKey\uFFFF0\uFFFEabc\uFFFF1\uFFFEdef\uFFFF2\uFFFEghi\uFFFFM\uFFFEjkl\uFFFF5\uFFFEmno");

    expect(text.plural(0), "abc");
    expect(text.version("0"), "abc");
    expect(text.allVersions()["0"], "abc");

    expect(text.plural(1), "def");
    expect(text.version("1"), "def");
    expect(text.allVersions()["1"], "def");

    expect(text.plural(2), "ghi");
    expect(text.version("2"), "ghi");
    expect(text.allVersions()["2"], "ghi");

    expect(text.plural(3), "jkl");
    expect(text.version("M"), "jkl");
    expect(text.allVersions()["M"], "jkl");

    expect(text.plural(5), "mno");
    expect(text.version("5"), "mno");
    expect(text.allVersions()["5"], "mno");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Numeric modifiers.", () {
    //
    I18n.define(Locale("en", "US"));
    var text = "There is 1 item.";
    expect(text.plural(0), "There are no items.");
    expect(text.plural(1), "There is 1 item.");
    expect(text.plural(2), "There are a pair of items.");
    expect(text.plural(3), "There are 3 items.");
    expect(text.plural(4), "There are 4 items.");
    expect(text.plural(5), "Yes, you reached 5 items.");

    I18n.define(Locale("pt", "BR"));
    text = "There is 1 item.";
    expect(text.plural(0), "Não há itens.");
    expect(text.plural(1), "Há 1 item.");
    expect(text.plural(2), "Há um par de itens.");
    expect(text.plural(3), "Há 3 itens.");
    expect(text.plural(4), "Há 4 itens.");
    expect(text.plural(5), "Sim, você alcançou 5 items.");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Custom modifiers.", () {
    //
    I18n.define(Locale("en", "US"));
    var text = "There is a person";
    expect(text.gender(Gender.male), "There is a man");
    expect(text.gender(Gender.female), "There is a woman");
    expect(text.gender(Gender.they), "There is a person");

    expect(
        () => text.gender(null),
        throwsA(TranslationsException(
            "This text has no version for modifier 'null' (modifier: null, key: 'There is a person', locale: 'en_us').")));

    // ---

    I18n.define(Locale("pt", "BR"));
    text = "There is a person";
    expect(text.gender(Gender.male), "Há um homem");
    expect(text.gender(Gender.female), "Há uma mulher");
    expect(text.gender(Gender.they), "Há uma pessoa");

    expect(
        () => text.gender(null),
        throwsA(TranslationsException(
            "This text has no version for modifier 'null' (modifier: null, key: 'There is a person', locale: 'pt_br').")));
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Czech variations.", () {
    I18n.define(Locale("en", "US"));

    Translations t = Translations("en_us") +
        {
          "en_us": "1 beer"
              .zero("0 beers")
              .one("1 beer")
              .two("2 beers")
              .three("3 beers")
              .four("4 beers")
              .five("5 beers")
              .six("6 beers")
              .ten("10 beers")
              .times(12, "12 beers")
              .many("many beers"),
          "cz_cz": "1 variation"
              .zero("0 variation")
              .one("1 variation")
              .two("2 variation")
              .three("3 variation")
              .four("4 variation")
              // .twoThreeFour will not be used because we've defined
              // .two .three .four and those take precedence.
              .twoThreeFour("234 variation")
              .five("5 variation")
              .six("6 variation")
              .ten("10 variation")
              .times(12, "times variation")
              .many("many variation"),
        };

    I18n.define(Locale("cz", "cz"));
    var key = "1 beer";
    expect(localizePlural(0, key, t, locale: "cz_cz"), "0 variation");
    expect(localizePlural(1, key, t, locale: "cz_cz"), "1 variation");
    expect(localizePlural(2, key, t, locale: "cz_cz"), "2 variation");
    expect(localizePlural(3, key, t, locale: "cz_cz"), "3 variation");
    expect(localizePlural(4, key, t, locale: "cz_cz"), "4 variation");
    expect(localizePlural(5, key, t, locale: "cz_cz"), "5 variation");
    expect(localizePlural(6, key, t, locale: "cz_cz"), "6 variation");
    expect(localizePlural(7, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(8, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(9, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(10, key, t, locale: "cz_cz"), "10 variation");
    expect(localizePlural(11, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(12, key, t, locale: "cz_cz"), "times variation");
    expect(localizePlural(13, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(14, key, t, locale: "cz_cz"), "many variation");

    expect(
        t.toString(),
        '\n'
        'Translations: ---------------\n'
        '  en_us | 1 beer\n'
        '          0 → 0 beers\n'
        '          1 → 1 beer\n'
        '          2 → 2 beers\n'
        '          3 → 3 beers\n'
        '          4 → 4 beers\n'
        '          5 → 5 beers\n'
        '          6 → 6 beers\n'
        '          T → 10 beers\n'
        '          12 → 12 beers\n'
        '          M → many beers\n'
        '  cz_cz | 1 variation\n'
        '          0 → 0 variation\n'
        '          1 → 1 variation\n'
        '          2 → 2 variation\n'
        '          3 → 3 variation\n'
        '          4 → 4 variation\n'
        '          C → 234 variation\n'
        '          5 → 5 variation\n'
        '          6 → 6 variation\n'
        '          T → 10 variation\n'
        '          12 → times variation\n'
        '          M → many variation\n'
        '-----------------------------\n');

    // Now try again without defining .two .three .four.
    t = Translations("en_us") +
        {
          "en_us": "1 beer"
              .zero("0 beers")
              .one("1 beer")
              .five("5 beers")
              .six("6 beers")
              .ten("10 beers")
              .times(12, "12 beers")
              .many("many beers"),
          "cz_cz": "1 variation"
              .zero("0 variation")
              .one("1 variation")
              // .twoThreeFour will  be used.
              .twoThreeFour("234 variation")
              .five("5 variation")
              .six("6 variation")
              .ten("10 variation")
              .times(12, "times variation")
              .many("many variation"),
        };

    expect(localizePlural(0, key, t, locale: "cz_cz"), "0 variation");
    expect(localizePlural(1, key, t, locale: "cz_cz"), "1 variation");
    expect(localizePlural(2, key, t, locale: "cz_cz"), "234 variation");
    expect(localizePlural(3, key, t, locale: "cz_cz"), "234 variation");
    expect(localizePlural(4, key, t, locale: "cz_cz"), "234 variation");
    expect(localizePlural(5, key, t, locale: "cz_cz"), "5 variation");
    expect(localizePlural(6, key, t, locale: "cz_cz"), "6 variation");
    expect(localizePlural(7, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(8, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(9, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(10, key, t, locale: "cz_cz"), "10 variation");
    expect(localizePlural(11, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(12, key, t, locale: "cz_cz"), "times variation");
    expect(localizePlural(13, key, t, locale: "cz_cz"), "many variation");
    expect(localizePlural(14, key, t, locale: "cz_cz"), "many variation");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}

extension Localization on String {
  //
  static var _t = Translations("en_us") +
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
        "en_us": "There is 1 item."
            .zero("There are no items.")
            .one("There is 1 item.")
            .two("There are a pair of items.")
            .times(5, "Yes, you reached 5 items.")
            .many("There are %d items."),
        "pt_br": "Há 1 item."
            .zero("Não há itens.")
            .one("Há 1 item.")
            .two("Há um par de itens.")
            .times(5, "Sim, você alcançou 5 items.")
            .many("Há %d itens."),
      } +
      {
        "en_us": "There is a person"
            .modifier(Gender.male, "There is a man")
            .modifier(Gender.female, "There is a woman")
            .modifier(Gender.they, "There is a person"),
        "pt_br": "Há uma pessoa"
            .modifier(Gender.male, "Há um homem")
            .modifier(Gender.female, "Há uma mulher")
            .modifier(Gender.they, "Há uma pessoa"),
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);

  Map<String, String> allVersions() => localizeAllVersions(this, _t);

  String gender(Gender gnd) => localizeVersion(gnd, this, _t);
}

enum Gender { they, female, male }
