import 'package:gettext_parser/gettext_parser.dart' as gettext_parser;
import 'package:i18n_extension/i18n_extension.dart';

/// Loads translations from PO (gettext) files.
///
/// A file like `es-ES.po` contains entries like these:
///
/// ```po
/// msgid ""
/// msgstr ""
/// "Content-Type: text/plain; charset=UTF-8\n"
///
/// msgid "Welcome to this demo."
/// msgstr "Bienvenido a esta demostración."
///
/// msgid "Hello, World!"
/// msgstr "¡Hola, Mundo!"
/// ```
///
/// # Plurals
///
/// An entry with `msgid_plural` becomes a translation with plural versions, for the
/// `plural` function: `msgstr[0]` is the singular (the `one` version, and also the
/// unversioned text), and `msgstr[1]` is the plural (the `many` version), like
/// `.one()` and `.many()` in Dart:
///
/// ```po
/// msgid "You have %d message"
/// msgid_plural "You have %d messages"
/// msgstr[0] "Tienes %d mensaje"
/// msgstr[1] "Tienes %d mensajes"
/// ```
///
/// # Genders
///
/// Gettext has no genders, but its `msgctxt` (message context) is the usual way to
/// tell them apart. The entries with the contexts `male`, `female` and `neutral`
/// become the gender versions of the entry with the same `msgid`, for the `gender`
/// function, like `.male()`, `.female()` and `.neutral()` in Dart:
///
/// ```po
/// msgid "There is a person"
/// msgstr "Hay una persona"
///
/// msgctxt "male"
/// msgid "There is a person"
/// msgstr "Hay un hombre"
///
/// msgctxt "female"
/// msgid "There is a person"
/// msgstr "Hay una mujer"
/// ```
///
/// The entry without context is the unversioned text, used when the gender has no
/// version. If there is no such entry, the unversioned text is the `msgid` itself.
///
/// A gender entry may also have `msgid_plural`, to combine gender and plural, for the
/// `plural` function and its gender:
///
/// ```po
/// msgctxt "male"
/// msgid "There is a person"
/// msgid_plural "There are %d people"
/// msgstr[0] "Hay un hombre"
/// msgstr[1] "Hay %d hombres"
/// ```
///
/// Entries with any other context are read as if they had no context. Since the
/// contexts don't become part of the translation key, an entry with a context
/// overwrites an entry with the same `msgid` and another context.
///
class I18nPoLoader extends I18nLoader {
  //
  @override
  String get extension => '.po';

  static const _msgStr = 'msgstr';
  static const _msgId = 'msgid';

  static const _splitter1 = '\uFFFF';
  static const _splitter2 = '\uFFFE';

  /// The modifiers of the string extensions `.male()`, `.female()` and `.neutral()`,
  /// by the `msgctxt` used for them in the files.
  static const _genderModifiersByContext = {
    'male': 'm',
    'female': 'f',
    'neutral': 'n',
  };

  @override
  Map<String, dynamic> decode(String source) {
    //
    Map<String, String> out = {};

    // The gender versions of each msgid, from the entries with the gender contexts.
    Map<String, Map<String, String>> genderVersionsByMsgId = {};

    Map<String, dynamic> translations =
        gettext_parser.po.parse(source)["translations"];

    for (MapEntry<String, dynamic> contextEntry in translations.entries) {
      //
      String context = contextEntry.key;
      String? genderModifier = _genderModifiersByContext[context];

      Map translationsInContext = contextEntry.value;

      for (Map translation in translationsInContext.values) {
        //
        if (translation.isEmpty) continue;

        String? msgId = translation[_msgId];
        if (msgId == null || msgId.isEmpty) continue;

        String? text = _text(translation);
        if (text == null) continue;

        if (genderModifier == null) {
          out[msgId] = text;
        } else {
          (genderVersionsByMsgId[msgId] ??= {})[genderModifier] = text;
        }
      }
    }

    // Adds the gender versions to the unversioned text of the msgid, which is
    // the msgid itself when the file has no entry without context. Note the
    // `modifier` function flattens the plural versions of a gender, like `m1`.
    for (MapEntry<String, Map<String, String>> entry
        in genderVersionsByMsgId.entries) {
      //
      String msgId = entry.key;
      String result = out[msgId] ?? msgId;

      for (MapEntry<String, String> version in entry.value.entries) {
        result = result.modifier(version.key, version.value);
      }

      out[msgId] = result;
    }

    return out;
  }

  /// The text of a [translation] entry: the `msgstr`, or, for an entry with
  /// `msgid_plural`, the text with the plural versions, where `msgstr[0]` is the
  /// singular (the `one` version, and the unversioned text) and `msgstr[1]` is the
  /// plural (the `many` version). Returns null if the entry has no translation.
  static String? _text(Map translation) {
    //
    List msgStrs = translation[_msgStr];

    if (msgStrs.length == 1) {
      String? msgStr = msgStrs[0];
      return (msgStr != null && msgStr.isNotEmpty) ? msgStr : null;
    }
    //
    else {
      String firstMsgStr = msgStrs[0];
      String secondMsgStr = msgStrs[1];
      return "$_splitter1$firstMsgStr$_splitter1"
          "1$_splitter2$firstMsgStr$_splitter1"
          "M$_splitter2$secondMsgStr";
    }
  }
}
