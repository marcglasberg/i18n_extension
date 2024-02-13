import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:i18n_extension/i18n_extension.dart';

void main() {
  //
  test("Record missing keys used with .i18n of the default import.", () {
    //
    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    // This should call recordKey().
    "Hello".i18n;

    expect(Translations.missingKeys.length, 1);
    expect(Translations.missingKeys.single.locale, "");
    expect(Translations.missingKeys.single.key, "Hello");
    expect(Translations.missingTranslations, isEmpty);

    // ---

    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    // Call recordKey() directly.
    recordMissingKey("Goodbye");

    expect(Translations.missingKeys.length, 1);
    expect(Translations.missingKeys.single.locale, "");
    expect(Translations.missingKeys.single.key, "Goodbye");
    expect(Translations.missingTranslations, isEmpty);
  });

  test("Record missing keys used with .plural() of the default import.", () {
    //
    Translations.missingKeys.clear();
    Translations.missingTranslations.clear();

    // This should call recordKey().
    var translated = "There are %d people".plural(2);

    // In the result, "%d" should be replaced by "2".
    expect(translated, "There are 2 people");

    // But the recorded key should contain "%d".
    expect(Translations.missingKeys.length, 1);
    expect(Translations.missingKeys.single.locale, "");
    expect(Translations.missingKeys.single.key, "There are %d people");
    expect(Translations.missingTranslations, isEmpty);
  });
}
