import 'package:yaml/yaml.dart';

import 'i18n_loader.dart';

/// Loads translations from YAML files.
///
/// A file like `es-ES.yaml` must contain a map, where each key is a translation
/// key, and each value is its translation:
///
/// ```yaml
/// # Comments are allowed.
/// Welcome to this demo.: Bienvenido a esta demostración.
/// i18n Demo: Demostración i18n
/// Increment: Incrementar
/// "Change Language": "Cambiar idioma"
/// "You clicked the button %d times:": "Hiciste clic en el botón %d veces:"
///
/// # Long texts can use the YAML multiline styles. The literal style (|) keeps
/// # the line breaks, and the folded style (>) joins the lines with spaces.
/// "Please read our terms of use before continuing.": >-
///   Por favor, lea nuestros términos de uso
///   antes de continuar.
/// ```
///
/// A translation may also be a map of its versions, like plurals and genders,
/// which works like the string modifiers `.zero()`, `.one()`, `.times()`,
/// `.male()`, `.female()`, `.modifier()` etc. The `other` version is the text
/// used when no other version applies, and is required. An integer version, like
/// `12`, is the same as `.times(12)`, and may be unquoted:
///
/// ```yaml
/// "You clicked the button %d times:":
///   other: "Hiciste clic en el botón %d veces:"
///   zero: "No hiciste clic en el botón:"
///   one: "Hiciste clic en el botón una vez:"
///   12: "Hiciste clic en el botón una docena de veces:"
/// There is a person:
///   other: Hay una persona
///   male: Hay un hombre
///   female: Hay una mujer
/// ```
///
/// See [I18nLoader.fromAssetDir] for the names of all the versions, and for how
/// to combine gender and plural, by nesting the plural versions inside a gender
/// version.
///
/// Keys and values must be Strings (except the integer versions). Note that in
/// YAML, an unquoted `123`, `1.5`, `true`, `false` or `null` is read as a number,
/// a boolean or null, not as text, and an empty value is also read as null. To
/// use those as a translation key or value, quote them, like `"123"`. Keys that
/// contain `: ` or ` #`, or that start with characters like `-`, `?`, `[`, `{`,
/// `*`, `&`, `!`, `%`, `@` or a quote, must also be quoted, and the same goes for
/// values. When in doubt, quote them.
///
/// Lists are not supported, and versions can't be nested: each version must be
/// text.
///
/// YAML files may end with `.yaml` or `.yml`. Since each loader handles a single
/// file extension, there are two loaders: [I18nYamlLoader.new] loads `.yaml`
/// files, and [I18nYamlLoader.yml] loads `.yml` files. Both are in the
/// `I18n.loaders` list by default.
///
class I18nYamlLoader extends I18nLoader {
  //
  /// Loads the files that end with `.yaml`.
  I18nYamlLoader() : extension = '.yaml';

  /// Loads the files that end with `.yml`, the other common extension of YAML files.
  I18nYamlLoader.yml() : extension = '.yml';

  @override
  final String extension;

  /// Decodes the [source] text of a YAML file into a map of translations, where
  /// each value is a String, or a map of versions (Strings to Strings, or to maps
  /// of versions of their own, like the plural versions of a gender).
  ///
  /// Throws a [FormatException] if the source is not valid YAML, or if it doesn't
  /// contain a map of Strings to Strings or maps of versions. An empty file, or a
  /// file with only comments, is valid and results in an empty map.
  @override
  Map<String, dynamic> decode(String source) {
    //
    // Some editors save UTF-8 files with a byte order mark (BOM) at the start.
    // The YAML spec allows it, but the `yaml` package fails to parse a document
    // that starts with it (it sees a second document on the next line), so we
    // remove it here.
    if (source.startsWith('\uFEFF')) source = source.substring(1);

    // Throws a `YamlException` (which is a `FormatException`) if the source is not
    // valid YAML, if it contains more than one document, or if it has duplicate keys.
    Object? document = loadYaml(source);

    // An empty file, or a file with only comments, is a valid YAML document
    // with no content. It simply has no translations.
    if (document == null) return {};

    if (document is! Map) {
      throw FormatException('The YAML file must contain a map of translations, '
          'but it contains ${_describe(document)}.');
    }

    Map<String, dynamic> translations = {};

    for (var entry in document.entries) {
      Object? key = entry.key;
      Object? value = entry.value;

      if (key is! String) {
        throw FormatException(
            "Key '$key' is not a String, but ${_describe(key)}. ${_hint(key)}");
      }

      if (value is String) {
        translations[key] = value;
      }
      //
      // A map of versions, like `{other: ..., one: ..., 12: ...}`.
      else if (value is Map) {
        translations[key] = _versions(key, value);
      }
      //
      else {
        throw FormatException("Value '$value' for key '$key' is not a String, "
            "but ${_describe(value)}. ${_hint(value)}");
      }
    }

    return translations;
  }

  /// Returns the map of versions of the translation [key], checking that each
  /// version is named with a String or an integer (YAML reads an unquoted `12` as
  /// an integer), and that each version is a String, or a map of versions of its
  /// own (like the plural versions of a gender, see [I18nLoader.fromAssetDir]).
  /// The integers become Strings, so that the base loader can read the names.
  /// The [parent] is the name of the version whose nested versions these are.
  static Map<String, dynamic> _versions(String key, Map map, {String? parent}) {
    Map<String, dynamic> versions = {};

    // Describes what's being read, for the error messages.
    String what = (parent == null) ? "key '$key'" : "version '$parent' of key '$key'";

    for (var entry in map.entries) {
      Object? name = entry.key;
      Object? text = entry.value;

      if (name is! String && name is! int) {
        throw FormatException(
            "${what[0].toUpperCase()}${what.substring(1)} has a version named "
            "'$name', which is not a String, but ${_describe(name)}. ${_hint(name)}");
      }

      // Nested versions, like the plural versions of a gender. The base loader
      // checks where they are allowed.
      if (text is Map) {
        versions[name.toString()] = _versions(key, text, parent: name.toString());
      }
      //
      else if (text is! String) {
        throw FormatException("Version '$name' of $what is not a String, "
            "but ${_describe(text)}. ${_hint(text)}");
      }
      //
      else {
        versions[name.toString()] = text;
      }
    }

    return versions;
  }

  static String _describe(Object? value) {
    if (value == null) return 'null';
    if (value is num) return 'a number';
    if (value is bool) return 'a boolean';
    if (value is Map) return 'a map';
    if (value is List) return 'a list';
    return 'a ${value.runtimeType}';
  }

  static String _hint(Object? value) {
    if (value is Map) {
      return 'A map is only allowed as the versions of a translation, or as the '
          'plural versions inside a gender version.';
    }
    if (value is List) {
      return 'Lists are not supported: each value must be text, '
          'or a map of versions.';
    }
    return 'In YAML, numbers, booleans, null and empty values are not read as text. '
        'To use them as text, quote them, like "123".';
  }
}
