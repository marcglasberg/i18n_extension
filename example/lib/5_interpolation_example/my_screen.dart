// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'my.i18n.dart';
import 'my_widget.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late int counter;

  @override
  void initState() {
    super.initState();
    counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyWidget(),
            space20,
            _changeLanguageButton(),
            _localeLabel(),
          ],
        ),
      ),
    );
  }

  MaterialButton _changeLanguageButton() {
    return MaterialButton(
      color: Colors.blue,
      onPressed: _onChangeLanguage,
      child: Text(
        changeLanguage.i18n,
        style: const TextStyle(color: Colors.white, fontSize: 17),
      ),
    );
  }

  Text _localeLabel() {
    return Text(
      "Locale: ${I18n.languageTag}",
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: Colors.grey),
    );
  }

  /// English, them Spanish, then Portuguese, then English again.
  void _onChangeLanguage() {
    //
    String next = (I18n.languageTag == "en-US")
        ? 'es-ES'
        : (I18n.languageTag == "es-ES")
            ? 'pt-BR'
            : 'en-US';

    I18n.of(context).locale = next.asLocale;
  }
}
