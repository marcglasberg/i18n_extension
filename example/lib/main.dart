import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: I18n(
          // Usually you should not provide and initialLocale,
          // and just let it use the system locale.
          // initialLocale: Locale("pt_BR"),
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
