// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

final appbarTitle = Object();
final greetings = Object();
final increment = Object();
final changeLanguage = Object();
final youClickedThisNumberOfTimes = Object();

extension MyLocalization on Object {
  //

  /// If you want to use identifiers as translation keys, you can define the keys
  /// using any unique object, and then use the [Translations.byId] constructor:
  ///
  static final _t = Translations.byId("en-US", {
    appbarTitle: {
      "en-US": "i18n Demo",
      "pt-BR": "Demonstração i18n",
    },
    greetings: {
      "en-US": "This example demonstrates how to use identifiers as keys.\n\n"
          "For example, you can declare:\n"
          "final greetings = UniqueKey();\n"
          "and then write:\n"
          "Text(greetings.i18n);\n",
      "pt-BR": "Este exemplo demonstra como usar identificadores como chaves.\n\n"
          "Por exemplo, você pode declarar:\n"
          "final greetings = UniqueKey();\n"
          "e daí escrever:\n"
          "Text(greetings.i18n);\n",
    },
    increment: {
      "en-US": "Increment",
      "pt-BR": "Incrementar",
    },
    changeLanguage: {
      "en-US": "Change Language",
      "pt-BR": "Mude Idioma",
    },
    youClickedThisNumberOfTimes: {
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
    }
  });

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);
}
