// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //
  /// Note you may also define this as a static const,
  /// if you use the [Translations.from] constructor:
  ///
  /// ```
  /// static const _t = Translations.from(
  ///   "en_us", {
  ///     "i18n Demo": {
  ///       "en_us": "i18n Demo",
  ///       "pt_br": "Demonstração i18n",
  ///     }});
  /// ```
  ///
  static final _t = Translations("en_us") +
      const {
        "en_us": "i18n Demo",
        "pt_br": "Demonstração i18n",
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);
}
