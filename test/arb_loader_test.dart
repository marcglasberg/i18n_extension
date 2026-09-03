import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'loader_test_utils.dart';

/// Tests for [I18nArbLoader], which loads translations from `.arb` files, and for
/// its integration with [Translations.byFile] and [Translations.byHttp], through
/// the default [I18n.loaders].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Matches a [FormatException] whose message matches [msg].
  Matcher isFormatException(Object msg) =>
      isA<FormatException>().having((e) => e.message, 'message', msg);

  /// Matches the error of the message with the given [key], which also
  /// contains the given [problem].
  Matcher isMessageError(String key, Object problem) => throwsA(
      isFormatException(allOf(contains("Error in message '$key'"), problem)));

  /// The separators used by the string modifiers, like `.one()`, `.many()` and
  /// `.modifier()`, to add versions to a text. The unversioned text comes first,
  /// and then each version, as `modifier` + [s2] + `text`, all separated by [s1].
  final s1 = String.fromCharCode(0xFFFF);
  final s2 = String.fromCharCode(0xFFFE);

  /// Creates the translations for [locale], from the messages decoded from the
  /// ARB [source]. The default locale is `en-US`.
  Translations translationsFrom(
    String source, {
    String locale = 'en-US',
    bool useEscaping = false,
  }) {
    var messages = I18nArbLoader(useEscaping: useEscaping).decode(source);
    return Translations.byLocale('en-US') +
        {locale: messages.cast<String, String>()};
  }

  /// Returns all versions of the message [key], from the ARB [source], as a map
  /// where the unversioned text has the `null` key, like [localizeAllVersions].
  Map<String?, String> versionsOf(String key, String source) =>
      localizeAllVersions(key, translationsFrom(source), languageTag: 'en-US');

  group('I18nArbLoader.decode: the file structure', () {
    //
    final loader = I18nArbLoader();

    test('Decodes the messages, and ignores the attributes and the metadata',
        () {
      var result = loader.decode(r'''
{
  "@@locale": "es",
  "@@context": "HomePage",
  "@@last_modified": "2025-01-01T10:00-03:00",
  "@@author": "Someone",
  "@@comment": "A comment.",
  "@@x-custom": 123,
  "helloWorld": "¡Hola, Mundo!",
  "@helloWorld": {
    "description": "The conventional greeting.",
    "type": "text",
    "context": "HomePage:Header"
  },
  "welcome": "Bienvenido, {name}",
  "@welcome": {
    "placeholders": {
      "name": {"type": "String", "example": "Juan"}
    }
  },
  "@orphan": {"description": "Metadata for a message that does not exist."},
  "empty": ""
}
''');

      expect(result, {
        'helloWorld': '¡Hola, Mundo!',
        'welcome': 'Bienvenido, {name}',
        'empty': '',
      });
    });

    test('Keys may be any text, not only identifiers', () {
      var result = loader.decode(r'''
{
  "Hello, welcome to this demo.": "Hola, bienvenido a esta demostración.",
  "You clicked the button %d times:": "Hiciste clic en el botón %d veces:"
}
''');

      expect(result, {
        'Hello, welcome to this demo.': 'Hola, bienvenido a esta demostración.',
        'You clicked the button %d times:':
            'Hiciste clic en el botón %d veces:',
      });
    });

    test('An empty file, or a file with an empty object, has no translations',
        () {
      expect(loader.decode(''), isEmpty);
      expect(loader.decode('   '), isEmpty);
      expect(loader.decode('{}'), isEmpty);
      expect(loader.decode('{"@@locale": "es"}'), isEmpty);
    });

    test('Handles a byte order mark (BOM) and Windows line endings', () {
      var bom = String.fromCharCode(0xFEFF);
      var crlf = String.fromCharCodes([13, 10]);

      var result =
          loader.decode('$bom{$crlf"Hello": "Hola",$crlf"Bye": "Adiós"$crlf}');

      expect(result, {'Hello': 'Hola', 'Bye': 'Adiós'});
    });

    test('Throws if the file is not valid JSON', () {
      expect(() => loader.decode('{"Hello": "Hola",}'), throwsFormatException);
      expect(() => loader.decode('{"Hello": "Hola"'), throwsFormatException);
      expect(() => loader.decode('Hello: Hola'), throwsFormatException);
    });

    test('Throws if the file does not contain a JSON object', () {
      expect(
        () => loader.decode('["Hello", "Hola"]'),
        throwsA(isFormatException('The ARB file must contain a JSON object of '
            'translations, but it contains a list.')),
      );

      expect(
        () => loader.decode('"Hello"'),
        throwsA(isFormatException(contains('but it contains a String.'))),
      );

      expect(
        () => loader.decode('123'),
        throwsA(isFormatException(contains('but it contains a number.'))),
      );
    });

    test('Throws if a message is not a String', () {
      expect(
        () => loader.decode('{"count": 123}'),
        throwsA(isFormatException(
            "Value '123' for key 'count' is not a String, but a number.")),
      );

      expect(
        () => loader.decode('{"flag": true}'),
        throwsA(isFormatException(
            "Value 'true' for key 'flag' is not a String, but a boolean.")),
      );

      expect(
        () => loader.decode('{"nothing": null}'),
        throwsA(isFormatException(
            "Value 'null' for key 'nothing' is not a String, but null.")),
      );

      expect(
        () => loader.decode('{"nested": {"Hello": "Hola"}}'),
        throwsA(
            isFormatException(contains('is not a String, but a JSON object.'))),
      );

      expect(
        () => loader.decode('{"list": ["Hola"]}'),
        throwsA(isFormatException(contains('is not a String, but a list.'))),
      );
    });

    test('Throws if the metadata of a message is not a JSON object', () {
      expect(
        () => loader.decode('{"hello": "Hola", "@hello": "The greeting."}'),
        throwsA(isFormatException(
            "The metadata '@hello' must be a JSON object, but it's a String.")),
      );

      expect(
        () => loader.decode('{"hello": "Hola", "@hello": null}'),
        throwsA(isFormatException(
            "The metadata '@hello' must be a JSON object, but it's null.")),
      );
    });

    test('Throws if the @@locale is not a String', () {
      expect(
        () => loader.decode('{"@@locale": 123, "hello": "Hola"}'),
        throwsA(isFormatException(
            "The '@@locale' attribute must be a String, but it's a number.")),
      );
    });

    test('The extension is .arb', () {
      expect(I18nArbLoader().extension, '.arb');
      expect(I18nArbLoader(useEscaping: true).extension, '.arb');
    });
  });

  group('I18nArbLoader.decodeFile: the locale of the file', () {
    //
    final loader = I18nArbLoader();

    test('The locale comes from @@locale, normalized as a language tag', () {
      var result = loader.decodeFile(
          'app_es.arb', '{"@@locale": "es-ES", "Hello": "Hola"}');

      expect(result.languageTag, 'es-ES');
      expect(result.translations, {'Hello': 'Hola'});

      expect(
        loader.decodeFile('app.arb', '{"@@locale": "en_US"}').languageTag,
        'en-US',
      );

      expect(
        loader.decodeFile('app.arb', '{"@@locale": "pt-br"}').languageTag,
        'pt-BR',
      );

      expect(
        loader.decodeFile('app.arb', '{"@@locale": "zh_hans_cn"}').languageTag,
        'zh-Hans-CN',
      );
    });

    test('The @@locale wins over the file name', () {
      var result = loader.decodeFile('app_en.arb', '{"@@locale": "es"}');
      expect(result.languageTag, 'es');
    });

    test('An empty @@locale is ignored, and the file name is used', () {
      var result = loader.decodeFile('app_en.arb', '{"@@locale": ""}');
      expect(result.languageTag, 'en');
    });

    test('Without @@locale, the locale comes from the file name', () {
      String? tagOf(String fileName) =>
          loader.decodeFile(fileName, '{"Hello": "Hello"}').languageTag;

      // The whole name is the locale.
      expect(tagOf('en.arb'), 'en');
      expect(tagOf('en-US.arb'), 'en-US');
      expect(tagOf('en_US.arb'), 'en-US');
      expect(tagOf('pt_br.arb'), 'pt-BR');
      expect(tagOf('zh-Hans-CN.arb'), 'zh-Hans-CN');
      expect(tagOf('zh_Hant.arb'), 'zh-Hant');
      expect(tagOf('es-419.arb'), 'es-419');
      expect(tagOf('fil_PH.arb'), 'fil-PH');

      // The Flutter convention: a prefix, and then the locale.
      expect(tagOf('app_en.arb'), 'en');
      expect(tagOf('app_en_US.arb'), 'en-US');
      expect(tagOf('intl_pt_BR.arb'), 'pt-BR');
      expect(tagOf('intl_messages_de.arb'), 'de');
      expect(tagOf('app_zh_Hans_CN.arb'), 'zh-Hans-CN');
      expect(tagOf('app_es_419.arb'), 'es-419');
      expect(tagOf('my_app_en.arb'), 'en');
      expect(tagOf('app-fr.arb'), 'fr');
      expect(tagOf('strings.en.arb'), 'en');

      // A path with directories.
      expect(tagOf('assets/translations/app_en.arb'), 'en');
      expect(tagOf('assets/translations/en-US.arb'), 'en-US');
    });

    test('localeFromFileName returns null when there is no locale in the name',
        () {
      expect(I18nArbLoader.localeFromFileName('strings.arb'), isNull);
      expect(I18nArbLoader.localeFromFileName('translations.arb'), isNull);
      expect(I18nArbLoader.localeFromFileName('app.arb'), isNull);
      expect(I18nArbLoader.localeFromFileName('app_messages.arb'), isNull);
      expect(I18nArbLoader.localeFromFileName('app_xx.arb'), isNull);

      expect(I18nArbLoader.localeFromFileName('app_en.arb'), 'en');
      expect(I18nArbLoader.localeFromFileName('pt_BR.arb'), 'pt-BR');
    });

    test('Throws if the locale cannot be determined and the file has messages',
        () {
      expect(
        () => loader.decodeFile('strings.arb', '{"Hello": "Hello"}'),
        throwsA(isFormatException(allOf(
          startsWith("The locale of the ARB file 'strings.arb' could not be "
              'determined.'),
          contains("Add the '@@locale' attribute"),
        ))),
      );
    });

    test('A file without messages does not need a locale', () {
      var result = loader.decodeFile('strings.arb', '{}');
      expect(result.languageTag, 'und');
      expect(result.translations, isEmpty);
    });
  });

  group('I18nArbLoader.decode: placeholders', () {
    //
    final loader = I18nArbLoader();

    test('Named and numbered placeholders are kept', () {
      var result = loader.decode(r'''
{
  "welcome": "Welcome, {firstName} {lastName}!",
  "numbered": "Hello {0} and {1}",
  "underscore": "{first_name} {name2} {_private}",
  "unicode": "{nombre} {名前}",
  "twice": "{name}, {name}!"
}
''');

      expect(result, {
        'welcome': 'Welcome, {firstName} {lastName}!',
        'numbered': 'Hello {0} and {1}',
        'underscore': '{first_name} {name2} {_private}',
        'unicode': '{nombre} {名前}',
        'twice': '{name}, {name}!',
      });
    });

    test('Whitespace around the placeholder name is removed', () {
      var result = loader.decode('{"welcome": "Welcome, { name }!"}');
      expect(result, {'welcome': 'Welcome, {name}!'});
    });

    test('Placeholders work with the args function', () {
      var t = translationsFrom(r'''
{
  "welcome": "Welcome, {firstName} {lastName}!",
  "numbered": "Hello {0} and {1}"
}
''');

      expect(
        localize('welcome', t, languageTag: 'en-US')
            .args({'firstName': 'John', 'lastName': 'Doe'}),
        'Welcome, John Doe!',
      );

      expect(
        localize('numbered', t, languageTag: 'en-US').args('John', 'Mary'),
        'Hello John and Mary',
      );
    });

    test(
        'Formatted placeholders become simple placeholders, '
        'since the app formats the values', () {
      var result = loader.decode(r'''
{
  "price": "Total: {price, number, currency}",
  "noFormat": "Total: {price, number}",
  "date": "Since {date, date, ::yMd}",
  "time": "At {time, time, jm}",
  "commas": "On {date, date, EEE, MMM d}",
  "quotes": "On {date, date, 'at' HH:mm}",
  "spaces": "{ n , number , ::percent }",
  "others": "{a, spellout} {b, ordinal} {c, duration}"
}
''');

      expect(result, {
        'price': 'Total: {price}',
        'noFormat': 'Total: {price}',
        'date': 'Since {date}',
        'time': 'At {time}',
        'commas': 'On {date}',
        'quotes': 'On {date}',
        'spaces': '{n}',
        'others': '{a} {b} {c}',
      });
    });

    test('The {@text} syntax of the ARB specification is literal text', () {
      var result = loader.decode('{"bold": "Hello {@<b>}World{@</b>}."}');
      expect(result, {'bold': 'Hello <b>World</b>.'});
    });

    test('A # outside a plural is just text', () {
      var result = loader.decode('{"ticket": "Ticket #{id}"}');
      expect(result, {'ticket': 'Ticket #{id}'});
    });

    test('Throws if a placeholder is malformed, naming the message', () {
      expect(
        () => loader.decode('{"empty": "Hello {}"}'),
        isMessageError('empty', contains('Expected an argument name')),
      );

      expect(
        () => loader.decode('{"blank": "Hello { }"}'),
        isMessageError('blank', contains('Expected an argument name')),
      );

      expect(
        () => loader.decode('{"set": "In math, {1, 2, 3} is a set."}'),
        isMessageError('set', contains("Unknown argument type '2'")),
      );

      expect(
        () => loader.decode('{"open": "Hello {name"}'),
        isMessageError('open',
            contains("Expected '}' or ',' after the argument name 'name'")),
      );

      expect(
        () => loader.decode('{"close": "Hello name}"}'),
        isMessageError('close', contains("Unmatched '}'")),
      );

      expect(
        () => loader.decode('{"twoWords": "Hello {first name}"}'),
        isMessageError('twoWords', contains("Expected '}' or ','")),
      );

      expect(
        () => loader.decode('{"symbol": "Hello {first-name}"}'),
        isMessageError('symbol', contains("Expected '}' or ','")),
      );

      expect(
        () => loader.decode('{"unknown": "{x, foo}"}'),
        isMessageError('unknown', contains("Unknown argument type 'foo'")),
      );

      expect(
        () => loader.decode('{"unfinished": "{price, number, currency"}'),
        isMessageError(
            'unfinished', contains("Expected '}' but the message ended")),
      );

      // The error also shows the message text.
      expect(
        () => loader.decode('{"empty": "Hello {}"}'),
        isMessageError('empty', contains('Message: Hello {}')),
      );
    });

    test('Throws for the ICU argument types that cannot be represented', () {
      expect(
        () =>
            loader.decode('{"ord": "{n, selectordinal, one{#st} other{#th}}"}'),
        isMessageError('ord',
            contains("The 'selectordinal' argument type is not supported")),
      );

      expect(
        () => loader.decode('{"choice": "{n, choice, 0#none|1#one}"}'),
        isMessageError(
            'choice', contains("The 'choice' argument type is not supported")),
      );
    });
  });

  group('I18nArbLoader.decode: plurals', () {
    //
    final loader = I18nArbLoader();

    test('A plural becomes a text with plural versions', () {
      const source = r'''
{
  "itemCount": "{count, plural, =0{No items} one{One item} other{# items}}"
}
''';

      // The `other` case is the unversioned text, and `#` becomes `%d`.
      expect(versionsOf('itemCount', source), {
        null: '%d items',
        '1': 'One item',
        '0': 'No items',
      });

      // The versions are encoded like the string modifiers do. The categories
      // come first, in order, and then the exact cases.
      expect(
        loader.decode(source),
        {'itemCount': '$s1%d items${s1}1${s2}One item${s1}0${s2}No items'},
      );
    });

    test('A plural works with the plural function', () {
      var t = translationsFrom(r'''
{
  "itemCount": "{count, plural, =0{No items} one{One item} other{# items}}"
}
''');

      String plural(int n) =>
          localizePlural(n, 'itemCount', t, languageTag: 'en-US');

      expect(plural(0), 'No items');
      expect(plural(1), 'One item');
      expect(plural(2), '2 items');
      expect(plural(5), '5 items');
      expect(plural(100), '100 items');
    });

    test('Both # and the plural variable become the number', () {
      expect(
        versionsOf('a',
            r'''{"a": "{count, plural, one{{count} item} other{{count} items}}"}'''),
        {null: '%d items', '1': '%d item'},
      );

      expect(
        versionsOf('a',
            r'''{"a": "{count, plural, one{# item ({count})} other{# items ({count})}}"}'''),
        {null: '%d items (%d)', '1': '%d item (%d)'},
      );

      // Also when the plural variable is a number.
      expect(
        versionsOf(
            'a', r'''{"a": "{0, plural, one{# item} other{{0} items}}"}'''),
        {null: '%d items', '1': '%d item'},
      );

      // Also when the plural variable appears outside the plural.
      expect(
        versionsOf('a',
            r'''{"a": "{count}: {count, plural, one{item} other{items}}"}'''),
        {null: '%d: items', '1': '%d: item'},
      );

      // But other placeholders are kept.
      expect(
        versionsOf('a',
            r'''{"a": "{count, plural, one{{name} has # item} other{{name} has # items}}"}'''),
        {null: '{name} has %d items', '1': '{name} has %d item'},
      );
    });

    test('All the plural cases are converted to the corresponding versions',
        () {
      expect(
        versionsOf('a', r'''
{"a": "{n, plural, zero{Z} one{O} two{T} few{F} many{M} other{X}}"}
'''),
        {null: 'X', '0': 'Z', '1': 'O', '2': 'T', 'C': 'F', 'M': 'M'},
      );

      expect(
        versionsOf('a', r'''
{"a": "{n, plural, =0{Z} =1{O} =2{T} =3{Th} =10{Ten} =12{Dozen} other{X}}"}
'''),
        {
          null: 'X',
          '0': 'Z',
          '1': 'O',
          '2': 'T',
          '3': 'Th',
          'T': 'Ten', // The version for 10 is 'T', like `.ten()`.
          '12': 'Dozen',
        },
      );
    });

    test('The plural cases are selected by the rules of the plural function',
        () {
      var t = translationsFrom(r'''
{
  "all": "{n, plural, zero{Z} one{O} two{T} few{F} many{M} other{X}}",
  "some": "{n, plural, one{O} other{X}}",
  "exact": "{n, plural, =0{Z} =1{O} =10{Ten} =12{Dozen} other{# X}}"
}
''');

      String plural(String key, int n) =>
          localizePlural(n, key, t, languageTag: 'en-US');

      expect(plural('all', 0), 'Z');
      expect(plural('all', 1), 'O');
      expect(plural('all', 2), 'T');
      expect(plural('all', 3), 'F');
      expect(plural('all', 4), 'F');
      expect(plural('all', 5), 'M');
      expect(plural('all', 10), 'M');
      expect(plural('all', 100), 'M');

      expect(plural('some', 0), 'X');
      expect(plural('some', 1), 'O');
      expect(plural('some', 2), 'X');
      expect(plural('some', 5), 'X');

      expect(plural('exact', 0), 'Z');
      expect(plural('exact', 1), 'O');
      expect(plural('exact', 2), '2 X');
      expect(plural('exact', 10), 'Ten');
      expect(plural('exact', 12), 'Dozen');
      expect(plural('exact', 13), '13 X');
    });

    test('An exact case wins over a category, whatever their order', () {
      expect(
        versionsOf(
            'a', r'''{"a": "{n, plural, =1{exact} one{category} other{X}}"}'''),
        {null: 'X', '1': 'exact'},
      );

      expect(
        versionsOf(
            'a', r'''{"a": "{n, plural, one{category} =1{exact} other{X}}"}'''),
        {null: 'X', '1': 'exact'},
      );

      expect(
        versionsOf('a',
            r'''{"a": "{n, plural, zero{category} =0{exact} other{X}}"}'''),
        {null: 'X', '0': 'exact'},
      );
    });

    test('A plural may be part of a longer message, with other placeholders',
        () {
      var t = translationsFrom(r'''
{
  "cart": "{name} has {count, plural, one{one item} other{# items}} in the cart."
}
''');

      expect(localizeAllVersions('cart', t, languageTag: 'en-US'), {
        null: '{name} has %d items in the cart.',
        '1': '{name} has one item in the cart.',
      });

      expect(
        localizePlural(1, 'cart', t, languageTag: 'en-US')
            .args({'name': 'Ann'}),
        'Ann has one item in the cart.',
      );

      expect(
        localizePlural(3, 'cart', t, languageTag: 'en-US')
            .args({'name': 'Ann'}),
        'Ann has 3 items in the cart.',
      );
    });

    test('Whitespace between the parts is allowed, and kept inside the cases',
        () {
      expect(
        versionsOf('a',
            r'''{"a": "{ count , plural , one { # item } other { # items } }"}'''),
        {null: ' %d items ', '1': ' %d item '},
      );

      expect(
        versionsOf('a', r'''{"a": "{count,plural,=1{one}other{#}}"}'''),
        {null: '%d', '1': 'one'},
      );

      expect(
        versionsOf('a', r'''{"a": "{count, plural, = 1 {one} other {#}}"}'''),
        {null: '%d', '1': 'one'},
      );
    });

    test('A plural with only the other case is plain text', () {
      expect(
        loader.decode(r'''{"a": "{count, plural, other{# items}}"}'''),
        {'a': '%d items'},
      );

      var t = translationsFrom(r'''{"a": "{count, plural, other{# items}}"}''');
      expect(localizePlural(3, 'a', t, languageTag: 'en-US'), '3 items');
      expect(localize('a', t, languageTag: 'en-US'), '%d items');
    });

    test('A case may be empty', () {
      expect(
        versionsOf('a', r'''{"a": "{n, plural, =0{} other{# items}}"}'''),
        {null: '%d items', '0': ''},
      );

      var t =
          translationsFrom(r'''{"a": "{n, plural, =0{} other{# items}}"}''');
      expect(localizePlural(0, 'a', t, languageTag: 'en-US'), '');
    });

    test('Throws if the plural is malformed, naming the message', () {
      expect(
        () => loader.decode('{"a": "{n, plural, one{one}}"}'),
        isMessageError('a', contains("The plural must have an 'other' case")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, foo{x} other{y}}"}'),
        isMessageError(
            'a', contains("The plural case 'foo' must be one of 'zero'")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, one{x} one{y} other{z}}"}'),
        isMessageError('a', contains("The case 'one' is duplicated")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, =x{x} other{z}}"}'),
        isMessageError('a', contains("Expected a number after '='")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, =1.5{x} other{z}}"}'),
        isMessageError('a', contains("Expected '{' but found '.'")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, one other{z}}"}'),
        isMessageError('a', contains("Expected '{' but found 'o'")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, one{x} other{z}"}'),
        isMessageError('a', contains("Expected '}' but the message ended")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural, one{x other{z}}"}'),
        isMessageError('a', contains("Expected '}' but the message ended")),
      );

      expect(
        () => loader.decode('{"a": "{n, plural one{x} other{z}}"}'),
        isMessageError('a', contains("Expected ',' but found 'o'")),
      );
    });

    test('Throws for the plural offset, which cannot be represented', () {
      expect(
        () => loader.decode(
            '{"a": "{n, plural, offset:1 =0{none} one{you and one} other{you and #}}"}'),
        isMessageError('a', contains('The plural offset is not supported')),
      );
    });

    test(
        'Throws if a message has more than one plural or select, '
        'since a translation is selected by a single value', () {
      const problem = 'The message has more than one plural or select';

      expect(
        () => loader.decode(
            '{"a": "{n, plural, one{# file} other{# files}} and {m, plural, one{# folder} other{# folders}}"}'),
        isMessageError('a', contains(problem)),
      );

      // Even when both use the same variable.
      expect(
        () => loader.decode(
            '{"a": "{n, plural, one{# file} other{# files}} {n, plural, one{is} other{are}} here"}'),
        isMessageError('a', contains(problem)),
      );

      expect(
        () => loader.decode(
            '{"a": "{g, select, male{He} other{They}} {n, plural, one{has # item} other{have # items}}"}'),
        isMessageError('a', contains(problem)),
      );
    });

    test('Throws if a plural or select is inside another one', () {
      const problem = 'inside a plural or select';

      expect(
        () => loader.decode(
            '{"a": "{g, select, male{He has {n, plural, one{# item} other{# items}}} other{They have items}}"}'),
        isMessageError('a', contains(problem)),
      );

      expect(
        () => loader.decode(
            '{"a": "{n, plural, one{{g, select, male{his item} other{their item}}} other{# items}}"}'),
        isMessageError('a', contains(problem)),
      );

      expect(
        () => loader.decode(
            '{"a": "{n, plural, =0{none} other{{n, plural, one{one} other{many}}}}"}'),
        isMessageError('a', contains(problem)),
      );
    });
  });

  group('I18nArbLoader.decode: selects', () {
    //
    final loader = I18nArbLoader();

    test('A select becomes a text with a version for each case', () {
      const source = r'''
{
  "pronoun": "{gender, select, male{He} female{She} other{They}}"
}
''';

      expect(versionsOf('pronoun', source), {
        null: 'They',
        'male': 'He',
        'female': 'She',
      });

      expect(
        loader.decode(source),
        {'pronoun': '${s1}They${s1}male${s2}He${s1}female${s2}She'},
      );
    });

    test('A select works with the version function', () {
      var t = translationsFrom(r'''
{
  "pronoun": "{gender, select, male{He} female{She} other{They}}"
}
''');

      String version(Object modifier) =>
          localizeVersion(modifier, 'pronoun', t, languageTag: 'en-US');

      expect(version('male'), 'He');
      expect(version('female'), 'She');

      // The `other` case is the unversioned text.
      expect(localizeAllVersions('pronoun', t, languageTag: 'en-US')[null],
          'They');
    });

    test('A select may be part of a longer message, with placeholders', () {
      var t = translationsFrom(r'''
{
  "friend": "{gender, select, male{{name} is his friend} female{{name} is her friend} other{{name} is their friend}}",
  "title": "Dear {gender, select, male{Mr.} female{Ms.} other{Mx.}} {name},"
}
''');

      expect(
        localizeVersion('male', 'friend', t, languageTag: 'en-US')
            .args({'name': 'Bob'}),
        'Bob is his friend',
      );

      expect(localizeAllVersions('title', t, languageTag: 'en-US'), {
        null: 'Dear Mx. {name},',
        'male': 'Dear Mr. {name},',
        'female': 'Dear Ms. {name},',
      });

      expect(
        localizeVersion('female', 'title', t, languageTag: 'en-US')
            .args({'name': 'Ann'}),
        'Dear Ms. Ann,',
      );
    });

    test('The select variable is kept as a placeholder, and # is text', () {
      expect(
        versionsOf('a',
            r'''{"a": "{status, select, done{Done: {status} #1} other{{status}}}"}'''),
        {null: '{status}', 'done': 'Done: {status} #1'},
      );
    });

    test('Case names may have digits and underscores', () {
      expect(
        versionsOf('a',
            r'''{"a": "{s, select, in_progress{Working} step2{Second} other{Unknown}}"}'''),
        {null: 'Unknown', 'in_progress': 'Working', 'step2': 'Second'},
      );
    });

    test('A select with only the other case is plain text', () {
      expect(
        loader.decode(r'''{"a": "{gender, select, other{They}}"}'''),
        {'a': 'They'},
      );
    });

    test('Throws if the select is malformed, naming the message', () {
      expect(
        () => loader.decode('{"a": "{g, select, male{He}}"}'),
        isMessageError('a', contains("The select must have an 'other' case")),
      );

      expect(
        () => loader.decode('{"a": "{g, select, =1{He} other{They}}"}'),
        isMessageError('a', contains("Unexpected '=' in a select")),
      );

      expect(
        () => loader
            .decode('{"a": "{g, select, male{He} male{Him} other{They}}"}'),
        isMessageError('a', contains("The case 'male' is duplicated")),
      );
    });
  });

  group('I18nArbLoader.decode: escaping', () {
    //
    test('By default, an apostrophe is just an apostrophe', () {
      var result = I18nArbLoader().decode(r'''
{
  "its": "It's {name}",
  "two": "Don''t",
  "quoted": "'{name}' is {name}"
}
''');

      expect(result, {
        'its': "It's {name}",
        'two': "Don''t",
        'quoted': "'{name}' is {name}",
      });
    });

    test('By default, there is no way to write a literal brace', () {
      expect(
        () => I18nArbLoader().decode('''{"brace": "A '{' here"}'''),
        isMessageError('brace', contains('Expected an argument name')),
      );
    });

    test('With useEscaping, text between single quotes is literal', () {
      var result = I18nArbLoader(useEscaping: true).decode(r'''
{
  "brace": "A '{' here",
  "braces": "In math, '{1, 2, 3}' is a set.",
  "notPlaceholder": "'{name}' is {name}",
  "twoQuotes": "Don''t",
  "flutterDoc": "Hello! 'Flutter''s amazing'. {name}",
  "empty": "Say '' now",
  "hash": "'#' is a hash"
}
''');

      expect(result, {
        'brace': 'A { here',
        'braces': 'In math, {1, 2, 3} is a set.',
        'notPlaceholder': '{name} is {name}',
        'twoQuotes': "Don't",
        'flutterDoc': "Hello! Flutter's amazing. {name}",
        'empty': "Say ' now",
        'hash': '# is a hash',
      });

      // Four quotes are two apostrophes.
      var fourQuotes = "'" * 4;
      expect(
        I18nArbLoader(useEscaping: true).decode('{"a": "$fourQuotes"}'),
        {'a': "''"},
      );
    });

    test('With useEscaping, a quote without a closing quote is an apostrophe',
        () {
      var result = I18nArbLoader(useEscaping: true).decode(r'''
{
  "its": "It's {name}",
  "end": "Rock 'n roll'"
}
''');

      expect(result, {
        'its': "It's {name}",
        'end': "Rock n roll",
      });
    });

    test('With useEscaping, quoted text inside a plural is literal', () {
      var t = translationsFrom(r'''
{
  "a": "{n, plural, one{'#' # item} other{'{'# items'}'}}"
}
''', useEscaping: true);

      expect(localizeAllVersions('a', t, languageTag: 'en-US'), {
        null: '{%d items}',
        '1': '# %d item',
      });

      expect(localizePlural(1, 'a', t, languageTag: 'en-US'), '# 1 item');
      expect(localizePlural(3, 'a', t, languageTag: 'en-US'), '{3 items}');
    });

    test('Quotes inside the braces of an argument are not escapes', () {
      var result = I18nArbLoader(useEscaping: true)
          .decode(r'''{"a": "On {date, date, 'at' HH:mm}"}''');

      expect(result, {'a': 'On {date}'});
    });
  });

  group('I18nArbLoader.fromAssetDir', () {
    //
    const dir = 'assets/translations';

    const files = {
      '$dir/app_en.arb':
          '{"@@locale": "en-US", "Hello": "Hello", "Bye": "Bye"}',
      '$dir/es-ES.arb': '{"Hello": "Hola", "Bye": "Adiós"}',
      '$dir/more_translations/app_pt_BR.arb': '{"Hello": "Olá"}',
      '$dir/de-DE.json': '{"Hello": "Hallo"}',
      'assets/other/it.arb': '{"Hello": "Ciao"}',
    };

    setUp(() => mockAssets(files));
    tearDown(() => rootBundle.clear());

    test(
        'Loads the .arb files in the directory and its subdirectories, '
        'and no other files', () async {
      var result = await I18nArbLoader().fromAssetDir(dir);

      expect(result, {
        'Hello': {'en-US': 'Hello', 'es-ES': 'Hola', 'pt-BR': 'Olá'},
        'Bye': {'en-US': 'Bye', 'es-ES': 'Adiós'},
      });
    });
  });

  group('I18nArbLoader.fromAssetDir, with a file that fails to decode', () {
    //
    const dir = 'assets/translations';
    const enUs = '$dir/app_en.arb';
    const noLocale = '$dir/strings.arb';
    const badPlural = '$dir/app_es.arb';

    /// Records every call to [I18n.failedResourceCallback] as (resource, error).
    late List<(String, Object)> failures;

    setUp(() {
      failures = [];
      I18n.failedResourceCallback =
          (resource, error) => failures.add((resource, error));
      mockAssets({
        enUs: '{"Hello": "Hello"}',
        noLocale: '{"Hello": "Hello"}',
        badPlural: '{"@@locale": "es", "Hello": "{n, plural, one{Hola}}"}',
      });
    });

    tearDown(() {
      I18n.failedResourceCallback = I18n.defaultFailedResourceCallback;
      rootBundle.clear();
    });

    test('By default, a file that fails to decode fails the whole load',
        () async {
      await expectLater(
        I18nArbLoader().fromAssetDir(dir),
        throwsA(isTranslationsException(startsWith('Error decoding $dir/'))),
      );

      expect(failures, isEmpty);
    });

    test(
        'With failOnInvalidResource: false, the files are skipped and reported',
        () async {
      var result =
          await I18nArbLoader().fromAssetDir(dir, failOnInvalidResource: false);

      expect(result, {
        'Hello': {'en': 'Hello'},
      });

      expect(failures.map((f) => f.$1), unorderedEquals([noLocale, badPlural]));

      var noLocaleFailure = failures.singleWhere((f) => f.$1 == noLocale);
      expect(
        noLocaleFailure.$2,
        isTranslationsException(allOf(
          startsWith('Error decoding $noLocale: '),
          contains("The locale of the ARB file 'strings.arb' could not be "
              'determined'),
        )),
      );

      var badPluralFailure = failures.singleWhere((f) => f.$1 == badPlural);
      expect(
        badPluralFailure.$2,
        isTranslationsException(allOf(
          startsWith('Error decoding $badPlural: '),
          contains("Error in message 'Hello'"),
          contains("The plural must have an 'other' case"),
        )),
      );
    });
  });

  group('I18nArbLoader.fromUrl', () {
    //
    const baseUrl = 'https://example.com/translations';

    test('Loads an .arb url, with the locale from @@locale', () async {
      var result = await withMockHttp(
        {'$baseUrl/app_es.arb': '{"@@locale": "es-ES", "Hello": "Hola"}'},
        () => I18nArbLoader().fromUrl('$baseUrl/app_es.arb'),
      );

      expect(result, {
        'Hello': {'es-ES': 'Hola'},
      });
    });

    test('Loads an .arb url, with the locale from the file name', () async {
      var result = await withMockHttp(
        {'$baseUrl/app_pt_BR.arb': '{"Hello": "Olá"}'},
        () => I18nArbLoader().fromUrl('$baseUrl/app_pt_BR.arb'),
      );

      expect(result, {
        'Hello': {'pt-BR': 'Olá'},
      });
    });

    test('Ignores the urls with another extension', () async {
      var result = await withMockHttp(
        {'$baseUrl/es-ES.json': '{"Hello": "Hola"}'},
        () => I18nArbLoader().fromUrl('$baseUrl/es-ES.json'),
      );

      expect(result, isEmpty);
    });

    test('Throws if the file fails to decode', () async {
      await withMockHttp({'$baseUrl/es-ES.arb': '{"Hello": "{}"}'}, () async {
        await expectLater(
          I18nArbLoader().fromUrl('$baseUrl/es-ES.arb'),
          throwsA(isTranslationsException(allOf(
            startsWith('Error decoding $baseUrl/es-ES.arb: '),
            contains("Error in message 'Hello'"),
          ))),
        );
      });
    });
  });

  group('Default loaders', () {
    //
    const dir = 'assets/translations';

    late List<I18nLoader Function()> originalLoaders;

    setUp(() {
      originalLoaders = List.of(I18n.loaders);
      I18nTranslationsExtension.initLoadProcess();
    });

    tearDown(() {
      I18n.loaders
        ..clear()
        ..addAll(originalLoaders);
      rootBundle.clear();
    });

    test('I18n.loaders includes the ARB loader', () {
      var extensions = I18n.loaders.map((loader) => loader().extension);
      expect(
          extensions, containsAll(['.json', '.po', '.yaml', '.yml', '.arb']));

      var arbLoaders = I18n.loaders.map((l) => l()).whereType<I18nArbLoader>();
      expect(arbLoaders.single.useEscaping, isFalse);
    });

    test('Translations.byFile loads .arb files, together with the other files',
        () async {
      mockAssets({
        '$dir/en-US.json':
            '{"Hello": "Hello", "You clicked %d times": "You clicked %d times"}',
        '$dir/app_es.arb': r'''
{
  "@@locale": "es-ES",
  "Hello": "Hola",
  "You clicked %d times": "{n, plural, =0{No hiciste clic} one{Hiciste clic una vez} other{Hiciste clic # veces}}"
}
''',
        '$dir/app_pt_BR.arb': '{"Hello": "Olá"}',
      });

      var t = Translations.byFile('en-US', dir: dir);
      await t.load();

      expect(localize('Hello', t, languageTag: 'en-US'), 'Hello');
      expect(localize('Hello', t, languageTag: 'es-ES'), 'Hola');
      expect(localize('Hello', t, languageTag: 'pt-BR'), 'Olá');

      expect(
        localizePlural(0, 'You clicked %d times', t, languageTag: 'es-ES'),
        'No hiciste clic',
      );
      expect(
        localizePlural(1, 'You clicked %d times', t, languageTag: 'es-ES'),
        'Hiciste clic una vez',
      );
      expect(
        localizePlural(3, 'You clicked %d times', t, languageTag: 'es-ES'),
        'Hiciste clic 3 veces',
      );

      // The English translation, from the JSON file, also works as a plural.
      expect(
        localizePlural(3, 'You clicked %d times', t, languageTag: 'en-US'),
        'You clicked 3 times',
      );
    });

    test('Translations.byHttp loads .arb resources', () async {
      const baseUrl = 'https://example.com/translations';

      await withMockHttp({
        '$baseUrl/app_en.arb': '{"Hello": "Hello"}',
        '$baseUrl/app_es.arb': '{"@@locale": "es-ES", "Hello": "Hola"}',
      }, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['app_en.arb', 'app_es.arb'],
        );

        await t.load();

        expect(t.translationByLocale_ByTranslationKey, {
          'Hello': {'en': 'Hello', 'es-ES': 'Hola'},
        });

        expect(localize('Hello', t, languageTag: 'es-ES'), 'Hola');

        // The `en` translation is found for `en-US`, by the language.
        expect(localize('Hello', t, languageTag: 'en-US'), 'Hello');
      });
    });

    test('The default ARB loader may be replaced by one with useEscaping',
        () async {
      I18n.loaders.removeWhere((loader) => loader() is I18nArbLoader);
      I18n.loaders.add(() => I18nArbLoader(useEscaping: true));

      mockAssets({
        '$dir/app_en.arb': '''{"set": "In math, '{1, 2, 3}' is a set."}''',
      });

      var t = Translations.byFile('en-US', dir: dir);
      await t.load();

      expect(
        localize('set', t, languageTag: 'en-US'),
        'In math, {1, 2, 3} is a set.',
      );
    });
  });
}
