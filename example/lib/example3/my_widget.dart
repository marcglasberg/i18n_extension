// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';

import 'my_widget.i18n.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      height: 100,
      color: Colors.grey[300],
      child: Text(
        "Hello, welcome to this internationalization demo.".i18n,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
