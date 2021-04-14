import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_getstrings.dart';

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
    expect(
        results,
        ["This is a test", "This is another %s test"]
            .map((e) => ExtractedString(e)));
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
    expect(
        results,
        ["This is a\n\"test\" ", "This is another test"]
            .map((e) => ExtractedString(e)));
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
      ExtractedString('%s order on %s', pluralRequired: true),
      ExtractedString('%s order', pluralRequired: true)
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
    expect(
        results,
        ['View', 'Invert Document Preview in Dark Mode']
            .map((e) => ExtractedString(e)));
  });

  test("Multi-line statements", () {
    var source = """
    var y = 'mysamplestring %s'
      .i18n
      .fill("test");
    """;
    var results = GetI18nStrings("").processString(source);
    expect(results, ["mysamplestring %s"].map((e) => ExtractedString(e)));
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
    expect(
        results,
        ["This is a test", "This is another %s test"]
            .map((e) => ExtractedString(e)));
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
    expect(
        results,
        [
          "This should be a single string, hopefully it doesn't just recognise the last part."
        ].map((e) => ExtractedString(e)));
  });
}
