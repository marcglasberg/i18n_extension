// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'my.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates using identifiers as translation keys.
///
/// There are 3 widget files that need translations:
/// * main.dart
/// * my_screen.dart
/// * my_widget.dart
///
/// We'll be using a single translations-file for all of them:
/// * my.i18n.dart
///
/// The translations-files in this example use the following identifiers
/// as translation keys:
///
/// [appbarTitle], [greetings], [increment], [changeLanguage],
/// and [youClickedThisNumberOfTimes].
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    I18n(
      initialLocale: await I18n.loadLocale(),
      autoSaveLocale: true,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // Could also be 'en-US'.asLocale,
        const Locale('pt', 'BR'), // Could also be 'pt-BR'.asLocale,
      ],
      child: AppCore(),
    ),
  );
}

class AppCore extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: I18n.locale,
        localizationsDelegates: I18n.localizationsDelegates,
        supportedLocales: I18n.supportedLocales,
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appbarTitle.i18n), backgroundColor: Colors.blue),
      body: MyScreen(),
    );
  }
}
