// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:example/1_translation_example/language_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates basic translations using a `I18n` widget.
///
/// There are 3 widget files that need translations:
/// * main.dart
/// * my_screen.dart
/// * my_widget.dart
///
/// And there is one translations-file for each one:
/// * main.i18n.dart
/// * my_screen.i18n.dart
/// * my_widget.i18n.dart
///
/// Note: We could have put all translations into a single translations-file
/// that would be used by all widget files. It's up to you how to organize
/// things.
///
/// Note: The translations-files in this example use strings as keys.
/// For example:
///
///     "You clicked the button %d times:".plural(counter),
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    I18n(
      initialLocale: await I18n.loadLocale(),
      autoSaveLocale: true,
      child: MyMaterialApp(),
    ),
  );
}

class MyMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// The initial locale for this app's [Localizations] widget is based on this
      /// value. If the 'locale' is null then the system's locale value is used.
      /// The value of [Localizations.locale] will equal this locale if it matches one
      /// of the [supportedLocales]. Otherwise it will be the first [supportedLocales].
      // locale: I18n.of(context).locale,
      locale: I18n.locale,
      //
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('pt', 'BR'),
        const Locale('es', 'ES'),
      ],
      home: Container(
        //
        child: MyHomePage(),
      ),
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
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
