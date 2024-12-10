// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';

import 'my.i18n.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      height: 410,
      color: Colors.grey[300],
      child: Text(
        MyScope.greetings.i18n,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
