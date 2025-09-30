// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

import 'package:example/1_translation_example/language_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates how to MANUALLY load translations from a file
/// in the assets. You start by creating a translations object with:
/// 
/// ```dart
/// static Translations translations = Translations.byLocale('en-US');
/// ```
///
/// And then loading other translation files and adding them:
///
/// ```dart
/// Translations _t = Translations.byFile('en-US', dir: 'assets/translations');
/// await _t.load();
/// translations *= _t;
/// ```
///
/// The above code is in file
/// `i18n_extension/example/lib/8_manually_loading_files_example/main.i18n.dart`.
///
/// IMPORTANT: This is NOT the recommended way to load translation files,
/// because i18n_extension already provides an easier way to do this.
/// Check `i18n_extension/example/lib/6_load_by_file_example` for
/// the recommended way to load translations from files in the assets.
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preloading the translations here is recommended but optional. If you remove this
  // line, the translations will be loaded automatically anyway later, but this may cause
  // a visible flicker when the widget rebuilds with the new translations.
  await MyTranslations.load(['assets/translations']);

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
