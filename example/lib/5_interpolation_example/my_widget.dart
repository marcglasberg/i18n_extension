// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';
import 'package:i18n_extension/default.i18n.dart';

import 'my.i18n.dart';

const Widget space12 = SizedBox(width: 12, height: 12);
const Widget space20 = SizedBox(width: 20, height: 20);
final Widget divider = Container(width: double.infinity, height: 2, color: Colors.grey);
const title = TextStyle(fontSize: 14.0);
const comment = TextStyle(fontSize: 17.0, color: Colors.grey);
const body = TextStyle(fontSize: 20.0);

class MyWidget extends StatelessWidget {
  //
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[300],
      child: Column(
        children: [
          //
          const Text('Interpolation with naked placeholders', style: title),
          const Text('{} and {}', style: title),
          space20,
          Text(greetings1.i18n.args('Alice', 'Bob'), style: body),
          Text("'" + greetings1.i18n + "'.i18n.args('Alice', 'Bob')", style: comment),
          space20,
          Text(greetings1.i18n.args('Alice', 'Bob'), style: body),
          Text("'" + greetings1.i18n + "'.i18n.args(['Alice', 'Bob'])", style: comment),
          space20,
          //
          divider,
          space12,
          //
          const Text('Interpolation with indexed placeholders', style: title),
          const Text('{1} and {2}', style: title),
          space20,
          //
          Text(greetings2.i18n.args({1: 'Alice', 2: 'Bob'}), style: body),
          Text("'" + greetings2.i18n + "'.i18n.args({1: 'Alice', 2: 'Bob'})",
              style: comment),
          space20,
          //
          Text(greetings3.i18n.args({1: 'Alice', 2: 'Bob'}), style: body),
          Text("'" + greetings3.i18n + "'.i18n.args({1: 'Alice', 2: 'Bob'})",
              style: comment),
          space20,
          //
          divider,
          space12,
          //
          const Text('Interpolation with named placeholders', style: title),
          const Text('{name} and {other}', style: title),
          space20,
          Text(greetings4.i18n.args({'name': 'Alice', 'other': 'Bob'}), style: body),
          Text("'" + greetings4.i18n + "'.i18n\n.args({'name': 'Alice', 'other': 'Bob'})",
              style: comment),
          space20,
          Text(greetings4.i18n.args({'other': 'Alice', 'name': 'Bob'}), style: body),
          Text("'" + greetings4.i18n + "'.i18n\n.args({'other': 'Alice', 'name': 'Bob'})",
              style: comment),
          space20,
          //
          divider,
          space12,
          //
          const Text('Mixed interpolation', style: title),
          const Text('{}, {name}, {other}, {1} and {2}, ', style: title),
          space20,
          Text(
              greetings5.i18n.args('Charlie', {'name': 'Alice', 'other': 'Bob'},
                  {1: 'Paris', 2: 'London'}),
              style: body),
          Text("'${greetings5.i18n}'.i18n.args('Charlie', {'name': 'Alice', 'other': 'Bob'}, {1: 'Paris', 2: 'London'})",
              style: comment),
          space20,
          //
          divider,
          space12,
          //
          const Text('Interpolation with sprintf', style: title),
          const Text('%s, %1\$s and %2\$s', style: title),
          space20,
          Text(greetings6.i18n.fill('Alice', 'Bob'), style: body),
          Text("'" + greetings6.i18n + "'.i18n.fill('Alice', 'Bob')", style: comment),
          space20,
          Text(greetings6.i18n.fill(['Alice', 'Bob']), style: body),
          Text("'" + greetings6.i18n + "'.i18n.fill(['Alice', 'Bob'])", style: comment),
          space20,
          Text(greetings7.i18n.fill('Alice', 'Bob'), style: body),
          Text("'" + greetings7.i18n + "'.i18n.fill('Alice', 'Bob')", style: comment),
          space20,
          Text(greetings7.i18n.fill(['Alice', 'Bob']), style: body),
          Text("'" + greetings7.i18n + "'.i18n.fill(['Alice', 'Bob'])", style: comment),
          space20,
          Text(greetings8.i18n.fill('Alice', 'Bob'), style: body),
          Text("'" + greetings8.i18n + "'.i18n.fill('Alice', 'Bob')", style: comment),
          space20,
          Text(greetings8.i18n.fill(['Alice', 'Bob']), style: body),
          Text("'" + greetings8.i18n + "'.i18n.fill(['Alice', 'Bob'])", style: comment),
          space20,
        ],
      ),
    );
  }
}
