// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

import 'package:example/1_translation_example/language_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates how to load translations from files in the assets,
/// while skipping the files that fail to load, instead of failing the whole load.
///
/// Note `MyTranslations` uses `Translations.byFile` with `failOnMissingResource: false`:
///
/// ```dart
/// extension MyTranslations on String {
///   static final _t = Translations.byFile(
///     'en-US',
///     dir: 'assets/faulty_translations',
///     failOnMissingResource: false,
///   );
///   static Future<void> load() => _t.load();
///   String get i18n => localize(this, _t);
/// }
/// ```
///
/// The translations are inside the assets/faulty_translations directory:
///
/// ```
/// assets
///   └── faulty_translations
///     ├── en-US.json
///     ├── es-ES.json  <-- deliberately broken (it's not valid JSON)
///     └── pt-BR.json
/// ```
///
/// By default (`failOnMissingResource: true`), a single broken file would fail the
/// whole load, and NO translations would be loaded at all, not even the good ones.
///
/// With `failOnMissingResource: false`, the broken `es-ES.json` file is printed to the
/// console and skipped, while `en-US.json` and `pt-BR.json` are loaded normally.
/// This means the app works in English and Portuguese, and when you switch to Spanish
/// the strings simply fall back to English (the default locale).
///
/// If ALL files fail to load, no error is thrown either, and the app simply shows the
/// default-locale strings.
///
/// Optionally, you can also customize what happens when a file fails to load, by
/// setting `I18n.failedResourceCallback`. It receives the specific file that failed,
/// plus the error. See the `main()` method below.
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: By default, files that fail to load are simply printed to the console.
  // You may replace this, for example, to report them to your crash reporting tool.
  I18n.failedResourceCallback = (resource, error) {
    print('Skipped translation file "$resource" because of: $error');
  };

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
