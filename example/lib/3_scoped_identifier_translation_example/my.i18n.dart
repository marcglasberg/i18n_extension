// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

extension MyLocalization on Object {
  //
  static final _t = MyScope._t * OtherScope._t;

  String get i18n => localize(this, _t);

  String plural(value) => localizePlural(value, this, _t);
}

class MyScope {
  static final appbarTitle = Object();
  static final greetings = Object();

  static final _t = Translations.byId("en-US", {
    appbarTitle: {
      "en-US": "i18n Demo",
      "pt-BR": "Demonstração i18n",
    },
    greetings: {
      "en-US": "This example demonstrates how to define SCOPED identifiers, "
          "to use them as translation keys.\n\n"
          "For example, you can declare:\n\n"
          "  class MyScope {\n"
          "    static final greetings = Object();\n"
          "  }\n\n"
          "and then write:\n\n"
          "  Text(MyScope.greetings.i18n);\n",
      "pt-BR": "Este exemplo demonstra como definir identificadores escopados, "
          "para usá-los como chaves de tradução.\n\n"
          "Por exemplo, você pode declarar:\n\n"
          "class MyScope {\n"
          "  static final greetings = Object();\n"
          "}\n\n"
          "e então escrever:\n\n"
          "  Text(MyScope.greetings.i18n);\n",
    },
  });
}

class OtherScope {
  static final increment = Object();
  static final changeLanguage = Object();
  static final youClickedThisNumberOfTimes = Object();

  static final _t = Translations.byId("en-US", {
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
      "pt-BR": "Você clicou no botão %d vezes:"
          .zero("Você não clicou no botão:")
          .one("Você clicou uma única vez:")
          .two("Você clicou um par de vezes:")
          .many("Você clicou %d vezes:")
          .times(12, "Você clicou uma dúzia de vezes:"),
    }
  });
}
