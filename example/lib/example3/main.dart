import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'my_widget.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

/// This example demonstrates having two `I18n` widgets.
/// It is NOT recommended to have two `I18n` widgets, at all.
/// However, if for some reason it is inevitable, I've provided
/// the I18n.forceRebuild() method to help you deal with it.
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', "US"),
          const Locale('pt', "BR"),
        ],
        home: Scaffold(
          appBar: AppBar(title: const Text("Multiple i18n Demo")),
          body: MyScreen(),
        ),
      );
}

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //
          // This is the FIRST instance of the I18n widget:
          I18n(
            id: "first",
            initialLocale: const Locale("en", "US"),
            child: Widget1(),
          ),
          const SizedBox(height: 20.0),
          //
          // This is the SECOND instance of the I18n widget.
          // Note `Widget2` will change the locale as usual,
          // And then force the rebuild of the FIRST I18n widget.
          I18n(
            id: "second",
            initialLocale: const Locale("en", "US"),
            child: Widget2(),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class Widget1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyWidget();
  }
}

class Widget2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        children: [
          MyWidget(),
          MaterialButton(
            color: Colors.blue,
            child: const Text(
              "CLICK ME",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            onPressed: () {
              var newLocale = (I18n.localeStr == "pt_br")
                  ? const Locale("en", "US")
                  : const Locale("pt", "BR");

              // This changes the language and rebuilds the FIRST I18n widget.
              I18n.of(context).locale = newLocale;

              // This forces the rebuild of the SECOND I18n widget.
              I18n.forceRebuild("first");
            },
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
