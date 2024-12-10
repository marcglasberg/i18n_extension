// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

const appbarTitle = 'appbarTitle';
const greetings = 'greetings';
const increment = 'increment';
const changeLanguage = 'changeLanguage';
const youClickedThisNumberOfTimes = 'youClickedThisNumberOfTimes';

extension Localization on String {
  //
  /// This shows how to use identifiers as translation keys, defined as constants,
  /// using a the [ConstTranslations] constructor:
  ///
  static const _t = ConstTranslations("en-US", {
    appbarTitle: {
      "en-US": "i18n Demo",
      "pt-BR": "Demonstração i18n",
    },
    greetings: {
      "en-US": "This example demonstrates how to use the ConstTranslations constructor.",
      "pt-BR": "Este exemplo demonstra como usar o construtor ConstTranslations.",
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
      "en-US": "You clicked the button %d times:",
      "pt-BR": "Você clicou o botão %d vezes:",
    },
    //
    // This will work in future versions:
    // youClickedThisNumberOfTimes: {
    //   "en-US": {
    //     '': "You clicked the button %d times:",
    //     'zero': "You haven't clicked the button:",
    //     'one': "You clicked it once:",
    //     'two': "You clicked a couple times:",
    //     'many': "You clicked %d times:",
    //     12: "You clicked a dozen times:",
    //   },
    //   "pt-BR": {
    //     '': "Você clicou o botão %d vezes:",
    //     'zero': "Você não clicou no botão:",
    //     'one': "Você clicou uma única vez:",
    //     'two': "Você clicou um par de vezes:",
    //     'many': "Você clicou %d vezes:",
    //     12: "Você clicou uma dúzia de vezes:",
    //   }
    // },
  });

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);
}
