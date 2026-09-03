import 'dart:convert';

import 'i18n_loader.dart';

/// Loads translations from JSON files.
///
/// A file like `es-ES.json` must contain a JSON object, where each key is a
/// translation key, and each value is its translation:
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
/// A translation may also be an object with its versions, like plurals and
/// genders, which works like the string modifiers `.zero()`, `.one()`,
/// `.times()`, `.modifier()` etc. The `other` version is the text used when no
/// other version applies, and is required. An integer version, like `12`, is the
/// same as `.times(12)`:
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
/// See [I18nLoader.fromAssetDir] for the names of all the versions.
///
class I18nJsonLoader extends I18nLoader {
  //
  @override
  String get extension => '.json';

  /// Decodes the [source] text of a JSON file. The values, which may be Strings
  /// or maps of versions, are checked and encoded when the translations are added.
  @override
  Map<String, dynamic> decode(String source) => json.decode(source);
}
