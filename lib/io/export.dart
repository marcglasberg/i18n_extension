import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:gettext_parser/gettext_parser.dart' as gettext_parser;

Map<String, Exporter Function(dynamic)> exporters = {
  "pot": (s) => GettextExporter(s),
  "json": (s) => JsonExporter(s)
};

abstract class Exporter {
  HashMap<String, String> getTemplate() {
    HashMap<String, String> template = HashMap();
    for (var s in sourceStrings) {
      template[s] = "";
    }
    return template;
  }

  List<String> sourceStrings;
  Exporter(this.sourceStrings);
  Future<void> exportTo(File target);
}

class GettextExporter extends Exporter {
  GettextExporter(List<String> sourceStrings) : super(sourceStrings);

  @override
  Future<void> exportTo(File target) async {
    Map<String, dynamic> template = {};

    for (var string in sourceStrings) {
      template[string] = {
        "msgid": string,
        "msgstr": [""]
      };
    }

    Map out = {
      "charset": "utf-8",
      "headers": {"content-type": "text/plain; charset=utf-8"},
      "translations": {"": template}
    };

    await target.writeAsString(gettext_parser.po.compile(out));
  }
}

class JsonExporter extends Exporter {
  JsonExporter(List<String> sourceStrings) : super(sourceStrings);

  @override
  Future<void> exportTo(File target) async {
    JsonEncoder encoder =JsonEncoder.withIndent(' ' * 4);
    await target.writeAsString(encoder.convert(getTemplate()));
  }
}
