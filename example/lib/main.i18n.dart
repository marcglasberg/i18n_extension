import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //
  static var t = Translations("en_us") +
      {
        "cs_cz": "Zdravím tě",
        "en_us": "Hi",
        "en_uk": "Hi",
        "pt_br": "Olá",
        "es": "Hola",
      } +
      {
        "en_us": "Goodbye",
        "pt_br": "Adeus",
        "cs_cz": "Sbohem",
        "en_uk": "Goodbye",
        "es": "Adiós",
      };

  String get i18n => localize(this, t);
}
