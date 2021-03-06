import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

/// !!!!!!!!!!!!!!!!!!!!!!!!!!!
/// TODO: This is not yet implemented, so all tests here should fail.
/// TODO: Does anyone really need this? I should implement this only if someone ever complains.
/// TODO: If/when this is implemented, add this to the readme:
///
/// **Q: If the UX team wants to change an English translation,
/// they would have to make that modification in code, right?
/// They couldn't just update some `.arb` file
/// as the English version then no longer matches the literal `.i18n` was called on.**
///
/// **A:** _If the UX team wants to change an English translation,
/// they can just update the English translation and not the translatable string.
/// That would mean the translatable string is now simply acting as a key,
/// which is not the idea in the first place.
/// But it would work, no problem.
/// Also, i18n_extension can report to the developer
/// that the string in the code and in the translation are out of sync,
/// in case the developer wants to fix it.
/// This problem is also the case with regular keys of old methods:
/// If you update some text and then the key has nothing to do with the text anymore._
///
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!
///
void main() {
  //
  //////////////////////////////////////////////////////////////////////////////////////////////////

  test(
      "The translatable key is usually the same as the default locale translation, "
      "but it can be different."
      ""
      "For example { '': 'Good evening' } means that 'Good evening' is the key, "
      "and you can provide an English translation which is different than that, "
      "even if English is the default locale. "
      ""
      "This is to support the use case when you want to have fixed keys, "
      "which is NOT the preferred way to do it, "
      "but may be necessary for some advanced use cases.", () {
    //
    /// TODO: Uncomment if necessary:
//    I18n.define(Locale("pt", "BR"));
//
//    // 1) This works because the key "Hello" is provided in "en_us".
//    expect("Hello".i18n, "Olá");
//
//    // 2) This works because the key "Good evening" is provided both in "en_us" and as a default "".
//    expect("Good evening".i18n, "Boa noite");
//
//    // 3) This works because the key "Goodbye" is provided in "en_us",
//    // and the key "xyz" is provided as a default "".
//    expect("Goodbye".i18n, "Adeus");
//    expect("xyz".i18n, "Adeus");
//
//    // 4) This works because the key "Good morning" is provided as a default "".
//    expect("Good morning".i18n, "Bom dia");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Should not accept empty keys or values.", () {
    //
    /// TODO: Uncomment if necessary:
//    // This should work ok (and not do anything).
//    var x = Translations("en_us") + {};
//
//    // This works ok too, because the "" locale means "any" the default.
//    var y = Translations("en_us") + {"": "some text"};
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}

extension Localization on String {
  //
  static final _t = Translations("en_us") +
      {
        "en_us": "Hello",
        "pt_br": "Olá",
      } +
      {
        "": "Good evening",
        "en_us": "Good evening",
        "pt_br": "Boa noite",
      } +
      {
        "": "xyz",
        "en_us": "Goodbye",
        "pt_br": "Adeus",
      } +
      {
        "": "Good morning",
        "pt_br": "Bom dia",
      };

  String get i18n => localize(this, _t);
}
