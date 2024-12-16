import 'dart:convert';

import 'i18n_loader.dart';

class I18nJsonLoader extends I18nLoader {
  //
  @override
  String get extension => '.json';

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
  @override
  Map<String, dynamic> decode(String source) => json.decode(source);
}
