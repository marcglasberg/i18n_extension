import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

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
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', "US"),
          const Locale('pt', "BR"),
        ],
        home: I18n(
          // Usually you should not provide an initialLocale,
          // and just let it use the system locale.
          // initialLocale: Locale("pt", "BR"),
          //
          child: MyHomePage(),
        ),
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
      appBar: AppBar(title: Text("i18n Demo".i18n)),
      body: MyScreen(),
    );
  }
}
