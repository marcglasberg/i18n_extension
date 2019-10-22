import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'main.i18n.dart';
import 'my_screen.dart';

void main() => runApp(MyApp());

////////////////////////////////////////////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return I18n(
      // You can provide an initialLocale, but usually just let it use the system locale.
      // initialLocale: Locale("pt_BR"),
      child: Scaffold(
        appBar: AppBar(title: Text("i18n Demo".i18n)),
        body: MyScreen(),
      ),
    );
  }
}
