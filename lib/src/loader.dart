import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_extension.dart';

abstract class Loader {
  //

  /// For example, for file 'en-US.json', the extension is '.json'.
  String get extension;

  /// Given [source], the text content of the asset file,
  /// returns a JSON map of translations.
  Map<String, dynamic> decode(String source);

  /// load a file, like `es-ES.json`, containing something like:
  ///
  /// ```json
  /// {
  ///   "Welcome to this demo.": "Bienvenido a esta demostración.",
  ///   "i18n Demo": "Demostración i18n",
  ///   "Increment": "Incrementar",
  ///   "Change Language": "Cambiar idioma",
  ///   "You clicked the button %d times:": "Hiciste clic en el botón %d veces:"
  /// }
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
    String manifestContent = await rootBundle.loadString("AssetManifest.json");
    Map<String, dynamic> manifestMap = decode(manifestContent);

    Map<String, Map<String, String>> translations = HashMap();

    for (String path in manifestMap.keys) {
      if (!path.startsWith(dir)) continue;

      var fileName = path.split("/").last;

      if (!fileName.endsWith(extension)) {
        throw TranslationsException("Ignoring '$path' which is not a $extension file.");
      }

      var languageTag = fileName.split(".")[0].asLanguageTag;

      var stringReadFromBundle = await rootBundle.loadString(path);

      var translationsInFile =
          Map<String, dynamic>.from(json.decode(stringReadFromBundle));

      for (MapEntry<String, dynamic> entry in translationsInFile.entries) {
        String key = entry.key;
        dynamic value = entry.value;
        if (value is String) {
          translations.putIfAbsent(key, () => HashMap())[languageTag] = value;
        } else
          throw TranslationsException("Value for key '$key' in '$path' is not a String.");
      }
    }

    return translations;
  }
}
