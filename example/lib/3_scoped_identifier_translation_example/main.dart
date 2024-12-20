// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'my.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates how to define SCOPED identifiers, to use them as
/// translation keys. For example, you can declare:
///
///     class MyScope {
///        static final appbarTitle = Object();
///        static final greetings = Object();
///     }
///
///     class OtherScope {
///        static final increment = Object();
///        static final changeLanguage = Object();
///        static final youClickedThisNumberOfTimes = Object();
///     }
///
/// And then write:
///
///     Text(MyScope.greetings.i18n);
///     MaterialButton(child: Text(OtherScope.increment.i18n));
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    I18n(
      initialLocale: await I18n.loadLocale(),
      autoSaveLocale: true,
      supportedLocales: [
        const Locale('en', "US"),
        const Locale('pt', "BR"),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: AppCore(),
    ),
  );
}

class AppCore extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: I18n.locale,
        localizationsDelegates: I18n.localizationsDelegates,
        supportedLocales: I18n.supportedLocales,
        home: MyHomePage(),
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
      appBar: AppBar(title: Text(MyScope.appbarTitle.i18n), backgroundColor: Colors.blue),
      body: MyScreen(),
    );
  }
}
