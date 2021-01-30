import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gettext_parser/gettext_parser.dart' as gettextParser;

abstract class Importer {
  String _extension;

  Map<String, String> _load(String source);

  Future<Map<String, Map<String, String>>> fromAssetFile(
      String language, String fileName) async {
    return {language: _load(await rootBundle.loadString(fileName))};
  }

  Future<Map<String, Map<String, String>>> fromAssetDirectory(
      String dir) async {
    var manifestContent = await rootBundle.loadString("AssetManifest.json");
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    Map<String, Map<String, String>> translations = new HashMap();

    for (String path in manifestMap.keys) {
      if (!path.startsWith(dir)) continue;
      var fileName = path.split("/").last;
      if (!fileName.endsWith(_extension)) {
        print(
            "➜ Ignoring file $path with unexpected file type (expected: $_extension).");
        continue;
      }
      var languageCode = fileName.split(".")[0];
      translations.addAll(await fromAssetFile(languageCode, path));
    }

    return translations;
  }

  Future<Map<String, Map<String, String>>> fromString(
      String language, String source) async {
    return {language: _load(source)};
  }
}

class JSONImporter extends Importer {
  var _extension = ".json";

  @override
  Map<String, String> _load(String source) {
    return new Map<String, String>.from(json.decode(source));
  }
}

class GettextImporter extends Importer {
  var _extension = ".po";

  @override
  Map<String, String> _load(String source) {
    Map<String, String> out = {};
    var translations = gettextParser.po.parse(source)["translations"][""];
    for (Map translation in translations.values) {
      if (translation.length > 0 && translation["msgstr"][0] != "")
        out[translation["msgid"]] = translation["msgstr"][0];
    }
    return out;
  }
}
