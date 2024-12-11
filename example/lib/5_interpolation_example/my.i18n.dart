// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';

final appbarTitle = Object();
final changeLanguage = Object();
final greetings1 = Object();
final greetings2 = Object();
final greetings3 = Object();
final greetings4 = Object();
final greetings5 = Object();
final greetings6 = Object();
final greetings7 = Object();
final greetings8 = Object();

extension MyLocalization on Object {
  //

  /// If you want to use identifiers as translation keys, you can define the keys
  /// using any unique object, and then use the [Translations.byId] constructor:
  ///
  static final _t = Translations.byId("en-US", {
    appbarTitle: {
      'en-US': 'Interpolation Examples',
      'es-ES': 'Ejemplos de interpolación',
      'pt-BR': 'Exemplos de interpolação',
    },
    changeLanguage: {
      "en-US": "Change Language",
      "pt-BR": "Mude Idioma",
    },
    greetings1: {
      'en-US': 'Hi, {} and {}',
      'es-ES': 'Hola, {} y {}',
      'pt-BR': 'Olá, {} e {}',
    },
    greetings2: {
      'en-US': 'Hi, {1} and {2}',
      'es-ES': 'Hola, {1} y {2}',
      'pt-BR': 'Olá, {1} e {2}',
    },
    greetings3: {
      'en-US': 'Hi, {2} and {1}',
      'es-ES': 'Hola, {2} y {1}',
      'pt-BR': 'Olá, {2} e {1}',
    },
    greetings4: {
      'en-US': 'Hi, {name} and {other}',
      'es-ES': 'Hola, {name} y {other}',
      'pt-BR': 'Olá, {name} e {other}',
    },
    greetings5: {
      'en-US': 'Hello {name}, let’s meet up with {} and {other} to explore {1} and {2}.',
      'es-ES': 'Hola {name}, reunámonos con {} y {other} para explorar {1} y {2}.',
      'pt-BR': 'Olá {name}, vamos nos encontrar com {} e {other} para explorar {1} e {2}.',
    },
    greetings6: {
      'en-US': 'Hi, %s and %s',
      'es-ES': 'Hola, %s y %s',
      'pt-BR': 'Olá, %s e %s',
    },
    greetings7: {
      'en-US': 'Hi, %1\$s and %2\$s',
      'es-ES': 'Hola, %1\$s y %2\$s',
      'pt-BR': 'Olá, %1\$s e %2\$s',
    },
    greetings8: {
      'en-US': 'Hi, %2\$s and %1\$s',
      'es-ES': 'Hola, %2\$s y %1\$s',
      'pt-BR': 'Olá, %2\$s e %1\$s',
    },
  });

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(value) => localizePlural(value, this, _t);
}
