import 'package:flutter/material.dart';

import 'my.i18n.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      height: 200,
      color: Colors.grey[300],
      child: Text(
        greetings.i18n,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
