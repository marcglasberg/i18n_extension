import 'package:example/1_translation_example/language_settings_page.i18n.dart';
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
        title: SelectableText('Language Settings Page'.i18n),
      ),
      body: Column(
        children: [
          //
          Transform.scale(scale: 0.75, child: MyWidget()),
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
        ElevatedButton(
          child: const Text(
            "context.locale = Locale(en, US)",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => context.locale = const Locale('en', 'US'),
        ),
        //
        ElevatedButton(
          child: const Text(
            "context.locale = Locale(es, ES)",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => context.locale = const Locale('es', 'ES'),
        ),
        //
        ElevatedButton(
          child: const Text(
            "context.locale = Locale(pt, BR)",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => context.locale = const Locale('pt', 'BR'),
        ),
        //
        ElevatedButton(
          child: const Text(
            "context.locale = null",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => context.locale = null,
        ),
        //
        //
        space16,
        SelectableText(
            'context.locale == Locale(${context.locale.format(separator: ', ')})'),
        SelectableText('I18n.locale == Locale(${I18n.locale.format(separator: ', ')})'),
        const SelectableText('Recommended ways to get the current locale',
            style: commentStyle),
        space16,
        SelectableText('I18n.languageTag == "${I18n.languageTag}"'),
        const SelectableText('The current locale as a string',
            style: commentStyle),
        space16,
        SelectableText('I18n.languageOnly == "${I18n.languageOnly}"'),
        const SelectableText('Language only, without country/region or script',
            style: commentStyle),
        space16,
        SelectableText('I18n.localeStr == "${I18n.localeStr}"'),
        const SelectableText('Deprecated way to get the locale as a string',
            style: commentStyle),
        space16,
        divider,
        space6,
        //
        space16,
        SelectableText(
            'I18n.systemLocale == Locale(${I18n.systemLocale.format(separator: ', ')})'),
        const SelectableText('The system locale read from the device', style: commentStyle),
        space16,
        SelectableText(
            'I18n.forcedLocale == ${I18n.forcedLocale == null ? null : 'Locale(${I18n.forcedLocale!.format(separator: ', ')})'}'),
        const SelectableText('The locale that overrides the system locale',
            style: commentStyle),
        const SelectableText('When null, the system locale will be used',
            style: commentStyle),
        space16,
        SelectableText('Localizations.maybeLocaleOf(context) == '
            'Locale(${Localizations.maybeLocaleOf(context)!.format(separator: ', ')})'),
        const SelectableText('The locale as per the MaterialApp widget',
            style: commentStyle),
        space16,
      ],
    );
  }
}
