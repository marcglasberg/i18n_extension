import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:i18n_extension/i18n_getstrings.dart';

void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption("output-file", abbr: "f", defaultsTo: "strings.json")
    ..addOption("source-dir", abbr: "s", defaultsTo: "./lib");
  var results = parser.parse(arguments);
  var strings = GetI18nStrings(results["source-dir"]).run();
  var template = HashMap();
  for (var s in strings) {
    template[s] = "";
  }
  JsonEncoder encoder = new JsonEncoder.withIndent(' '*4);
  File(results["output-file"]).writeAsStringSync(encoder.convert(template));
  print(
      "Wrote ${strings.length} strings to template ${results["output-file"]}");
}
