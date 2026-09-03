import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'loader_test_utils.dart';

/// Tests for [I18nYamlLoader], which loads translations from `.yaml` and `.yml`
/// files, and for its integration with [Translations.byFile] and
/// [Translations.byHttp], through the default [I18n.loaders].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Matches a [FormatException] whose message matches [msg].
  Matcher isFormatException(Object msg) =>
      isA<FormatException>().having((e) => e.message, 'message', msg);

  group('I18nYamlLoader.decode', () {
    //
    final loader = I18nYamlLoader();

    test('Decodes a flat map of Strings, with plain and quoted scalars', () {
      var result = loader.decode(r'''
Hello: Hola
Goodbye: 'Adiós'
"How are you?": "¿Cómo estás?"
"You clicked the button %d times:": "Hiciste clic en el botón %d veces:"
Welcome to this demo.: Bienvenido a esta demostración.
Website: https://example.com
"Quoted: colon": "Colon: space needs quotes"
''');

      expect(result, {
        'Hello': 'Hola',
        'Goodbye': 'Adiós',
        'How are you?': '¿Cómo estás?',
        'You clicked the button %d times:':
            'Hiciste clic en el botón %d veces:',
        'Welcome to this demo.': 'Bienvenido a esta demostración.',
        'Website': 'https://example.com',
        'Quoted: colon': 'Colon: space needs quotes',
      });
    });

    test('Ignores comments and blank lines', () {
      var result = loader.decode(r'''
# A comment at the top.

Hello: Hola # A comment after a value.

# Another comment.
Goodbye: Adiós
''');

      expect(result, {'Hello': 'Hola', 'Goodbye': 'Adiós'});
    });

    test(
        'Supports the multiline styles: literal (|) keeps the line breaks, '
        'and folded (>) joins the lines with spaces', () {
      var result = loader.decode(r'''
Literal: |-
  First line.
  Second line.
Folded: >-
  First line,
  same paragraph.
Literal with final newline: |
  Text.
''');

      expect(result, {
        'Literal': 'First line.\nSecond line.',
        'Folded': 'First line, same paragraph.',
        'Literal with final newline': 'Text.\n',
      });
    });

    test('Supports the escapes of double-quoted strings', () {
      var result = loader.decode(r'''
Escapes: "Tab:\t Newline:\n Quote:\" Backslash:\\ Unicode:\u00e9"
''');

      expect(result, {
        'Escapes': 'Tab:\t Newline:\n Quote:" Backslash:\\ Unicode:é',
      });
    });

    test('Supports anchors and aliases', () {
      var result = loader.decode(r'''
Hello: &greeting Hola
Hi: *greeting
''');

      expect(result, {'Hello': 'Hola', 'Hi': 'Hola'});
    });

    test('An empty file, or a file with only comments, has no translations',
        () {
      expect(loader.decode(''), isEmpty);
      expect(loader.decode('   \n\n'), isEmpty);
      expect(loader.decode('# Only a comment.\n'), isEmpty);
    });

    test('Handles a byte order mark (BOM) and Windows line endings', () {
      var result = loader.decode('\uFEFFHello: Hola\r\nGoodbye: Adiós\r\n');

      expect(result, {'Hello': 'Hola', 'Goodbye': 'Adiós'});
    });

    test('Throws if the file is not valid YAML', () {
      expect(() => loader.decode('Hello: "unclosed'), throwsFormatException);
      expect(() => loader.decode('Hello: [Hola'), throwsFormatException);
      expect(() => loader.decode('- Hello\nGoodbye: Adiós'),
          throwsFormatException);
    });

    test('Throws if the file contains more than one document', () {
      expect(() => loader.decode('Hello: Hola\n---\nGoodbye: Adiós\n'),
          throwsFormatException);
    });

    test('Throws if a key is duplicated', () {
      expect(
        () => loader.decode('Hello: Hola\nHello: Olá\n'),
        throwsA(isFormatException(contains('Duplicate mapping key'))),
      );
    });

    test('Throws if the file does not contain a map', () {
      expect(
        () => loader.decode('- Hello\n- Goodbye\n'),
        throwsA(isFormatException(
            'The YAML file must contain a map of translations, but it contains a list.')),
      );

      expect(
        () => loader.decode('Hello'),
        throwsA(isFormatException(contains('but it contains a String.'))),
      );

      expect(
        () => loader.decode('123'),
        throwsA(isFormatException(contains('but it contains a number.'))),
      );
    });

    test('Throws if a key is not a String', () {
      expect(
        () => loader.decode('123: Hola'),
        throwsA(isFormatException(
            startsWith("Key '123' is not a String, but a number."))),
      );

      expect(
        () => loader.decode('true: Hola'),
        throwsA(isFormatException(
            startsWith("Key 'true' is not a String, but a boolean."))),
      );

      expect(
        () => loader.decode('~: Hola'),
        throwsA(isFormatException(
            startsWith("Key 'null' is not a String, but null."))),
      );

      expect(
        () => loader.decode('? [a, b]\n: Hola'),
        throwsA(isFormatException(contains('is not a String, but a list.'))),
      );

      // The error explains how to fix it.
      expect(
        () => loader.decode('123: Hola'),
        throwsA(isFormatException(contains('quote them, like "123"'))),
      );

      // Quoting the key makes it a String.
      expect(loader.decode('"123": Hola'), {'123': 'Hola'});
    });

    test('Throws if a value is not a String', () {
      expect(
        () => loader.decode('Count: 123'),
        throwsA(isFormatException(startsWith(
            "Value '123' for key 'Count' is not a String, but a number."))),
      );

      expect(
        () => loader.decode('Flag: true'),
        throwsA(isFormatException(startsWith(
            "Value 'true' for key 'Flag' is not a String, but a boolean."))),
      );

      expect(
        () => loader.decode('Empty:'),
        throwsA(isFormatException(startsWith(
            "Value 'null' for key 'Empty' is not a String, but null."))),
      );

      expect(
        () => loader.decode('List:\n  - Hola'),
        throwsA(isFormatException(allOf(
          startsWith(
              "Value '[Hola]' for key 'List' is not a String, but a list."),
          contains('Lists are not supported'),
        ))),
      );

      // Quoting the value makes it a String. An empty String is a valid value.
      expect(
        loader.decode('Count: "123"\nFlag: "true"\nEmpty: ""'),
        {'Count': '123', 'Flag': 'true', 'Empty': ''},
      );
    });

    test('A map of versions is returned, with the version names as Strings',
        () {
      var result = loader.decode('''
"You clicked the button %d times:":
  other: "Hiciste clic en el botón %d veces:"
  zero: "No hiciste clic en el botón:"
  one: "Hiciste clic en el botón una vez:"
  12: "Hiciste clic en el botón una docena de veces:"
There is a person:
  other: Hay una persona
  male: Hay un hombre
''');

      expect(result, {
        'You clicked the button %d times:': {
          'other': 'Hiciste clic en el botón %d veces:',
          'zero': 'No hiciste clic en el botón:',
          'one': 'Hiciste clic en el botón una vez:',
          '12': 'Hiciste clic en el botón una docena de veces:',
        },
        'There is a person': {
          'other': 'Hay una persona',
          'male': 'Hay un hombre',
        },
      });
    });

    test('Throws if a version is not a String, or has a name that is not text',
        () {
      expect(
        () => loader.decode('''
Key:
  other: x
  male:
    other: y
'''),
        throwsA(isFormatException(allOf(
          startsWith("Version 'male' of key 'Key' is not a String, but a map."),
          contains('Versions can not be nested'),
        ))),
      );

      expect(
        () => loader.decode('''
Key:
  other: x
  one: 123
'''),
        throwsA(isFormatException(startsWith(
            "Version 'one' of key 'Key' is not a String, but a number."))),
      );

      expect(
        () => loader.decode('''
Key:
  other: x
  one:
    - a
'''),
        throwsA(isFormatException(allOf(
          startsWith("Version 'one' of key 'Key' is not a String, but a list."),
          contains('Lists are not supported'),
        ))),
      );

      expect(
        () => loader.decode('''
Key:
  other: x
  true: y
'''),
        throwsA(isFormatException(startsWith(
            "Key 'Key' has a version named 'true', which is not a String, "
            "but a boolean."))),
      );
    });

    test('The .yaml and .yml loaders differ only in the extension', () {
      expect(I18nYamlLoader().extension, '.yaml');
      expect(I18nYamlLoader.yml().extension, '.yml');
      expect(I18nYamlLoader.yml().decode('Hello: Hola'), {'Hello': 'Hola'});
    });
  });

  group('I18nYamlLoader.fromAssetDir', () {
    //
    const dir = 'assets/translations';

    const files = {
      '$dir/en-US.yaml': 'Hello: Hello\nGoodbye: Goodbye\n',
      '$dir/es-ES.yaml': 'Hello: Hola\nGoodbye: Adiós\n',
      '$dir/more_translations/pt-BR.yaml': 'Hello: Olá\n',
      '$dir/fr-FR.yml': 'Hello: Bonjour\n',
      '$dir/de-DE.json': '{"Hello": "Hallo"}',
      'assets/other/it-IT.yaml': 'Hello: Ciao\n',
    };

    setUp(() => mockAssets(files));
    tearDown(() => rootBundle.clear());

    test(
        'Loads the .yaml files in the directory and its subdirectories, '
        'and no other files', () async {
      var result = await I18nYamlLoader().fromAssetDir(dir);

      expect(result, {
        'Hello': {'en-US': 'Hello', 'es-ES': 'Hola', 'pt-BR': 'Olá'},
        'Goodbye': {'en-US': 'Goodbye', 'es-ES': 'Adiós'},
      });
    });

    test('The .yml loader loads only the .yml files', () async {
      var result = await I18nYamlLoader.yml().fromAssetDir(dir);

      expect(result, {
        'Hello': {'fr-FR': 'Bonjour'},
      });
    });

    test('A map of versions is encoded like the string modifiers', () async {
      mockAssets({
        '$dir/es-ES.yaml': '''
"You clicked the button %d times:":
  other: "Hiciste clic en el botón %d veces:"
  zero: "No hiciste clic en el botón:"
  one: "Hiciste clic en el botón una vez:"
  12: "Hiciste clic en el botón una docena de veces:"
There is a person:
  other: Hay una persona
  male: Hay un hombre
  female: Hay una mujer
''',
      });

      var result = await I18nYamlLoader().fromAssetDir(dir);

      expect(
        result['You clicked the button %d times:']!['es-ES'],
        'Hiciste clic en el botón %d veces:'
            .zero('No hiciste clic en el botón:')
            .one('Hiciste clic en el botón una vez:')
            .times(12, 'Hiciste clic en el botón una docena de veces:'),
      );

      expect(
        result['There is a person']!['es-ES'],
        'Hay una persona'
            .modifier('male', 'Hay un hombre')
            .modifier('female', 'Hay una mujer'),
      );
    });

    test('A map of versions without the other version fails the file',
        () async {
      mockAssets({
        '$dir/es-ES.yaml': '''
Hello:
  one: Hola
''',
      });

      await expectLater(
        I18nYamlLoader().fromAssetDir(dir),
        throwsA(isTranslationsException(
            "Error decoding $dir/es-ES.yaml: FormatException: Key 'Hello' "
            "has versions, but no 'other' version, which is the text used when "
            "no other version applies.")),
      );
    });
  });

  group('I18nYamlLoader.fromAssetDir, with a file that fails to decode', () {
    //
    const dir = 'assets/translations';
    const enUs = '$dir/en-US.yaml';
    const esEs = '$dir/es-ES.yaml';

    /// Records every call to [I18n.failedResourceCallback] as (resource, error).
    late List<(String, Object)> failures;

    setUp(() {
      failures = [];
      I18n.failedResourceCallback =
          (resource, error) => failures.add((resource, error));
      mockAssets({enUs: 'Hello: Hello\n', esEs: 'Hello: 123\n'});
    });

    tearDown(() {
      I18n.failedResourceCallback = I18n.defaultFailedResourceCallback;
      rootBundle.clear();
    });

    test('By default, a file with a non-String value fails the whole load',
        () async {
      await expectLater(
        I18nYamlLoader().fromAssetDir(dir),
        throwsA(isTranslationsException(allOf(
          startsWith('Error decoding $esEs: '),
          contains("Value '123' for key 'Hello' is not a String"),
        ))),
      );

      expect(failures, isEmpty);
    });

    test('With failOnInvalidResource: false, the file is skipped and reported',
        () async {
      var result = await I18nYamlLoader()
          .fromAssetDir(dir, failOnInvalidResource: false);

      expect(result, {
        'Hello': {'en-US': 'Hello'},
      });

      expect(failures.map((f) => f.$1), [esEs]);
      expect(failures.single.$2,
          isTranslationsException(startsWith('Error decoding $esEs: ')));
    });
  });

  group('I18nYamlLoader.fromUrl', () {
    //
    const baseUrl = 'https://example.com/translations';

    test('Loads a .yaml url', () async {
      var result = await withMockHttp(
        {'$baseUrl/es-ES.yaml': 'Hello: Hola\n'},
        () => I18nYamlLoader().fromUrl('$baseUrl/es-ES.yaml'),
      );

      expect(result, {
        'Hello': {'es-ES': 'Hola'},
      });
    });

    test('Each loader ignores the urls with another extension', () async {
      var result = await withMockHttp(
        {'$baseUrl/es-ES.yml': 'Hello: Hola\n'},
        () => I18nYamlLoader().fromUrl('$baseUrl/es-ES.yml'),
      );

      expect(result, isEmpty);

      result = await withMockHttp(
        {'$baseUrl/es-ES.yml': 'Hello: Hola\n'},
        () => I18nYamlLoader.yml().fromUrl('$baseUrl/es-ES.yml'),
      );

      expect(result, {
        'Hello': {'es-ES': 'Hola'},
      });
    });

    test('Throws if the file fails to decode', () async {
      await withMockHttp({'$baseUrl/es-ES.yaml': 'Hello: [Hola'}, () async {
        await expectLater(
          I18nYamlLoader().fromUrl('$baseUrl/es-ES.yaml'),
          throwsA(isTranslationsException(
              startsWith('Error decoding $baseUrl/es-ES.yaml: '))),
        );
      });
    });
  });

  group('Default loaders', () {
    //
    const dir = 'assets/translations';

    setUp(() => I18nTranslationsExtension.initLoadProcess());
    tearDown(() => rootBundle.clear());

    test(
        'I18n.loaders includes the YAML loaders, for both .yaml and .yml files',
        () {
      var extensions = I18n.loaders.map((loader) => loader().extension);

      expect(extensions, containsAll(['.json', '.po', '.yaml', '.yml']));
    });

    test(
        'Translations.byFile loads .yaml and .yml files, '
        'together with .json and .po files', () async {
      mockAssets({
        '$dir/en-US.json': '{"Hello": "Hello"}',
        '$dir/es-ES.yaml': 'Hello: Hola\n',
        '$dir/fr-FR.yml': 'Hello: Bonjour\n',
        '$dir/pt-BR.po': r'''
msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"

msgid "Hello"
msgstr "Olá"
''',
      });

      var t = Translations.byFile('en-US', dir: dir);
      await t.load();

      expect(t.translationByLocale_ByTranslationKey, {
        'Hello': {
          'en-US': 'Hello',
          'es-ES': 'Hola',
          'fr-FR': 'Bonjour',
          'pt-BR': 'Olá',
        },
      });

      expect(localize('Hello', t, languageTag: 'es-ES'), 'Hola');
      expect(localize('Hello', t, languageTag: 'fr-FR'), 'Bonjour');
    });

    test('Translations.byHttp loads .yaml and .yml resources', () async {
      const baseUrl = 'https://example.com/translations';

      await withMockHttp({
        '$baseUrl/en-US.yaml': 'Hello: Hello\n',
        '$baseUrl/es-ES.yml': 'Hello: Hola\n',
      }, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['en-US.yaml', 'es-ES.yml'],
        );

        await t.load();

        expect(t.translationByLocale_ByTranslationKey, {
          'Hello': {'en-US': 'Hello', 'es-ES': 'Hola'},
        });

        expect(localize('Hello', t, languageTag: 'es-ES'), 'Hola');
      });
    });
  });
}
