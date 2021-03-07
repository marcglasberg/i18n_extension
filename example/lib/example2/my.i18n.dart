import 'package:i18n_extension/i18n_extension.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

const appbarTitle = "appbarTitle";
const greetings = "greetings";
const increment = "increment";
const changeLanguage = "changeLanguage";
const youClickedThisNumberOfTimes = "youClickedThisNumberOfTimes";

extension Localization on String {
  //
  /// If you want to use identifiers as translation keys, you can define the
  /// keys here in the translations file, and then use the [Translations.from]
  /// constructor:
  ///
  static final _t = Translations.from("en_us", {
    appbarTitle: {
      "en_us": "i18n Demo",
      "pt_br": "Demonstração i18n",
    },
    greetings: {
      "en_us": "This example demonstrates how to use identifiers as keys.\n\n"
          "For example, you can write:\n"
          "helloThere.i18n\n"
          "instead of\n"
          "\"Hello There\".i18n",
      "pt_br": "Este exemplo demonstra como usar identificadores como chaves.\n\n"
          "Por exemplo, você pode escrever:\n"
          "saudacao.i18n\n"
          "em vez de\n"
          "\"Olá como vai\".i18n",
    },
    increment: {
      "en_us": "Increment",
      "pt_br": "Incrementar",
    },
    changeLanguage: {
      "en_us": "Change Language",
      "pt_br": "Mude Idioma",
    },
    youClickedThisNumberOfTimes: {
      "en_us": "You clicked the button %d times:"
          .zero("You haven't clicked the button:")
          .one("You clicked it once:")
          .two("You clicked a couple times:")
          .many("You clicked %d times:")
          .times(12, "You clicked a dozen times:"),
      "pt_br": "Você clicou o botão %d vezes:"
          .zero("Você não clicou no botão:")
          .one("Você clicou uma única vez:")
          .two("Você clicou um par de vezes:")
          .many("Você clicou %d vezes:")
          .times(12, "Você clicou uma dúzia de vezes:"),
    }
  });

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, _t);
}
