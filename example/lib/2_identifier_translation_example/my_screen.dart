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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(flex: 2),
          MyWidget(),
          const Spacer(),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              youClickedThisNumberOfTimes.plural(counter),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
          ),
          MaterialButton(
            color: Colors.blue,
            child: Text(
              increment.i18n,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            onPressed: _increment,
          ),
          const Spacer(),
          MaterialButton(
            color: Colors.blue,
            child: Text(
              changeLanguage.i18n,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            onPressed: _onPressed,
          ),
          Text(
            "Locale: ${I18n.languageTag}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  void _onPressed() =>
      I18n.of(context).locale = (I18n.languageTag == 'pt-BR') ? null : 'pt-BR'.asLocale;

  void _increment() => setState(() => counter++);
}
