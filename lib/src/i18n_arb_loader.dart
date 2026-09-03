import 'dart:convert';

import 'package:i18n_extension/i18n_extension.dart';

/// Loads translations from ARB (Application Resource Bundle) files, the format used
/// by Flutter's own `gen-l10n` localization tool, and by translation services like
/// Localizely, Crowdin, Lokalise and POEditor.
///
/// An ARB file is a JSON file, where each key is a translation key (a resource id),
/// and each value is its translation. Keys starting with `@` hold metadata, which
/// is meant for translators and tools, and is ignored here. For example, a file
/// like `app_es.arb`:
///
/// ```json
/// {
///   "@@locale": "es",
///   "helloWorld": "¡Hola, Mundo!",
///   "@helloWorld": {
///     "description": "The conventional greeting."
///   },
///   "welcome": "Bienvenido, {name}",
///   "@welcome": {
///     "placeholders": {
///       "name": { "type": "String", "example": "Juan" }
///     }
///   },
///   "itemCount": "{count, plural, =0{Sin artículos} one{Un artículo} other{# artículos}}",
///   "pronoun": "{gender, select, male{él} female{ella} other{ellos}}"
/// }
/// ```
///
/// # The locale of the file
///
/// The locale is taken from the `@@locale` attribute, when present. Otherwise, it's
/// taken from the file name, which may be the locale itself, like `es-ES.arb` or
/// `es_ES.arb`, or may end with the locale after an underscore, following the
/// Flutter convention, like `app_es.arb`, `intl_messages_pt_BR.arb` or
/// `app_zh_Hans_CN.arb`. If the locale can't be determined, the file fails to load.
///
/// # Placeholders
///
/// Placeholders like `{name}` or `{0}` are kept as they are, so that you can fill
/// them with the [I18nMainExtension.args] function:
///
/// ```dart
/// 'welcome'.i18n.args({'name': 'Juan'}); // Bienvenido, Juan
/// ```
///
/// Placeholders with a type and a format, like `{price, number, currency}` or
/// `{date, date, ::yMd}`, and placeholders whose `type` and `format` are declared
/// in the `@` metadata, are also kept as simple placeholders, like `{price}` and
/// `{date}`. The loader doesn't format values, so you must pass them already
/// formatted, as text, to the `args` function.
///
/// # Plurals
///
/// A message with an ICU plural becomes a translation with plural versions, to be
/// used with the `plural` function (the one created with [localizePlural]):
///
/// ```dart
/// 'itemCount'.plural(0); // Sin artículos
/// 'itemCount'.plural(1); // Un artículo
/// 'itemCount'.plural(5); // 5 artículos
/// ```
///
/// Inside the plural, both `#` and the plural variable, like `{count}`, become the
/// number. The plural cases become these versions: `=0` and `zero` become `.zero()`,
/// `=1` and `one` become `.one()`, `=2` and `two` become `.two()`, `few` becomes
/// `.twoThreeFour()`, `many` becomes `.many()`, other `=N` become `.times(N)`, and
/// `other` is the default text, which is used when no other version applies. An
/// exact case like `=1` wins over a category like `one`. Note the versions are
/// selected by the rules of the `plural` function, which are the same for all
/// languages, and not by the CLDR rules of each language.
///
/// The plural may be part of a longer message, like `"{name} has {count, plural,
/// one{one item} other{# items}} in the cart"`, in which case each version contains
/// the whole message. However, a message may contain only one plural or select, and
/// not one inside the other, because the `plural` and `version` functions select a
/// translation by a single value. A message that combines them fails to load, with
/// an error that explains the problem. The plural `offset` is also not supported.
///
/// # Selects
///
/// A message with an ICU select, which is used for genders and similar choices,
/// becomes a translation with versions, one for each case, to be used with the
/// `version` function (the one created with [localizeVersion]). The `other` case is
/// the default text.
///
/// ```dart
/// 'pronoun'.version('male'); // él
/// 'pronoun'.version('female'); // ella
/// 'pronoun'.allVersions()[null]; // ellos (the `other` case)
/// ```
///
/// # Escaping
///
/// By default, following the default of Flutter's `gen-l10n`, there's no escaping:
/// an apostrophe is just an apostrophe, and there's no way to write a literal `{`
/// or `}`. If your `l10n.yaml` has `use-escaping: true`, create the loader with
/// `I18nArbLoader(useEscaping: true)`. Then, text between single quotes is
/// literal, like `'{'` or `'{not a placeholder}'`, and two single quotes `''` are
/// one apostrophe. As a convenience, a single quote that has no closing quote is
/// kept as an apostrophe, instead of failing.
///
/// To replace the default loader with one that uses escaping, do this before the
/// translations are loaded:
///
/// ```dart
/// I18n.loaders.removeWhere((loader) => loader() is I18nArbLoader);
/// I18n.loaders.add(() => I18nArbLoader(useEscaping: true));
/// ```
///
/// Also, following the ARB specification, `{@text}` is literal text that
/// translators shouldn't change, like `{@<b>}`, and becomes just the text.
///
class I18nArbLoader extends I18nLoader {
  //
  /// Creates a loader for `.arb` files. See [useEscaping].
  I18nArbLoader({this.useEscaping = false});

  /// If `false` (the default), an apostrophe is just an apostrophe, and there's no
  /// way to write a literal `{` or `}`. This is the default of Flutter's `gen-l10n`.
  ///
  /// If `true`, text between single quotes is literal, like `'{'`, and two single
  /// quotes `''` are one apostrophe. Use this if your `l10n.yaml` has
  /// `use-escaping: true`.
  final bool useEscaping;

  @override
  String get extension => '.arb';

  /// Decodes the [source] text of an ARB file into a map of translations, where
  /// the messages are already converted to the format used by this package (see
  /// [I18nArbLoader]). The `@@locale` and the other attributes are removed.
  ///
  /// Throws a [FormatException] if the source is not valid JSON, if it doesn't
  /// contain a JSON object of Strings, if some metadata (a key starting with `@`)
  /// is not a JSON object, or if some message is not a valid ICU message, or uses
  /// a feature that can't be represented by this package.
  @override
  Map<String, dynamic> decode(String source) => _decode(source).translations;

  /// Decodes the ARB file named [fileName], with the given [source] text. The
  /// language tag comes from the `@@locale` attribute, or else from the file name
  /// (see [localeFromFileName]). Throws a [FormatException] if it can't be
  /// determined and the file has translations.
  @override
  ({String languageTag, Map<String, dynamic> translations}) decodeFile(
    String fileName,
    String source,
  ) {
    var decoded = _decode(source);

    String? languageTag = decoded.locale ?? localeFromFileName(fileName);

    // A file without translations doesn't need a locale.
    if (languageTag == null && decoded.translations.isEmpty) {
      languageTag = 'und';
    }

    if (languageTag == null) {
      throw FormatException(
          "The locale of the ARB file '$fileName' could not be determined. "
          "Add the '@@locale' attribute to the file, or name the file after "
          "the locale, like 'es-ES.arb', 'es_ES.arb' or 'app_es_ES.arb'.");
    }

    return (languageTag: languageTag, translations: decoded.translations);
  }

  ({String? locale, Map<String, dynamic> translations}) _decode(String source) {
    //
    // Some editors save UTF-8 files with a byte order mark (BOM) at the start,
    // which is not valid JSON, so we remove it here.
    if (source.startsWith('\uFEFF')) source = source.substring(1);

    // An empty file is treated as a file without translations.
    if (source.trim().isEmpty) return (locale: null, translations: {});

    // Throws a FormatException if the source is not valid JSON.
    Object? document = json.decode(source);

    if (document is! Map) {
      throw FormatException('The ARB file must contain a JSON object of '
          'translations, but it contains ${_describe(document)}.');
    }

    String? locale;
    Object? localeValue = document['@@locale'];

    if (localeValue != null) {
      if (localeValue is! String) {
        throw FormatException("The '@@locale' attribute must be a String, "
            "but it's ${_describe(localeValue)}.");
      }
      if (localeValue.trim().isNotEmpty) locale = localeValue.asLanguageTag;
    }

    Map<String, dynamic> translations = {};

    for (var entry in document.entries) {
      String key = entry.key as String;
      Object? value = entry.value;

      // Global attributes, like `@@locale`, `@@context`, `@@last_modified`,
      // `@@author`, `@@comment` and the custom `@@x-...`, are not translations.
      if (key.startsWith('@@')) continue;

      // The metadata of a message, like `@helloWorld`, is for translators and
      // tools. It must be a JSON object, with the description, placeholders etc.
      if (key.startsWith('@')) {
        if (value is! Map) {
          throw FormatException("The metadata '$key' must be a JSON object, "
              "but it's ${_describe(value)}.");
        }
        continue;
      }

      if (value is! String) {
        throw FormatException("Value '$value' for key '$key' is not a String, "
            "but ${_describe(value)}.");
      }

      translations[key] =
          _IcuMessage(key, value, useEscaping: useEscaping).convert();
    }

    return (locale: locale, translations: translations);
  }

  /// Returns the language tag of an ARB file from its [fileName], or `null` if
  /// the file name doesn't contain a locale.
  ///
  /// The file name may be the locale itself, like `es-ES.arb` or `es_ES.arb`, or
  /// may end with the locale after an underscore (or a hyphen or a dot), following
  /// the Flutter convention, like `app_es.arb`, `intl_messages_pt_BR.arb` or
  /// `app_zh_Hans_CN.arb`.
  ///
  /// In detail, the whole file name (without the extension) is tried first, and
  /// then the part after each separator, from left to right. The first one that
  /// is a valid locale wins, where a valid locale has a known ISO 639 language
  /// code, and optionally a script and a region, like `zh-Hans-CN` or `es-419`.
  /// The language tag is returned normalized, like `pt-BR` for `app_pt_br.arb`.
  ///
  static String? localeFromFileName(String fileName) {
    //
    // Remove the directories and the extension.
    var name = fileName.split('/').last;
    var dot = name.lastIndexOf('.');
    var base = (dot == -1) ? name : name.substring(0, dot);

    // The candidates are the whole name, and the part after each separator.
    var candidates = [base];
    for (int i = 0; i < base.length; i++) {
      var char = base[i];
      if (char == '_' || char == '-' || char == '.') {
        candidates.add(base.substring(i + 1));
      }
    }

    for (var candidate in candidates) {
      var match = _localePattern.firstMatch(candidate);
      if (match != null &&
          _iso639Languages.contains(match.group(1)!.toLowerCase())) {
        return candidate.asLanguageTag;
      }
    }

    return null;
  }

  /// A language (2 or 3 letters), an optional script (4 letters), and an optional
  /// region (2 letters or 3 digits), separated by hyphens or underscores.
  static final _localePattern = RegExp(
      r'^([a-zA-Z]{2,3})(?:[-_][a-zA-Z]{4})?(?:[-_](?:[a-zA-Z]{2}|[0-9]{3}))?$');

  static String _describe(Object? value) {
    if (value == null) return 'null';
    if (value is num) return 'a number';
    if (value is bool) return 'a boolean';
    if (value is Map) return 'a JSON object';
    if (value is List) return 'a list';
    return 'a ${value.runtimeType}';
  }
}

/// The nodes of a parsed ICU message.
sealed class _Node {}

/// Literal text.
class _Text extends _Node {
  _Text(this.text);

  final String text;
}

/// A simple placeholder, like `{name}` or `{0}`.
class _Placeholder extends _Node {
  _Placeholder(this.name);

  final String name;
}

/// The `#` inside a plural case, which is the number.
class _Pound extends _Node {}

/// A plural or select, like `{count, plural, one{...} other{...}}`.
class _Selection extends _Node {
  _Selection(this.type, this.argument, this.cases);

  /// Either `plural` or `select`.
  final String type;

  /// The name of the argument, like `count`.
  final String argument;

  /// The cases, in the order they appear. The selector of a plural case is a
  /// category like `one`, or an exact value like `=1`.
  final List<({String selector, List<_Node> nodes})> cases;

  bool get isPlural => type == 'plural';
}

/// Parses one ICU message of an ARB file, and converts it into the format used
/// by this package: plain text with placeholders, or a text with versions, for
/// the `plural` and `version` functions. See [I18nArbLoader] for the details.
class _IcuMessage {
  //
  _IcuMessage(this.key, this.message, {required this.useEscaping});

  final String key;
  final String message;
  final bool useEscaping;

  int _pos = 0;

  static const _splitter1 = '\uFFFF';
  static const _splitter2 = '\uFFFE';

  static final _whitespace = RegExp(r'\s+');
  static final _identifier = RegExp(r'[\p{L}\p{N}_]+', unicode: true);
  static final _digits = RegExp(r'[0-9]+');
  static final _quoted = RegExp(r"'[^']*'");

  static const _pluralCategories = {
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other'
  };

  static const _formattedTypes = {
    'number',
    'date',
    'time',
    'spellout',
    'ordinal',
    'duration',
  };

  String convert() {
    //
    List<_Node> nodes = _parseMessage(inPlural: false, depth: 0);

    List<int> selectionIndexes = [
      for (int i = 0; i < nodes.length; i++)
        if (nodes[i] is _Selection) i,
    ];

    // A message without plural or select is plain text with placeholders.
    if (selectionIndexes.isEmpty) return _render(nodes);

    if (selectionIndexes.length > 1) {
      throw _error("The message has more than one plural or select. "
          "The plural and version functions select a translation by a single "
          "value, so a message may contain only one plural or select. "
          "Split it into separate messages");
    }

    // A message with a plural or select becomes a text with versions, where each
    // version contains the whole message, with the corresponding case in place.
    int index = selectionIndexes.single;
    var selection = nodes[index] as _Selection;
    var before = nodes.sublist(0, index);
    var after = nodes.sublist(index + 1);
    String? pluralArgument = selection.isPlural ? selection.argument : null;

    String? defaultText;
    Map<String, String> versions = {};

    // In a plural, an exact case like `=1` wins over a category like `one`,
    // so the exact cases are added last, and overwrite the categories.
    var cases = [
      ...selection.cases.where((c) => !c.selector.startsWith('=')),
      ...selection.cases.where((c) => c.selector.startsWith('=')),
    ];

    for (var (:selector, :nodes) in cases) {
      var text = _render([...before, ...nodes, ...after],
          pluralArgument: pluralArgument);

      if (selector == 'other') {
        defaultText = text;
      } else {
        versions[selection.isPlural ? _pluralModifier(selector) : selector] =
            text;
      }
    }

    // The `other` case is required, so `defaultText` is never null here.
    // With no other cases, the message is plain text (which still works with
    // the `plural` function).
    if (versions.isEmpty) return defaultText!;

    var buffer = StringBuffer('$_splitter1$defaultText');
    for (var entry in versions.entries) {
      buffer.write('$_splitter1${entry.key}$_splitter2${entry.value}');
    }

    return buffer.toString();
  }

  /// Renders the [nodes] as text. Inside a plural, the `#` and the plural
  /// argument, like `{count}`, become `%d`, which the `plural` function replaces
  /// with the number.
  String _render(List<_Node> nodes, {String? pluralArgument}) {
    var buffer = StringBuffer();

    for (var node in nodes) {
      switch (node) {
        case _Text():
          buffer.write(node.text);
        case _Placeholder():
          buffer.write((node.name == pluralArgument) ? '%d' : '{${node.name}}');
        case _Pound():
          buffer.write('%d');
        case _Selection():
          // Nested selections are rejected by the parser.
          throw _error('Unexpected ${node.type}');
      }
    }

    return buffer.toString();
  }

  /// The version modifier for a plural case, matching the modifiers created by
  /// the string extensions `.zero()`, `.one()`, `.two()`, `.twoThreeFour()`,
  /// `.many()`, `.ten()` and `.times(n)`.
  static String _pluralModifier(String selector) {
    switch (selector) {
      case 'zero':
        return '0';
      case 'one':
        return '1';
      case 'two':
        return '2';
      case 'few':
        return 'C';
      case 'many':
        return 'M';
      default:
        // An exact case, like `=3`. Note the modifier for 10 is 'T'.
        int number = int.parse(selector.substring(1));
        return (number == 10) ? 'T' : number.toString();
    }
  }

  /// Parses the message text until the end (at depth 0), or until the `}` that
  /// closes the current plural or select case (at depth 1), which is not consumed.
  List<_Node> _parseMessage({required bool inPlural, required int depth}) {
    //
    List<_Node> nodes = [];
    var text = StringBuffer();

    void flushText() {
      if (text.isNotEmpty) {
        nodes.add(_Text(text.toString()));
        text.clear();
      }
    }

    while (_pos < message.length) {
      var char = message[_pos];

      if (char == '{') {
        flushText();
        nodes.add(_parseArgument(depth: depth));
      }
      //
      else if (char == '}') {
        if (depth == 0) throw _error("Unmatched '}'");
        flushText();
        return nodes;
      }
      //
      else if (char == '#' && inPlural) {
        flushText();
        nodes.add(_Pound());
        _pos++;
      }
      //
      else if (char == "'" && useEscaping) {
        text.write(_parseQuoted());
      }
      //
      else {
        text.write(char);
        _pos++;
      }
    }

    if (depth > 0) throw _error("Expected '}' but the message ended");

    flushText();
    return nodes;
  }

  /// Parses the text starting with a single quote, when [useEscaping] is true,
  /// following the rules of Flutter's `gen-l10n`: two single quotes are one
  /// apostrophe, and the text between single quotes is literal. A quote without a
  /// closing quote is kept as an apostrophe.
  String _parseQuoted() {
    //
    if (message.startsWith("''", _pos)) {
      _pos += 2;
      return "'";
    }

    var match = _quoted.matchAsPrefix(message, _pos);

    if (match == null) {
      _pos++;
      return "'";
    }

    var quoted = match.group(0)!;

    // In `'Flutter''s amazing'`, the second quoted text is `'s amazing'`, and it
    // follows a quote. It's then read as `'s amazing`, which gives the expected
    // `Flutter's amazing`.
    bool followsQuote = (_pos > 0) && (message[_pos - 1] == "'");

    _pos = match.end;

    return followsQuote
        ? quoted.substring(0, quoted.length - 1)
        : quoted.substring(1, quoted.length - 1);
  }

  /// Parses an argument, starting at its `{`, and consumes its closing `}`.
  _Node _parseArgument({required int depth}) {
    //
    _pos++; // Consumes the `{`.

    // In the ARB specification, `{@text}` is literal text that translators should
    // not change, like `{@<b>}`.
    if (_peek() == '@') {
      int end = message.indexOf('}', _pos);
      if (end == -1) throw _error("Expected '}' but the message ended");
      var literal = message.substring(_pos + 1, end);
      _pos = end + 1;
      return _Text(literal);
    }

    _skipWhitespace();
    var name = _readIdentifier('an argument name');
    _skipWhitespace();

    // A simple placeholder, like `{name}` or `{0}`.
    if (_peek() == '}') {
      _pos++;
      return _Placeholder(name);
    }

    if (_peek() != ',') {
      throw _error("Expected '}' or ',' after the argument name '$name'");
    }

    _pos++; // Consumes the `,`.
    _skipWhitespace();
    var type = _readIdentifier('an argument type');
    _skipWhitespace();

    switch (type) {
      case 'plural':
      case 'select':
        if (depth > 0) {
          throw _error("The message has a $type inside a plural or select. "
              "The plural and version functions select a translation by a "
              "single value, so a message may contain only one plural or select, "
              "and not one inside the other");
        }
        _expect(',');
        var cases = _parseCases(type);
        return _Selection(type, name, cases);

      case 'selectordinal':
      case 'choice':
        throw _error("The '$type' argument type is not supported");

      default:
        if (!_formattedTypes.contains(type)) {
          throw _error("Unknown argument type '$type'");
        }

        // A formatted placeholder, like `{price, number, currency}` or
        // `{date, date, ::yMd}`. The format is ignored, since the app must pass
        // the value already formatted, and it becomes a simple placeholder.
        if (_peek() == ',') {
          _pos++;
          _skipFormat();
        }
        _expect('}');
        return _Placeholder(name);
    }
  }

  /// Parses the cases of a plural or select, after the `plural,` or `select,`,
  /// and consumes the closing `}`.
  List<({String selector, List<_Node> nodes})> _parseCases(String type) {
    //
    bool isPlural = (type == 'plural');
    List<({String selector, List<_Node> nodes})> cases = [];

    while (true) {
      _skipWhitespace();

      if (_pos >= message.length) {
        throw _error("Expected '}' but the message ended");
      }

      if (_peek() == '}') {
        _pos++;
        break;
      }

      String selector;

      // An exact case, like `=1`.
      if (_peek() == '=') {
        if (!isPlural) throw _error("Unexpected '=' in a select");
        _pos++;
        _skipWhitespace();
        var match = _digits.matchAsPrefix(message, _pos);
        if (match == null) throw _error("Expected a number after '='");
        _pos = match.end;
        selector = '=${match.group(0)}';
      }
      //
      else {
        selector = _readIdentifier('a case name');

        if (isPlural) {
          _skipWhitespace();
          if (selector == 'offset' && _peek() == ':') {
            throw _error("The plural offset is not supported");
          }
          if (!_pluralCategories.contains(selector)) {
            throw _error("The plural case '$selector' must be one of "
                "'zero', 'one', 'two', 'few', 'many', 'other', or an exact "
                "value like '=1'");
          }
        }
      }

      _skipWhitespace();
      _expect('{');
      var nodes = _parseMessage(inPlural: isPlural, depth: 1);
      _expect('}');

      if (cases.any((c) => c.selector == selector)) {
        throw _error("The case '$selector' is duplicated");
      }

      cases.add((selector: selector, nodes: nodes));
    }

    if (!cases.any((c) => c.selector == 'other')) {
      throw _error("The $type must have an 'other' case");
    }

    return cases;
  }

  /// Skips the format of a formatted placeholder, like `currency` in
  /// `{price, number, currency}`, up to (but not including) the closing `}`.
  /// The format may contain commas and even braces, like `{d, date, EEE, MMM d}`.
  void _skipFormat() {
    int depth = 0;

    while (_pos < message.length) {
      var char = message[_pos];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        if (depth == 0) return;
        depth--;
      }
      _pos++;
    }
  }

  String? _peek() => (_pos < message.length) ? message[_pos] : null;

  void _skipWhitespace() {
    var match = _whitespace.matchAsPrefix(message, _pos);
    if (match != null) _pos = match.end;
  }

  String _readIdentifier(String what) {
    var match = _identifier.matchAsPrefix(message, _pos);
    if (match == null) throw _error('Expected $what');
    _pos = match.end;
    return match.group(0)!;
  }

  void _expect(String char) {
    if (_peek() != char) {
      throw _error((_pos >= message.length)
          ? "Expected '$char' but the message ended"
          : "Expected '$char' but found '${message[_pos]}'");
    }
    _pos++;
  }

  FormatException _error(String problem) => FormatException(
      "Error in message '$key', at position $_pos: $problem. Message: $message");
}

/// The ISO 639 language codes, used to tell the locale apart from the rest of the
/// file name, like the `en` in `app_en.arb`. This is the same list Flutter's
/// `gen-l10n` uses.
const _iso639Languages = <String>{
  'aa', 'ab', 'ae', 'af', 'ak', 'am', 'an', 'ar', 'as', 'av', 'ay', 'az', //
  'ba', 'be', 'bg', 'bh', 'bi', 'bm', 'bn', 'bo', 'br', 'bs', //
  'ca', 'ce', 'ch', 'co', 'cr', 'cs', 'cu', 'cv', 'cy', //
  'da', 'de', 'dv', 'dz', //
  'ee', 'el', 'en', 'eo', 'es', 'et', 'eu', //
  'fa', 'ff', 'fi', 'fil', 'fj', 'fo', 'fr', 'fy', //
  'ga', 'gd', 'gl', 'gn', 'gsw', 'gu', 'gv', //
  'ha', 'he', 'hi', 'ho', 'hr', 'ht', 'hu', 'hy', 'hz', //
  'ia', 'id', 'ie', 'ig', 'ii', 'ik', 'io', 'is', 'it', 'iu', //
  'ja', 'jv', //
  'ka', 'kg', 'ki', 'kj', 'kk', 'kl', 'km', 'kn', 'ko', 'kr', 'ks', 'ku', 'kv',
  'kw', 'ky', //
  'la', 'lb', 'lg', 'li', 'ln', 'lo', 'lt', 'lu', 'lv', //
  'mg', 'mh', 'mi', 'mk', 'ml', 'mn', 'mr', 'ms', 'mt', 'my', //
  'na', 'nb', 'nd', 'ne', 'ng', 'nl', 'nn', 'no', 'nr', 'nv', 'ny', //
  'oc', 'oj', 'om', 'or', 'os', //
  'pa', 'pi', 'pl', 'ps', 'pt', //
  'qu', //
  'rm', 'rn', 'ro', 'ru', 'rw', //
  'sa', 'sc', 'sd', 'se', 'sg', 'si', 'sk', 'sl', 'sm', 'sn', 'so', 'sq', 'sr',
  'ss', 'st', 'su', 'sv', 'sw', //
  'ta', 'te', 'tg', 'th', 'ti', 'tk', 'tl', 'tn', 'to', 'tr', 'ts', 'tt', 'tw',
  'ty', //
  'ug', 'uk', 'ur', 'uz', //
  've', 'vi', 'vo', //
  'wa', 'wo', //
  'xh', //
  'yi', 'yo', //
  'za', 'zh', 'zu',
};
