import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'loader_test_utils.dart';

/// Tests for [I18nJsonLoader], in special for the maps of versions (plurals and
/// genders) that a JSON translation may contain, which are encoded by the base
/// [I18nLoader] in the same way the string modifiers (`.zero()`, `.one()`,
/// `.modifier()` etc.) do.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dir = 'assets/translations';
  const enUs = '$dir/en-US.json';
  const esEs = '$dir/es-ES.json';

  /// Loads the given JSON files, with the JSON loader.
  Future<Map<String, Map<String, String>>> load(Map<String, String> files) {
    mockAssets(files);
    return I18nJsonLoader().fromAssetDir(dir);
  }

  tearDown(() => rootBundle.clear());

  group('I18nJsonLoader.decode', () {
    //
    test('Returns the JSON as it is, including the maps of versions', () {
      var result = I18nJsonLoader().decode(r'''
{
  "Hello": "Hola",
  "Bye": {"other": "Adiós", "one": "Adiós a ti"}
}
''');

      expect(result, {
        'Hello': 'Hola',
        'Bye': {'other': 'Adiós', 'one': 'Adiós a ti'},
      });
    });

    test('The extension is .json', () {
      expect(I18nJsonLoader().extension, '.json');
    });
  });

  group('Maps of versions', () {
    //
    test('A map of versions is encoded like the string modifiers', () async {
      var result = await load({
        enUs: r'''
{
  "You clicked the button %d times:": {
    "other": "You clicked the button %d times:",
    "zero": "You haven't clicked the button:",
    "one": "You clicked it once:",
    "two": "You clicked a couple times:",
    "many": "You clicked %d times:",
    "12": "You clicked a dozen times:"
  }
}
''',
      });

      expect(
        result['You clicked the button %d times:']!['en-US'],
        "You clicked the button %d times:"
            .zero("You haven't clicked the button:")
            .one("You clicked it once:")
            .two("You clicked a couple times:")
            .many("You clicked %d times:")
            .times(12, "You clicked a dozen times:"),
      );
    });

    test('All the plural names have their modifiers', () async {
      var result = await load({
        enUs: r'''
{
  "key": {
    "other": "other",
    "zero": "zero",
    "one": "one",
    "two": "two",
    "three": "three",
    "four": "four",
    "five": "five",
    "six": "six",
    "ten": "ten",
    "twoThreeFour": "twoThreeFour",
    "oneOrMore": "oneOrMore",
    "zeroOne": "zeroOne",
    "many": "many",
    "7": "seven",
    "25": "twenty-five"
  }
}
''',
      });

      expect(
        result['key']!['en-US'],
        'other'
            .zero('zero')
            .one('one')
            .two('two')
            .three('three')
            .four('four')
            .five('five')
            .six('six')
            .ten('ten')
            .twoThreeFour('twoThreeFour')
            .oneOrMore('oneOrMore')
            .zeroOne('zeroOne')
            .many('many')
            .times(7, 'seven')
            .times(25, 'twenty-five'),
      );
    });

    test('An integer is the same as .times(), and 10 is the same as .ten()',
        () async {
      var result = await load({
        enUs: r'''
{
  "a": {"other": "x", "10": "ten"},
  "b": {"other": "x", "0": "zero", "1": "one", "2": "two"},
  "c": {"other": "x", "012": "twelve"}
}
''',
      });

      expect(result['a']!['en-US'], 'x'.ten('ten'));
      expect(result['b']!['en-US'], 'x'.zero('zero').one('one').two('two'));
      expect(result['c']!['en-US'], 'x'.times(12, 'twelve'));
    });

    test('Any other name is a version, like .modifier()', () async {
      var result = await load({
        enUs: r'''
{
  "There is a person": {
    "other": "There is a person",
    "male": "There is a man",
    "female": "There is a woman"
  },
  "Gender.enum": {
    "other": "They",
    "Gender.male": "He",
    "Gender.female": "She"
  }
}
''',
      });

      expect(
        result['There is a person']!['en-US'],
        'There is a person'
            .modifier('male', 'There is a man')
            .modifier('female', 'There is a woman'),
      );

      expect(
        result['Gender.enum']!['en-US'],
        'They'.modifier('Gender.male', 'He').modifier('Gender.female', 'She'),
      );
    });

    test('A map with only the other version is plain text', () async {
      var result = await load({
        enUs: '{"Hello": {"other": "Hello"}}',
      });

      expect(result['Hello']!['en-US'], 'Hello');
    });

    test('Plain Strings and maps of versions may be mixed in a file', () async {
      var result = await load({
        enUs:
            '{"Hello": "Hello", "Items": {"other": "%d items", "one": "1 item"}}',
        esEs: '{"Hello": "Hola", "Items": "%d artículos"}',
      });

      expect(result, {
        'Hello': {'en-US': 'Hello', 'es-ES': 'Hola'},
        'Items': {
          'en-US': '%d items'.one('1 item'),
          'es-ES': '%d artículos',
        },
      });
    });

    test('The versions work with the plural and version functions', () async {
      mockAssets({
        enUs: r'''
{
  "You clicked the button %d times:": {
    "other": "You clicked the button %d times:",
    "zero": "You haven't clicked the button:",
    "one": "You clicked it once:",
    "two": "You clicked a couple times:",
    "many": "You clicked %d times:",
    "12": "You clicked a dozen times:"
  },
  "There is a person": {
    "other": "There is a person",
    "male": "There is a man",
    "female": "There is a woman"
  }
}
''',
        esEs: r'''
{
  "You clicked the button %d times:": {
    "other": "Hiciste clic en el botón %d veces:",
    "zero": "No hiciste clic en el botón:",
    "one": "Hiciste clic en el botón una vez:"
  },
  "There is a person": {
    "other": "Hay una persona",
    "male": "Hay un hombre",
    "female": "Hay una mujer"
  }
}
''',
      });

      I18nTranslationsExtension.initLoadProcess();
      var t = Translations.byFile('en-US', dir: dir);
      await t.load();

      const clicked = 'You clicked the button %d times:';

      String plural(int n, String locale) =>
          localizePlural(n, clicked, t, languageTag: locale);

      expect(plural(0, 'en-US'), "You haven't clicked the button:");
      expect(plural(1, 'en-US'), 'You clicked it once:');
      expect(plural(2, 'en-US'), 'You clicked a couple times:');
      expect(plural(5, 'en-US'), 'You clicked 5 times:');
      expect(plural(12, 'en-US'), 'You clicked a dozen times:');

      expect(plural(0, 'es-ES'), 'No hiciste clic en el botón:');
      expect(plural(1, 'es-ES'), 'Hiciste clic en el botón una vez:');
      expect(plural(7, 'es-ES'), 'Hiciste clic en el botón 7 veces:');

      const person = 'There is a person';

      expect(localizeVersion('male', person, t, languageTag: 'en-US'),
          'There is a man');
      expect(localizeVersion('female', person, t, languageTag: 'es-ES'),
          'Hay una mujer');
      expect(localizeAllVersions(person, t, languageTag: 'es-ES'), {
        null: 'Hay una persona',
        'male': 'Hay un hombre',
        'female': 'Hay una mujer',
      });
    });

    test('Also works with fromUrl', () async {
      const url = 'https://example.com/translations/es-ES.json';

      var result = await withMockHttp(
        {url: '{"Items": {"other": "%d artículos", "one": "1 artículo"}}'},
        () => I18nJsonLoader().fromUrl(url),
      );

      expect(result, {
        'Items': {'es-ES': '%d artículos'.one('1 artículo')},
      });
    });
  });

  group('Maps of versions that are invalid', () {
    //
    test('Throws if the other version is missing', () async {
      await expectLater(
        load({esEs: '{"Hello": {"one": "Hola"}}'}),
        throwsA(isTranslationsException(
            "Error decoding $esEs: FormatException: Key 'Hello' has "
            "versions, but no 'other' version, which is the text used when no "
            "other version applies.")),
      );

      // Also when the map is empty.
      await expectLater(
        load({esEs: '{"Hello": {}}'}),
        throwsA(isTranslationsException(contains("no 'other' version"))),
      );
    });

    test('Throws if two versions mean the same', () async {
      await expectLater(
        load({esEs: '{"Hello": {"other": "x", "one": "a", "1": "b"}}'}),
        throwsA(isTranslationsException(
            "Error decoding $esEs: FormatException: Key 'Hello' has both "
            "the 'one' and the '1' versions, which mean the same.")),
      );

      await expectLater(
        load({esEs: '{"Hello": {"other": "x", "ten": "a", "10": "b"}}'}),
        throwsA(isTranslationsException(
            contains("both the 'ten' and the '10' versions"))),
      );
    });

    test('Throws if a version is not a String', () async {
      await expectLater(
        load({esEs: '{"Hello": {"other": "x", "one": 1}}'}),
        throwsA(isTranslationsException(
            "Error decoding $esEs: FormatException: Version 'one' of key "
            "'Hello' is not a String: '1'. Each version must be text.")),
      );

      // Versions can't be nested.
      await expectLater(
        load({esEs: '{"Hello": {"other": "x", "male": {"other": "y"}}}'}),
        throwsA(isTranslationsException(
            contains("Version 'male' of key 'Hello' is not a String"))),
      );

      await expectLater(
        load({esEs: '{"Hello": {"other": null}}'}),
        throwsA(isTranslationsException(
            contains("Version 'other' of key 'Hello' is not a String"))),
      );
    });

    test('A value that is neither a String nor a map still fails', () async {
      await expectLater(
        load({esEs: '{"Hello": ["Hola"]}'}),
        throwsA(isTranslationsException(
            "Error decoding $esEs: FormatException: Value '[Hola]' for key 'Hello' is not a String.")),
      );

      await expectLater(
        load({esEs: '{"Hello": 123}'}),
        throwsA(isTranslationsException(
            "Error decoding $esEs: FormatException: Value '123' for key 'Hello' is not a String.")),
      );
    });

    test('With failOnInvalidResource: false, the file is skipped and reported',
        () async {
      List<(String, Object)> failures = [];
      I18n.failedResourceCallback =
          (resource, error) => failures.add((resource, error));

      try {
        mockAssets({
          enUs: '{"Hello": "Hello"}',
          esEs: '{"Hello": {"one": "Hola"}}',
        });

        var result = await I18nJsonLoader()
            .fromAssetDir(dir, failOnInvalidResource: false);

        expect(result, {
          'Hello': {'en-US': 'Hello'},
        });

        expect(failures.map((f) => f.$1), [esEs]);
        expect(failures.single.$2,
            isTranslationsException(contains("no 'other' version")));
      } finally {
        I18n.failedResourceCallback = I18n.defaultFailedResourceCallback;
      }
    });
  });
}
