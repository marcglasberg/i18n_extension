import 'package:example/example3/language_settings_page.i18n.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'my_widget.dart';

const Widget space6 = SizedBox(width: 6, height: 6);
const Widget space16 = SizedBox(width: 16, height: 16);
final Widget divider = Container(width: double.infinity, height: 2, color: Colors.grey);
const commentStyle = TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);

class LanguageSettingsPage extends StatefulWidget {
  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  //
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        //
        // 2) We can use the `const` keyword:
        title: Text('Language Settings Page'.i18n),
      ),
      body: Column(
        children: [
          //
          MyWidget(),
          //
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _usingThemedOf(ctx),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _usingThemedOf(BuildContext ctx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        space16,
        ElevatedButton(
          child: const Text(
            "I18n.of(context).locale = Locale(en, US)",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => I18n.of(context).locale = const Locale('en', 'US'),
        ),
        //
        space6,
        ElevatedButton(
          child: const Text(
            "I18n.of(context).locale = Locale(es, ES)",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => I18n.of(context).locale = const Locale('es', 'ES'),
        ),
        //
        space6,
        ElevatedButton(
          child: const Text(
            "I18n.of(context).locale = Locale(pt, BR)",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => I18n.of(context).locale = const Locale('pt', 'BR'),
        ),
        //
        space6,
        ElevatedButton(
          child: const Text(
            "I18n.of(context).locale = null",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => I18n.of(context).locale = null,
        ),
        //
        //
        space16,
        Text('I18n.of(context).locale == Locale{${I18n.of(context).locale}}'),
        const Text('Recommended way to get the current locale', style: commentStyle),
        //
        space16,
        Text('I18n.locale == Locale{${I18n.locale}}'),
        const Text('Also recommended way to get the current locale', style: commentStyle),
        space16,
        Text('I18n.languageTag == "${I18n.languageTag}"'),
        const Text('Recommended way to get the locale as a string', style: commentStyle),
        space16,
        Text('I18n.localeStr == "${I18n.localeStr}"'),
        const Text('Recommended way to get the locale as a string', style: commentStyle),
        space16,
        divider,
        space6,
        //
        space16,
        Text('I18n.systemLocale == ${I18n.systemLocale}'),
        const Text('The locale read from the system', style: commentStyle),
        space16,
        Text('I18n.forcedLocale == ${I18n.forcedLocale}'),
        const Text('The locale that overrides the system locale', style: commentStyle),
        const Text('When null, the system locale will be used', style: commentStyle),
        space16,
        Text('Localizations.maybeLocaleOf(context) == '
            '${Localizations.maybeLocaleOf(context)}'),
        const Text('The locale as per the MaterialApp widget', style: commentStyle),
        space16,
      ],
    );
  }
}
