import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:i18n_extension/i18n_extension.dart';

abstract class I18nLoader {
  //

  /// For example, for file 'en-US.json', the extension is '.json'.
  String get extension;

  /// Given [source], the text content of the asset file, returns a map of
  /// translations. Each value is the translated text, or a map of its versions,
  /// like plurals and genders (see [fromAssetDir]).
  Map<String, dynamic> decode(String source);

  /// Given the [fileName] of the asset file (like `es-ES.json`) and its [source]
  /// text content, returns the translations and the language tag they belong to.
  ///
  /// By default, the translations come from [decode], and the language tag comes
  /// from the file name, through [languageTagFromFileName], so that the
  /// translations in `es-ES.json` are for `es-ES`. Loaders of formats that declare
  /// the locale inside the file, like ARB files with their `@@locale` attribute,
  /// may override this to read the language tag from the file itself.
  ///
  /// Any error thrown here is reported as a decoding error of the file.
  ({String languageTag, Map<String, dynamic> translations}) decodeFile(
    String fileName,
    String source,
  ) =>
      (
        languageTag: languageTagFromFileName(fileName),
        translations: decode(source),
      );

  /// Returns the language tag of a translation file from its [fileName], which
  /// must be the locale itself, like `es-ES.json`, `es_ES.po` or `zh-Hans-CN.yaml`.
  /// The tag is normalized, so that `pt_br.json` gives `pt-BR`.
  static String languageTagFromFileName(String fileName) =>
      fileName.split(".")[0].asLanguageTag;

  /// This loader will search for all files that end with the expected [extension],
  /// in the given [dir] directory AND its subdirectories.
  ///
  /// A trailing slash is added to [dir] if it's missing, so that a directory
  /// like `assets/translations` only matches the files inside it, and not the
  /// files in a sibling directory that starts with the same text, like
  /// `assets/translations_old/`.
  ///
  /// While the function itself searches subdirectories, in `pubspec.yaml` you
  /// must **separately** declare all dirs and subdirectories that contain
  /// assets. In other words, Flutter automatically finds all files in the
  /// directory, but it does NOT enter subdirectories, unless you declare them
  /// explicitly in `pubspec.yaml`. For example:
  ///
  /// ```yaml
  /// flutter:
  ///   assets:
  ///     - assets/translations/
  ///     - assets/translations/more_translations/
  /// ```
  ///
  /// This works on all platforms, including the web. Note the asset files are
  /// never read from the user's file system: they are bundled with the app, and
  /// on the web they are downloaded from the web server that hosts the app, like
  /// any other asset.
  ///
  /// A file like `es-ES.json` could contain something like:
  ///
  /// ```json
  /// {
  ///   "Welcome to this demo.": "Bienvenido a esta demostración.",
  ///   "i18n Demo": "Demostración i18n",
  ///   "You clicked the button %d times:": "Hiciste clic en el botón %d veces:"
  /// }
  /// ```
  ///
  /// And files like `es-ES.po`, containing something like:
  ///
  /// ```po
  /// msgid ""
  /// msgstr ""
  /// "Content-Type: text/plain; charset=UTF-8\n"
  ///
  /// msgid "Increment"
  /// msgstr "Incrementar"
  ///
  /// msgid "Change Language"
  /// msgstr "Cambiar Idioma"
  /// ```
  ///
  /// And files like `es-ES.yaml` (or `es-ES.yml`), containing something like:
  ///
  /// ```yaml
  /// Welcome to this demo.: Bienvenido a esta demostración.
  /// "i18n Demo": Demostración i18n
  /// "You clicked the button %d times:": "Hiciste clic en el botón %d veces:"
  /// ```
  ///
  /// And files like `es-ES.arb` (or `app_es.arb`, with the locale in the
  /// `@@locale` attribute), containing something like:
  ///
  /// ```json
  /// {
  ///   "@@locale": "es-ES",
  ///   "Welcome to this demo.": "Bienvenido a esta demostración.",
  ///   "i18n Demo": "Demostración i18n",
  ///   "You clicked the button %d times:": "{count, plural, one{Hiciste clic en el botón una vez:} other{Hiciste clic en el botón # veces:}}"
  /// }
  /// ```
  ///
  /// # Plurals and other versions in JSON and YAML files
  ///
  /// In `.json` and `.yaml` files, a translation may also be a map of versions,
  /// which is the same as using the string modifiers `.zero()`, `.one()`,
  /// `.times()`, `.many()`, `.modifier()` etc. in Dart. The `other` version is
  /// required, and is the text used when no other version applies (in Dart, it's
  /// the string the modifiers are called on). For example, this JSON:
  ///
  /// ```json
  /// {
  ///   "You clicked the button %d times:": {
  ///     "other": "Hiciste clic en el botón %d veces:",
  ///     "zero": "No hiciste clic en el botón:",
  ///     "one": "Hiciste clic en el botón una vez:",
  ///     "12": "Hiciste clic en el botón una docena de veces:"
  ///   },
  ///   "There is a person": {
  ///     "other": "Hay una persona",
  ///     "male": "Hay un hombre",
  ///     "female": "Hay una mujer"
  ///   }
  /// }
  /// ```
  ///
  /// Is the same as this Dart code:
  ///
  /// ```dart
  /// 'es-ES': {
  ///   'You clicked the button %d times:': 'Hiciste clic en el botón %d veces:'
  ///       .zero('No hiciste clic en el botón:')
  ///       .one('Hiciste clic en el botón una vez:')
  ///       .times(12, 'Hiciste clic en el botón una docena de veces:'),
  ///   'There is a person': 'Hay una persona'
  ///       .modifier('male', 'Hay un hombre')
  ///       .modifier('female', 'Hay una mujer'),
  /// }
  /// ```
  ///
  /// The plural versions, for the `plural` function, are `zero`, `one`, `two`,
  /// `three`, `four`, `five`, `six`, `ten`, `twoThreeFour`, `oneOrMore`,
  /// `zeroOne` and `many`, plus any integer, like `12`, which is the same as
  /// `.times(12)`. Any other name, like `male`, is a version for the `version`
  /// function, like `.version('male')`, and must be the `toString()` of the
  /// modifier you pass to that function (for an enum, use `.version(gender.name)`,
  /// or name the version `Gender.male`). This means the plural names above can't
  /// be the names of your own versions. Each version must be text, so versions
  /// can't be nested.
  ///
  /// In YAML, the same translation looks like this (the integer may be unquoted):
  ///
  /// ```yaml
  /// "You clicked the button %d times:":
  ///   other: "Hiciste clic en el botón %d veces:"
  ///   zero: "No hiciste clic en el botón:"
  ///   one: "Hiciste clic en el botón una vez:"
  ///   12: "Hiciste clic en el botón una docena de veces:"
  /// ```
  ///
  /// And add to the translations, with something like:
  ///
  /// ```dart
  /// translations.translationByLocale_ByTranslationKey.addAll(
  ///   {
  ///     'Hello, welcome to this demo.': {
  ///       'en-US': 'Welcome to this demo.',
  ///       'pt-BR': 'Bem-vindo a esta demonstração.',
  ///       'es-ES': 'Bienvenido a esta demostración.',
  ///     },
  ///     'i18n Demo': {
  ///       'en-US': 'i18n Demo',
  ///       'pt-BR': 'Demonstração i18n',
  ///       'es-ES': 'Demostración i18n',
  ///     },
  ///     'Increment': {
  ///       'en-US': 'Increment',
  ///       'pt-BR': 'Incrementar',
  ///       'es-ES': 'Incrementar',
  ///     },
  ///     'Change Language': {
  ///       'en-US': 'Change Language',
  ///       'pt-BR': 'Mude Idioma',
  ///       'es-ES': 'Cambiar idioma',
  ///     },
  ///     "You clicked the button %d times:": {
  ///       "en-US": "You clicked the button %d times:",
  ///       "pt-BR": "Você clicou no botão %d vezes:",
  ///       "es-ES": "Hiciste clic en el botón %d veces:",
  ///     },
  ///   },
  /// );
  /// ```
  ///
  /// It will throw a [MissingTranslationsResourceException] if a file cannot be
  /// read from the asset bundle (which on the web is a download from the web
  /// server), and an [InvalidTranslationsResourceException] if a file is not in
  /// the valid format expected by the loader, or contains invalid translations,
  /// like values that are not Strings. Both are [TranslationsException]s that
  /// carry the `resource` that failed and the underlying `error`.
  ///
  /// However, if [failOnMissingResource] is `false`, a file that cannot be read is
  /// reported to [I18n.failedResourceCallback] and skipped, while all the other
  /// files are still loaded. Likewise, if [failOnInvalidResource] is `false`, a
  /// file that cannot be decoded, or has invalid content, is reported and skipped.
  /// A skipped failure never throws, not even when all files fail (the returned
  /// map is then simply empty).
  ///
  /// Note that since this method reads the list of files from the asset manifest,
  /// a file declared in `pubspec.yaml` is always listed. What
  /// [failOnMissingResource] handles here are files that cannot be read from the
  /// asset bundle, for example when the download fails on the web.
  ///
  Future<Map<String, Map<String, String>>> fromAssetDir(
    String dir, {
    bool failOnMissingResource = true,
    bool failOnInvalidResource = true,
  }) async {
    //
    // Load the asset manifest using the AssetManifest API.
    // See: https://api.flutter.dev/flutter/services/AssetManifest-class.html
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = assetManifest.listAssets();

    Map<String, Map<String, String>> translations = HashMap();

    final startTime = DateTime.now();

    // Add a trailing slash to the directory if it's missing, so that
    // `assets/translations` matches only the files inside that directory,
    // and not files in a sibling directory like `assets/translations_old/`.
    // An empty dir is kept as is, and matches all assets.
    final dirPrefix = (dir.isEmpty || dir.endsWith('/')) ? dir : '$dir/';

    // Filter the assets that match the directory and file extension.
    final relevantAssets = assets
        .where((path) => path.startsWith(dirPrefix) && path.endsWith(extension))
        .toList();

    // Process all matching assets in parallel. Each file is loaded and checked
    // independently, so that when a failure is allowed to be skipped, the other
    // files still load.
    await Future.wait(
      relevantAssets.map((path) async {
        try {
          await _loadAsset(path, translations, startTime);
        } on MissingTranslationsResourceException catch (error) {
          if (failOnMissingResource) rethrow;
          I18n.failedResourceCallback(path, error);
        } on InvalidTranslationsResourceException catch (error) {
          if (failOnInvalidResource) rethrow;
          I18n.failedResourceCallback(path, error);
        }
      }),
    );

    return translations;
  }

  /// Reads, decodes and checks a single asset file at [path], and then adds its
  /// translations into [translations].
  ///
  /// The translations are only added after the whole file was read, decoded and
  /// checked. This guarantees a file is either fully loaded or not loaded at all.
  ///
  Future<void> _loadAsset(
    String path,
    Map<String, Map<String, String>> translations,
    DateTime startTime,
  ) async {
    var fileName = path.split("/").last;

    print('Loading $path');

    String stringReadFromBundle;
    try {
      stringReadFromBundle = await rootBundle.loadString(path);
    } catch (error) {
      throw MissingTranslationsResourceException(path, error);
    }

    String languageTag;
    Map<String, String> checkedTranslations;
    try {
      var decoded = decodeFile(fileName, stringReadFromBundle);
      languageTag = decoded.languageTag;
      checkedTranslations = _checkTranslations(decoded.translations);
    } catch (error) {
      throw InvalidTranslationsResourceException(path, error);
    }

    _addTranslations(translations, checkedTranslations, languageTag);

    final endTime = DateTime.now();
    final loadTime = endTime.difference(startTime);
    print('Finished $path in ${loadTime.inMilliseconds} ms.');
  }

  /// The [url] must something like 'https://example.com/translations/en-US.json'.
  /// Make sure you are using https, not http.
  ///
  /// It will ignore (and not throw an error) if the file extension is not the one
  /// expected by the loader.
  ///
  /// However, if the file extension is correct, but the file is not found (a 404),
  /// or if any other network error happens, it will throw a
  /// [MissingTranslationsResourceException]. It will throw an
  /// [InvalidTranslationsResourceException] if the file is not in the valid format
  /// expected by the loader, or contains invalid translations, like values that
  /// are not Strings. Both are [TranslationsException]s that carry the `resource`
  /// that failed and the underlying `error`.
  ///
  /// However, if [failOnMissingResource] is `false`, a resource that cannot be read
  /// is reported to [I18n.failedResourceCallback], and an empty map is returned.
  /// Likewise, if [failOnInvalidResource] is `false`, a resource that cannot be
  /// decoded, or has invalid content, is reported, and an empty map is returned.
  ///
  Future<Map<String, Map<String, String>>> fromUrl(
    String url, {
    bool failOnMissingResource = true,
    bool failOnInvalidResource = true,
  }) async {
    try {
      return await _fromUrl(url);
    } on MissingTranslationsResourceException catch (error) {
      if (failOnMissingResource) rethrow;
      I18n.failedResourceCallback(url, error);
      return HashMap();
    } on InvalidTranslationsResourceException catch (error) {
      if (failOnInvalidResource) rethrow;
      I18n.failedResourceCallback(url, error);
      return HashMap();
    }
  }

  Future<Map<String, Map<String, String>>> _fromUrl(String url) async {
    //
    Map<String, Map<String, String>> translations = HashMap();

    final startTime = DateTime.now();

    if (url.endsWith(extension)) {
      //
      var path = Uri.parse(url).path;
      var fileName = url.split("/").last;
      var uri = Uri.parse(url);

      print('Loading $path');

      String stringReadFromUrl;
      try {
        stringReadFromUrl = await http.read(uri);
      } catch (error) {
        throw MissingTranslationsResourceException(url, error);
      }

      String languageTag;
      Map<String, String> checkedTranslations;
      try {
        var decoded = decodeFile(fileName, stringReadFromUrl);
        languageTag = decoded.languageTag;
        checkedTranslations = _checkTranslations(decoded.translations);
      } catch (error) {
        throw InvalidTranslationsResourceException(url, error);
      }

      _addTranslations(translations, checkedTranslations, languageTag);

      final endTime = DateTime.now();
      final loadTime = endTime.difference(startTime);
      print('Finished $path in ${loadTime.inMilliseconds} ms.');
    }

    return translations;
  }

  /// Checks the translations in [map], as decoded from a file or url, and returns
  /// them with each value encoded into a single String.
  ///
  /// Each value must be a String, or a map of versions (see [fromAssetDir]), which
  /// is encoded like the string modifiers do. Throws a [FormatException] if any
  /// value is invalid, so that the file is not loaded at all.
  ///
  static Map<String, String> _checkTranslations(Map<String, dynamic> map) {
    var translationsInFile = Map<String, dynamic>.from(map);

    Map<String, String> checkedTranslations = {};

    for (MapEntry<String, dynamic> entry in translationsInFile.entries) {
      String key = entry.key;
      dynamic value = entry.value;

      if (value is String) {
        checkedTranslations[key] = value;
      }
      //
      else if (value is Map) {
        checkedTranslations[key] = _encodeVersions(key, value);
      }
      //
      else {
        throw FormatException("Value '$value' for key '$key' is not a String.");
      }
    }

    return checkedTranslations;
  }

  /// Adds the [checkedTranslations] of a file or url (see [_checkTranslations])
  /// into [translations], for the given [languageTag].
  void _addTranslations(
    Map<String, Map<String, String>> translations,
    Map<String, String> checkedTranslations,
    String languageTag,
  ) {
    for (MapEntry<String, String> entry in checkedTranslations.entries) {
      //
      // Create a map for the key if it doesn't exist.
      translations.putIfAbsent(entry.key, () => HashMap());

      // Get the map for the key.
      Map<String, String>? translationsForKey = translations[entry.key];

      // Add a translation for the language.
      translationsForKey?[languageTag] = entry.value;
    }
  }

  /// The modifiers of the string extensions (`.zero()`, `.one()` etc.), by the
  /// name used for them in the files.
  static const _modifiersByName = {
    'zero': '0',
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'ten': 'T',
    'twoThreeFour': 'C',
    'oneOrMore': 'R',
    'zeroOne': 'F',
    'many': 'M',
  };

  /// Encodes the [versions] of the translation [key] into a single String, in the
  /// same way the string modifiers `.zero()`, `.one()`, `.times()`, `.modifier()`
  /// etc. do. See [fromAssetDir].
  ///
  /// The `other` version is required, and is the unversioned text. Throws a
  /// [FormatException] if it's missing, if a version is not a String, or if two
  /// versions mean the same, like `one` and `1`.
  ///
  static String _encodeVersions(String key, Map versions) {
    //
    String? defaultText;
    Map<String, String> textByModifier = {};
    Map<String, String> nameByModifier = {};

    for (var entry in versions.entries) {
      Object? name = entry.key;
      Object? text = entry.value;

      if (name is! String) {
        throw FormatException(
            "Key '$key' has a version named '$name', which is not a String.");
      }

      if (text is! String) {
        throw FormatException(
            "Version '$name' of key '$key' is not a String: '$text'. "
            "Each version must be text.");
      }

      if (name == 'other') {
        defaultText = text;
        continue;
      }

      String modifier = _modifierFor(name);

      String? previousName = nameByModifier[modifier];
      if (previousName != null) {
        throw FormatException(
            "Key '$key' has both the '$previousName' and the '$name' versions, "
            "which mean the same.");
      }

      nameByModifier[modifier] = name;
      textByModifier[modifier] = text;
    }

    if (defaultText == null) {
      throw FormatException(
          "Key '$key' has versions, but no 'other' version, which is the text "
          "used when no other version applies.");
    }

    String result = defaultText;
    for (var entry in textByModifier.entries) {
      result = result.modifier(entry.key, entry.value);
    }

    return result;
  }

  /// Returns the modifier for the version [name]: a plural modifier for the
  /// plural names and for integers (note the modifier for 10 is `T`, the one of
  /// `.ten()`), or the name itself, for the versions of the `version` function.
  static String _modifierFor(String name) {
    String? modifier = _modifiersByName[name];
    if (modifier != null) return modifier;

    int? number = int.tryParse(name);
    if (number != null) return (number == 10) ? 'T' : number.toString();

    return name;
  }
}
