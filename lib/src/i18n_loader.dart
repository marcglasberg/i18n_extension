import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
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
  Future<Map<String, Map<String, String>>> fromAssetDir(String dir) async {
    //
    // The manifest file lists all the assets in the assets directory.
    String manifestContent = await rootBundle.loadString("AssetManifest.json");
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    Map<String, Map<String, String>> translations = HashMap();

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
      }
    }

    return translations;
  }
}
