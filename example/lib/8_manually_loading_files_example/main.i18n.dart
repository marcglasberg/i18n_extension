// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension MyTranslations on String {
  static Translations translations = Translations.byLocale('en-US');

  static bool initialized = false;

  static Future<void> load(List<String> dirs) async {
    assert(!initialized);

    for (String dir in dirs) {
      Translations _t = Translations.byFile('en-US', dir: dir);
      await _t.load();
      translations *= _t;
    }

    initialized = true;
  }

  String get i18n => localize(this, translations);

  String plural(value) => localizePlural(value, this, translations);
}
