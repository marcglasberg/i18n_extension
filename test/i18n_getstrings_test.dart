import 'package:flutter_test/flutter_test.dart';

import 'getStrings/i18n_getstrings.dart';

void main() {
  test("Simple case", () {
    var source = """
    void main() {
      print("This is a test".i18n);
      print("This should not match");
      print('This is another %s test'.fill('great'));
      print('This should not match');
    }
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, [
      ExtractedString("This is a test", 2),
      ExtractedString("This is another %s test", 4),
    ]);
  });

  test("Triple-quoted strings", () {
    var source = """
    void main() {
      print("\""This is a
"test" "\"".i18n);
      print(""\"This should not match"\"");
      print('\''This is another test'\''.i18n);
      print('\''This should not match'\'');
    }
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, [
      ExtractedString("This is a\n\"test\" ", 2),
      ExtractedString("This is another test", 5),
    ]);
  });

  test("Invalid Dart", () {
    var source = """
    var y = '''.i18n;
    var z = '''Hello'''';
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, []);
  });

  test("Plurals in .POT", () {
    var source = """
    return Padding(
                  padding: const EdgeInsets.all(16),
                  child: TranslatableRichText(
                    Text(
                      '''%s order on %s'''.plural(_orders!.length).fill(
                        <String>[
                          _orders!.length.toStringAsFixed(
                            0,
                          ),
                          formattedPickup
                        ],
                      ),
                    ),
                    richTexts: <BaseRichText>[
                      BaseRichText(
                        text: '%s order'
                            .plural(_orders!.length)
                            .fill(<String>[_orders!.length.toStringAsFixed(0)]),
                        style: AppTextStyles.vocalOrderBoldTitle.copyWith(
                          color: AppColors.vocalOrderErrorColor,
                        ),
                      ),
                    ],
                  ),
                );
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, [
      ExtractedString('%s order on %s', 5, pluralRequired: true),
      ExtractedString('%s order', 16, pluralRequired: true),
    ]);
  });

  test("Real-world example", () {
    var source = """
    import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperless_app/i18n.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class SettingsRoute extends StatefulWidget {
  SettingsRoute({Key key}) : super(key: key);

  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  bool invertDocumentPreview = true;
  SharedPreferences prefs;
  _SettingsRouteState();


  @override
  void initState()  {
    loadPreferences();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      invertDocumentPreview = prefs.getBool("invert_document_preview") ?? true;
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SettingsList(
          sections: [
            SettingsSection(
              title: 'View'.i18n,
              tiles: [
                SettingsTile.switchTile(
                  title: 'Invert Document Preview in Dark Mode'.i18n,
                  leading: Icon(Icons.invert_colors),
                  switchValue: invertDocumentPreview,
                  onToggle: (bool value) {
                    prefs.setBool("invert_document_preview", value);
                    setState(() {
                      invertDocumentPreview = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
    );
  }
}""";
    var results = GetI18nStrings("").processString(source);
    expect(results, [
      ExtractedString('View', 40),
      ExtractedString('Invert Document Preview in Dark Mode', 43),
    ]);
  });

  test("Multi-line statements", () {
    var source = """
    var y = 'mysamplestring %s'
      .i18n
      .fill("test");
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, [ExtractedString("mysamplestring %s", 1)]);
  });

  test("Simple case with comments", () {
    var source = """
    void main() {
      print("This is a test".i18n);
      // You will find it doesn't work past this point
      print("This should not match");
      print('This is another %s test'.fill('great'));
      print('This should not match');
    }
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, [
      ExtractedString("This is a test", 2),
      ExtractedString("This is another %s test", 5),
    ]);
  });

  test("Simple case with adjacent strings", () {
    var source = """
    var text = "This should be a single string, "
               "hopefully it doesn't just recognise "
               "the last part.".i18n;
    var toxt = "This will not be translated, "
               "so it shouldn't be recognised "
               "at all.";     
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, [
      ExtractedString(
          "This should be a single string, hopefully it doesn't just recognise the last part.", 1),
    ]);
  });
}
