// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

import 'package:example/1_translation_example/language_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates how to load translations from a file in the assets.
///
/// Note `MyTranslations` uses `Translations.byFile`:
///
/// ```dart
/// extension MyTranslations on String {
///   static final _t = Translations.byFile('en-US', dir: 'assets/translations');
///   static Future<void> load() => _t.load();
///   String get i18n => localize(this, _t);
/// }
/// ```
///
/// The translations are inside the assets/translations directory:
///
/// ```
/// assets
///   └── translations
///     ├── en-US.json
///     ├── en-US.po
///     ├── es.po
///     ├── pt-BR.json
///     └── more_translations
///         ├── en-US.json
///         └── es-ES.json
/// ```
///
/// Notice that `Translations.byFile('en-US', dir: 'assets/translations')` will
/// load all files in that directory and its subdirectories that end with
/// `.json` or `.po`. Since `en-US.json` exists in both directories
/// (assets/translations and assets/translations/more_translations) , the
/// translations will be merged. 
///
/// In pubspec.yaml, however, you must declare both directories separately:
///
/// ```yaml
/// flutter:
///   assets:
///     - assets/translations/
///     - assets/translations/more_translations/
/// ```
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preloading the translations here is recommended but optional. If you remove this
  // line, the translations will be loaded automatically anyway later, but this may cause
  // a visible flicker when the widget rebuilds with the new translations.
  await MyTranslations.load();

  runApp(
    I18n(
      initialLocale: await I18n.loadLocale(),
      autoSaveLocale: true,
      supportedLocales: [
        const Locale('en', 'US'), // Could also be 'en-US'.asLocale,
        const Locale('pt', 'BR'), // Could also be 'pt-BR'.asLocale,
        const Locale('es', 'ES'), // Could also be 'es-ES'.asLocale,
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: AppCore(),
    ),
  );
}

class AppCore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: I18n.locale,
      localizationsDelegates: I18n.localizationsDelegates,
      supportedLocales: I18n.supportedLocales,
      home: MyHomePage(),
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("i18n Demo".i18n),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: MyScreen(),
    );
  }
}
