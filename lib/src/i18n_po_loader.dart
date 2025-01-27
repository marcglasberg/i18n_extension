import 'package:gettext_parser/gettext_parser.dart' as gettext_parser;

import 'i18n_loader.dart';

class I18nPoLoader extends I18nLoader {
  //
  @override
  String get extension => '.po';

  static const _msgStr = 'msgstr';
  static const _msgId = 'msgid';

  static const _splitter1 = '\uFFFF';
  static const _splitter2 = '\uFFFE';

  /// load a file, like `es-ES.po`, containing something like:
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
  ///
  /// msgid "How are you?"
  /// msgstr "¿Cómo estás?"
  ///
  /// msgid "Goodbye!"
  /// msgstr "¡Adiós!"
  /// ```
  @override
  Map<String, dynamic> decode(String source) {
    //
    Map<String, String> out = {};

    Map<String, dynamic> translations = gettext_parser.po.parse(source)["translations"];

    Iterable<dynamic> contexts = translations.values;
    for (Map context in contexts) {
      //
      var translations = context.values;
      for (Map translation in translations) {
        //
        if (translation.isNotEmpty) {
          //
          if (translation[_msgStr].length == 1) {
            String? msgStr = translation[_msgStr][0];
            if (msgStr != null && msgStr.isNotEmpty) {
              String? msgId = translation[_msgId];
              if (msgId != null && msgId.isNotEmpty) out[msgId] = msgStr;
            }
          }
          //
          else {
            String? msgId = translation[_msgId];
            if (msgId != null && msgId.isNotEmpty) {
              String firstMsgStr = translation[_msgStr][0];
              String secondMsgStr = translation[_msgStr][1];
              out[msgId] = "$_splitter1$firstMsgStr$_splitter1"
                  "1$_splitter2$firstMsgStr$_splitter1"
                  "M$_splitter2$secondMsgStr";
            }
          }
        }
      }
    }
    return out;
  }
}
