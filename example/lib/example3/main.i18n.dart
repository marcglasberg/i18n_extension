// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //

  /// Note you could also define the translation as const value,
  /// by using [ConstTranslations] instead of [Translations].
  ///
  /// ```
  /// static const _t2 = ConstTranslations(
  ///   "en_us",
  ///   {
  ///     "i18n Demo": {
  ///       "en_us": "i18n Demo",
  ///       "pt_br": "Demonstração i18n",
  ///     }
  ///   },
  /// );
  /// ```
  ///
  static final _t = Translations.byText("en_us") +
      const {
        "en_us": "i18n Demo",
        "pt_br": "Demonstração i18n",
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);
}
