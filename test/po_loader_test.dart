import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'loader_test_utils.dart';

/// Tests for [I18nPoLoader], which loads translations from `.po` (gettext) files,
/// including the plurals (`msgid_plural`) and the genders (`msgctxt`), and for its
/// integration with [Translations.byFile], through the default [I18n.loaders].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const header = r'''
msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\n"
''';

  final loader = I18nPoLoader();

  /// Creates the translations for `es-ES`, from the entries decoded from the PO
  /// [source]. The default locale is `en-US`.
  Translations translationsFrom(String source) =>
      Translations.byLocale('en-US') +
      {'es-ES': loader.decode(source).cast<String, String>()};

  /// Returns all versions of the [key], from the PO [source], as a map where the
  /// unversioned text has the `null` key, like [localizeAllVersions].
  Map<String?, String> versionsOf(String key, String source) =>
      localizeAllVersions(key, translationsFrom(source), languageTag: 'es-ES');

  group('I18nPoLoader.decode', () {
    //
    test('Decodes the entries, ignoring the header and the untranslated ones',
        () {
      var result = loader.decode(header + r'''

msgid "Hello"
msgstr "Hola"

msgid "Untranslated"
msgstr ""
''');

      expect(result, {'Hello': 'Hola'});
    });

    test('An entry with msgid_plural has the one and many versions', () {
      const source = header + r'''

msgid "You have %d message"
msgid_plural "You have %d messages"
msgstr[0] "Tienes %d mensaje"
msgstr[1] "Tienes %d mensajes"
''';

      // The same as `'Tienes %d mensaje'.one('Tienes %d mensaje')
      // .many('Tienes %d mensajes')` in Dart.
      expect(versionsOf('You have %d message', source), {
        null: 'Tienes %d mensaje',
        '1': 'Tienes %d mensaje',
        'M': 'Tienes %d mensajes',
      });

      var t = translationsFrom(source);

      String plural(int n) =>
          localizePlural(n, 'You have %d message', t, languageTag: 'es-ES');

      expect(plural(1), 'Tienes 1 mensaje');
      expect(plural(3), 'Tienes 3 mensajes');
      expect(plural(0), 'Tienes 0 mensajes');
    });

    test('The male, female and neutral contexts are the gender versions', () {
      const source = header + r'''

msgid "There is a person"
msgstr "Hay una persona"

msgctxt "male"
msgid "There is a person"
msgstr "Hay un hombre"

msgctxt "female"
msgid "There is a person"
msgstr "Hay una mujer"

msgctxt "neutral"
msgid "There is a person"
msgstr "Hay alguien"
''';

      // The same as `'Hay una persona'.male('Hay un hombre')
      // .female('Hay una mujer').neutral('Hay alguien')` in Dart.
      expect(versionsOf('There is a person', source), {
        null: 'Hay una persona',
        'm': 'Hay un hombre',
        'f': 'Hay una mujer',
        'n': 'Hay alguien',
      });

      var t = translationsFrom(source);

      String gender(Gender gender) =>
          localizeGender(gender, 'There is a person', t, languageTag: 'es-ES');

      expect(gender(Gender.male), 'Hay un hombre');
      expect(gender(Gender.female), 'Hay una mujer');
      expect(gender(Gender.neutral), 'Hay alguien');
    });

    test('Without an entry without context, the msgid is the unversioned text',
        () {
      const source = header + r'''

msgctxt "male"
msgid "There is a person"
msgstr "Hay un hombre"
''';

      expect(versionsOf('There is a person', source), {
        null: 'There is a person',
        'm': 'Hay un hombre',
      });

      var t = translationsFrom(source);
      expect(
          localizeGender(Gender.female, 'There is a person', t,
              languageTag: 'es-ES'),
          'There is a person');
    });

    test('A gender entry with msgid_plural combines gender and plural', () {
      const source = header + r'''

msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "Hay una persona"
msgstr[1] "Hay %d personas"

msgctxt "male"
msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "Hay un hombre"
msgstr[1] "Hay %d hombres"

msgctxt "female"
msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "Hay una mujer"
msgstr[1] "Hay %d mujeres"
''';

      // The same as, in Dart:
      //
      // 'Hay una persona'
      //     .one('Hay una persona')
      //     .many('Hay %d personas')
      //     .male('Hay un hombre'.one('Hay un hombre').many('Hay %d hombres'))
      //     .female('Hay una mujer'.one('Hay una mujer').many('Hay %d mujeres'))
      //
      expect(versionsOf('There is a person', source), {
        null: 'Hay una persona',
        '1': 'Hay una persona',
        'M': 'Hay %d personas',
        'm': 'Hay un hombre',
        'm1': 'Hay un hombre',
        'mM': 'Hay %d hombres',
        'f': 'Hay una mujer',
        'f1': 'Hay una mujer',
        'fM': 'Hay %d mujeres',
      });

      var t = translationsFrom(source);

      String plural(int n, [Gender? gender]) => localizePlural(
          n, 'There is a person', t,
          languageTag: 'es-ES', gender: gender);

      expect(plural(1, Gender.male), 'Hay un hombre');
      expect(plural(3, Gender.male), 'Hay 3 hombres');
      expect(plural(0, Gender.female), 'Hay 0 mujeres');
      expect(plural(1, Gender.female), 'Hay una mujer');
      expect(plural(1, Gender.neutral), 'Hay una persona');
      expect(plural(2, Gender.neutral), 'Hay 2 personas');
      expect(plural(2), 'Hay 2 personas');

      expect(
          localizeGender(Gender.female, 'There is a person', t,
              languageTag: 'es-ES'),
          'Hay una mujer');
    });

    test('Entries with other contexts are read as if they had no context', () {
      const source = header + r'''

msgctxt "some context"
msgid "Retry"
msgstr "Reintentar"

msgctxt "another context"
msgid "Cancel"
msgstr "Cancelar"

msgctxt "another context"
msgid "Hello"
msgid_plural "Hellos"
msgstr[0] "Hola"
msgstr[1] "Holas"
''';

      expect(loader.decode(source), {
        'Retry': 'Reintentar',
        'Cancel': 'Cancelar',
        'Hello': 'Hola'.one('Hola').many('Holas'),
      });
    });
  });

  group('Translations.byFile with .po files', () {
    //
    const dir = 'assets/translations';

    setUp(() => I18nTranslationsExtension.initLoadProcess());
    tearDown(() => rootBundle.clear());

    test('Loads the genders, and gender and plural combined, from .po files',
        () async {
      mockAssets({
        '$dir/en-US.po': header + r'''

msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "There is a person"
msgstr[1] "There are %d people"

msgctxt "male"
msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "There is a man"
msgstr[1] "There are %d men"

msgctxt "female"
msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "There is a woman"
msgstr[1] "There are %d women"

msgid "Thank you"
msgstr "Thank you"
''',
        '$dir/pt-BR.po': header + r'''

msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "Há uma pessoa"
msgstr[1] "Há %d pessoas"

msgctxt "male"
msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "Há um homem"
msgstr[1] "Há %d homens"

msgctxt "female"
msgid "There is a person"
msgid_plural "There are %d people"
msgstr[0] "Há uma mulher"
msgstr[1] "Há %d mulheres"

msgid "Thank you"
msgstr "Obrigado"

msgctxt "female"
msgid "Thank you"
msgstr "Obrigada"
''',
      });

      var t = Translations.byFile('en-US', dir: dir);
      await t.load();

      String plural(int n, Gender? gender, String locale) => localizePlural(
          n, 'There is a person', t,
          languageTag: locale, gender: gender);

      expect(plural(1, Gender.male, 'en-US'), 'There is a man');
      expect(plural(3, Gender.male, 'en-US'), 'There are 3 men');
      expect(plural(1, Gender.female, 'en-US'), 'There is a woman');
      expect(plural(0, Gender.female, 'en-US'), 'There are 0 women');
      expect(plural(1, Gender.neutral, 'en-US'), 'There is a person');
      expect(plural(2, null, 'en-US'), 'There are 2 people');

      expect(plural(1, Gender.male, 'pt-BR'), 'Há um homem');
      expect(plural(3, Gender.male, 'pt-BR'), 'Há 3 homens');
      expect(plural(1, Gender.female, 'pt-BR'), 'Há uma mulher');
      expect(plural(5, Gender.female, 'pt-BR'), 'Há 5 mulheres');
      expect(plural(1, Gender.neutral, 'pt-BR'), 'Há uma pessoa');
      expect(plural(2, null, 'pt-BR'), 'Há 2 pessoas');

      String gender(Gender gender, String locale) =>
          localizeGender(gender, 'Thank you', t, languageTag: locale);

      expect(gender(Gender.male, 'pt-BR'), 'Obrigado');
      expect(gender(Gender.female, 'pt-BR'), 'Obrigada');
      expect(gender(Gender.neutral, 'pt-BR'), 'Obrigado');
      expect(gender(Gender.female, 'en-US'), 'Thank you');
    });
  });
}
