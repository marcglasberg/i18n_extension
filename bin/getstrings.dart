import 'dart:io';

import 'package:args/args.dart';
import 'package:i18n_extension/i18n_getstrings.dart';
import 'package:i18n_extension/io/export.dart';

void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption("output-file",
        abbr: "f",
        defaultsTo: "strings.pot",
        valueHelp: "Supported formats: ${exporters.keys.join(", ")}")
    ..addOption("source-dir", abbr: "s", defaultsTo: "./lib");
  var results = parser.parse(arguments);

  var fileFormat = results["output-file"].split(".").last;
  if (!exporters.containsKey(fileFormat)) {
    print("Unable to write to ${results["output-file"]}.");
    print("Supported formats: ${exporters.keys.join(", ")}");
    exit(1);
  }

  List<ExtractedString> strings = GetI18nStrings(results["source-dir"]).run();

  var outFile = File(results["output-file"]);
  await outFile.create();
  exporters[fileFormat]!(strings).exportTo(outFile);

  print(
      "Wrote ${strings.length} strings to template ${results["output-file"]}");
}
