// Developed by Marcelo Glasberg (2026) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

/// This example demonstrates how to combine the gender and plural modifiers, so that
/// a single text depends on both the gender and the number of people.
///
/// Choose the gender with the radio buttons, and the number of people with the `+`
/// and `-` buttons, and the text changes accordingly. The "Change language" button
/// cycles through English, Spanish and Portuguese.
///
/// The translations, in the [Localization] extension at the end of this file,
/// declare all the combinations by nesting the plural modifiers (`.zero()`,
/// `.many()` etc.) inside the gender modifiers (`.male()` and `.female()`).
/// The text is then translated with `.plural(count, gender)`.
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    I18n(
      initialLocale: await I18n.loadLocale(),
      autoSaveLocale: true,
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('es', 'ES'),
        const Locale('pt', 'BR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: const AppCore(),
    ),
  );
}

class AppCore extends StatelessWidget {
  const AppCore({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: I18n.locale,
        localizationsDelegates: I18n.localizationsDelegates,
        supportedLocales: I18n.supportedLocales,
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Gender gender = Gender.neutral;
  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gender and plural'.i18n), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _translatedText(),
              const SizedBox(height: 40),
              _genderRadios(),
              const SizedBox(height: 20),
              _counter(),
              const SizedBox(height: 40),
              _changeLanguageButton(),
              _localeLabel(),
            ],
          ),
        ),
      ),
    );
  }

  /// The single translated text, which depends on both the gender and the number.
  Widget _translatedText() {
    return Text(
      'There is a person'.plural(count, gender),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  Widget _genderRadios() {
    return RadioGroup<Gender>(
      groupValue: gender,
      onChanged: (value) => setState(() => gender = value!),
      child: Column(
        children: [
          RadioListTile<Gender>(value: Gender.male, title: Text('Male'.i18n)),
          RadioListTile<Gender>(value: Gender.female, title: Text('Female'.i18n)),
          RadioListTile<Gender>(value: Gender.neutral, title: Text('Neutral'.i18n)),
        ],
      ),
    );
  }

  Widget _counter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: (count > 0) ? () => setState(() => count--) : null,
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('$count', style: const TextStyle(fontSize: 26)),
        ),
        IconButton.filled(
          onPressed: () => setState(() => count++),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _changeLanguageButton() {
    return MaterialButton(
      color: Colors.blue,
      onPressed: _onChangeLanguage,
      child: Text(
        'Change language'.i18n,
        style: const TextStyle(color: Colors.white, fontSize: 17),
      ),
    );
  }

  Widget _localeLabel() {
    return Text(
      'Locale: ${I18n.languageTag}',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: Colors.grey),
    );
  }

  /// English, then Spanish, then Portuguese, then English again.
  void _onChangeLanguage() {
    String next = (I18n.languageTag == 'en-US')
        ? 'es-ES'
        : (I18n.languageTag == 'es-ES')
            ? 'pt-BR'
            : 'en-US';

    I18n.of(context).locale = next.asLocale;
  }
}

/// The translations. Note how the plural modifiers are nested inside the gender
/// modifiers, to declare all the combinations of gender and number.
///
/// Only the combinations that differ need to be declared: the plural versions of the
/// given gender are tried first, then the gender version itself (which is the singular,
/// for 1 element), then the plural versions that don't depend on the gender, and
/// finally the unversioned text.
///
extension Localization on String {
  //
  static final _t = Translations.byText('en-US') +
      {
        'en-US': 'There is a person'
            .zero('There is nobody')
            .many('There are %d people')
            .male('There is a man'.zero('There are no men').many('There are %d men'))
            .female('There is a woman'.zero('There are no women').many('There are %d women')),
        'es-ES': 'Hay una persona'
            .zero('No hay nadie')
            .many('Hay %d personas')
            .male('Hay un hombre'.zero('No hay hombres').many('Hay %d hombres'))
            .female('Hay una mujer'.zero('No hay mujeres').many('Hay %d mujeres')),
        'pt-BR': 'Há uma pessoa'
            .zero('Não há ninguém')
            .many('Há %d pessoas')
            .male('Há um homem'.zero('Não há homens').many('Há %d homens'))
            .female('Há uma mulher'.zero('Não há mulheres').many('Há %d mulheres')),
      } +
      {
        'en-US': 'Gender and plural',
        'es-ES': 'Género y plural',
        'pt-BR': 'Gênero e plural',
      } +
      {
        'en-US': 'Male',
        'es-ES': 'Masculino',
        'pt-BR': 'Masculino',
      } +
      {
        'en-US': 'Female',
        'es-ES': 'Femenino',
        'pt-BR': 'Feminino',
      } +
      {
        'en-US': 'Neutral',
        'es-ES': 'Neutro',
        'pt-BR': 'Neutro',
      } +
      {
        'en-US': 'Change language',
        'es-ES': 'Cambiar idioma',
        'pt-BR': 'Mudar idioma',
      };

  String get i18n => localize(this, _t);

  String plural(Object? value, [Gender? gender]) =>
      localizePlural(value, this, _t, gender: gender);
}
