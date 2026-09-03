// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension MyTranslations on String {
  //
  static final _t = Translations.byFile(
    'en-US',
    dir: 'assets/faulty_translations',
    // The `es-ES.json` file in that directory is deliberately broken.
    // With `failOnInvalidResource: false`, it's logged and skipped,
    // while the other files are still loaded.
    failOnInvalidResource: false,
  );

  static Future<void> load() => _t.load();

  String get i18n => localize(this, _t);

  String plural(value) => localizePlural(value, this, _t);
}
