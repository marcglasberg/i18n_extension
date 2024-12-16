import 'dart:collection';
import 'dart:convert';

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

  /// load files like `es-ES.json`, containing something like:
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
  ///       "pt-BR": "Você clicou o botão %d vezes:",
  ///       "es-ES": "Hiciste clic en el botón %d veces:",
  ///     },
  ///   },
  /// );
  /// ```
  ///
  /// It will throw a [TranslationsException] if the file is not in the valid
  /// format expected by the loader.
  ///
  Future<Map<String, Map<String, String>>> fromAssetDir(String dir) async {
    //
    // The manifest file lists all the assets in the assets directory.
    String manifestContent = await rootBundle.loadString("AssetManifest.json");
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    Map<String, Map<String, String>> translations = HashMap();

    final startTime = DateTime.now();

    for (String path in manifestMap.keys) {
      //
      if (!path.startsWith(dir)) continue;

      if (path.endsWith(extension)) {
        //
        var fileName = path.split("/").last;
        var languageTag = fileName.split(".")[0].asLanguageTag;
        var stringReadFromBundle = await rootBundle.loadString(path);

        print('Loading $path');

        Map<String, dynamic> map;
        try {
          map = decode(stringReadFromBundle);
        } catch (error) {
          throw TranslationsException('Error decoding $path: $error');
        }

        var translationsInFile = Map<String, dynamic>.from(map);

        for (MapEntry<String, dynamic> entry in translationsInFile.entries) {
          String key = entry.key;
          dynamic value = entry.value;

          if (value is String) {
            //
            // Create a map for the key if it doesn't exist.
            translations.putIfAbsent(key, () => HashMap());

            // Get the map for the key.
            Map<String, String>? translationsForKey = translations[key];

            // Add a translation for the language.
            translationsForKey?[languageTag] = value;
          }
          //
          else
            throw TranslationsException("Error in $path: "
                "Value '$value' for key '$key' is not a String.");
        }

        final endTime = DateTime.now();
        final loadTime = endTime.difference(startTime);
        print('Finished $path in ${loadTime.inMilliseconds} ms.');
      }
    }

    return translations;
  }

  /// The [url] must something like 'https://example.com/translations/en-US.json'.
  /// Make sure you are using https, not http.
  ///
  /// It will ignore (and not throw an error) if the file extension os not the one
  /// expected by the loader.
  ///
  /// However, if the file extension is correct, but the file is not found, or if any
  /// other network error happens it will throw a [TranslationsException].
  ///
  /// It will also throw a [TranslationsException] if the file is not in the valid
  /// format expected by the loader.
  ///
  Future<Map<String, Map<String, String>>> fromUrl(String url) async {
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

      var translationsInFile = Map<String, dynamic>.from(map);

      for (MapEntry<String, dynamic> entry in translationsInFile.entries) {
        String key = entry.key;
        dynamic value = entry.value;

        if (value is String) {
          //
          // Create a map for the key if it doesn't exist.
          translations.putIfAbsent(key, () => HashMap());

          // Get the map for the key.
          Map<String, String>? translationsForKey = translations[key];

          // Add a translation for the language.
          translationsForKey?[languageTag] = value;
        }
        //
        else
          throw TranslationsException("Error in $url: "
              "Value '$value' for key '$key' is not a String.");
      }

      final endTime = DateTime.now();
      final loadTime = endTime.difference(startTime);
      print('Finished $path in ${loadTime.inMilliseconds} ms.');
    }

    return translations;
  }
}
