// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  //
  static final _t = Translations.byText("en-US") +
      {
        "en-US": "Increment",
        "pt-BR": "Incrementar",
      } +
      {
        "en-US": "Change Language",
        "pt-BR": "Mude Idioma",
      } +
      {
        "en-US": "You clicked the button %d times:"
            .zero("You haven't clicked the button:")
            .one("You clicked it once:")
            .two("You clicked a couple times:")
            .many("You clicked %d times:")
            .times(12, "You clicked a dozen times:"),
        "pt-BR": "Você clicou o botão %d vezes:"
            .zero("Você não clicou no botão:")
            .one("Você clicou uma única vez:")
            .two("Você clicou um par de vezes:")
            .many("Você clicou %d vezes:")
            .times(12, "Você clicou uma dúzia de vezes:"),
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);

  Map<String?, String> allVersions() => localizeAllVersions(this, _t);
}
