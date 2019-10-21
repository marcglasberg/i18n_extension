import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'main.i18n.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MyHomePage());
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return I18n(
      locale: Locale("pt_br"),
      child: Scaffold(
        appBar: AppBar(title: Text("i18n Demo")),
        body: Container(
          color: Colors.black,
          child: Center(
            child: Text(
              "Hi".i18n,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
