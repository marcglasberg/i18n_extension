import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //
  static var t = Translations("en_us") +
      {
        "en_us": "i18n Demo",
        "pt_br": "Demonstração i18n",
      };

  String get i18n => localize(this, t);

  String number(int value) => localizeNumber(value, this, t);

  String version(Object modifier) => localizeVersion(modifier, this, t);

  Map<String, String> allVersions() => localizeAllVersions(this, t);
}
