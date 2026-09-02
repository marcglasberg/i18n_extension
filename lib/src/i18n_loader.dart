import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:i18n_extension/i18n_extension.dart';

abstract class I18nLoader {
  //

  /// For example, for file 'en-US.json', the extension is '.json'.
  String get extension;

  /// Given [source], the text content of the asset file,
  /// returns a JSON map of translations.
  Map<String, dynamic> decode(String source);

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
  /// It will throw a [TranslationsException] if a file is not in the valid
  /// format expected by the loader, or if it cannot be read.
  ///
  /// However, if [failOnMissingResource] is `false`, a file that cannot be read or
  /// decoded is reported to [I18n.failedResourceCallback] and skipped, while all
  /// the other files are still loaded. In this case it never throws, not even
  /// when all files fail (the returned map is then simply empty).
  ///
  /// Note that since this method reads the list of files from the asset manifest,
  /// a file can't really be missing here. What [failOnMissingResource] handles
  /// in this case are files that cannot be read from the asset bundle, files that
  /// are not in the valid format expected by the loader, and files that contain
  /// translations that are not Strings.
  ///
  Future<Map<String, Map<String, String>>> fromAssetDir(
    String dir, {
    bool failOnMissingResource = true,
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
    // independently, so that when [failOnMissingResource] is false, a file that
    // fails is skipped while the other files still load.
    await Future.wait(
      relevantAssets.map((path) async {
        try {
          await _loadAsset(path, translations, startTime);
        } catch (error) {
          if (failOnMissingResource) rethrow;
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
    var languageTag = fileName.split(".")[0].asLanguageTag;

    print('Loading $path');
    var stringReadFromBundle = await rootBundle.loadString(path);

    Map<String, dynamic> map;
    try {
      map = decode(stringReadFromBundle);
    } catch (error) {
      throw TranslationsException('Error decoding $path: $error');
    }

    _addTranslations(translations, map, languageTag, path);

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
  /// However, if the file extension is correct, but the file is not found, or if any
  /// other network error happens it will throw a [TranslationsException].
  ///
  /// It will also throw a [TranslationsException] if the file is not in the valid
  /// format expected by the loader.
  ///
  /// However, if [failOnMissingResource] is `false`, it will never throw. Instead,
  /// when the resource can't be read or decoded, it's reported to
  /// [I18n.failedResourceCallback] and an empty map is returned.
  ///
  Future<Map<String, Map<String, String>>> fromUrl(
    String url, {
    bool failOnMissingResource = true,
  }) async {
    try {
      return await _fromUrl(url);
    } catch (error) {
      if (failOnMissingResource) rethrow;
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
      var languageTag = fileName.split(".")[0].asLanguageTag;
      var uri = Uri.parse(url);

      print('Loading $path');

      String stringReadFromUrl;
      try {
        stringReadFromUrl = await http.read(uri);
      } catch (error) {
        throw TranslationsException('Error reading $url: $error');
      }

      Map<String, dynamic> map;
      try {
        map = decode(stringReadFromUrl);
      } catch (error) {
        throw TranslationsException('Error decoding $url: $error');
      }

      _addTranslations(translations, map, languageTag, url);

      final endTime = DateTime.now();
      final loadTime = endTime.difference(startTime);
      print('Finished $path in ${loadTime.inMilliseconds} ms.');
    }

    return translations;
  }

  /// Adds the translations in [map] (as decoded from the file or url named
  /// [resource]) into [translations], for the given [languageTag].
  ///
  /// All values are checked before anything is written. If any value is not a
  /// String, a [TranslationsException] is thrown and [translations] is left
  /// untouched.
  ///
  void _addTranslations(
    Map<String, Map<String, String>> translations,
    Map<String, dynamic> map,
    String languageTag,
    String resource,
  ) {
    var translationsInFile = Map<String, dynamic>.from(map);

    Map<String, String> checkedTranslations = {};

    for (MapEntry<String, dynamic> entry in translationsInFile.entries) {
      String key = entry.key;
      dynamic value = entry.value;

      if (value is String) {
        checkedTranslations[key] = value;
      }
      //
      else {
        throw TranslationsException("Error in $resource: "
            "Value '$value' for key '$key' is not a String.");
      }
    }

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
}
