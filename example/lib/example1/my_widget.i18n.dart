// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //
  static final _t = Translations.byText("en_us") +
      {
        "en_us": "Hello, welcome to this internationalization demo.",
        "pt_br": "Olá, bem-vindo a esta demonstração de internacionalização.",
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);

  Map<String?, String> allVersions() => localizeAllVersions(this, _t);
}
