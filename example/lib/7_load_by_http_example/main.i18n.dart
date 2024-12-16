// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension MyTranslations on String {
  //
  static final _t = Translations.byHttp(
    'en-US',
    url: 'https://raw.githubusercontent.com/marcglasberg/'
        'i18n_extension/refs/heads/master/example/assets/translations/',
    resources: [
      'en-US.json',
      'es-ES.json',
      'pt-BR.json',
      'en-US.po',
      'es.po',
    ],
  );

  static Future<void> load() => _t.load();

  String get i18n => localize(this, _t);

  String plural(value) => localizePlural(value, this, _t);
}
