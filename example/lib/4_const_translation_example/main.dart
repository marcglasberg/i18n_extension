// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'package:i18n_extension/i18n_extension.dart';
import 'package:material_ui/material_ui.dart';

import 'my.i18n.dart';
import 'my_screen.dart';

/// This example demonstrates how to use identifiers as translation keys, defined as
/// constants, using a the [ConstTranslations] constructor:
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
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
      appBar: AppBar(title: Text(appbarTitle.i18n), backgroundColor: Colors.blue),
      body: MyScreen(),
    );
  }
}
