import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gettext_parser/gettext_parser.dart' as gettext_parser;

// /////////////////////////////////////////////////////////////////////////////

abstract class Importer {
  String get _extension;

  Map<String, String> _load(String source);

  Future<Map<String, Map<String, String>>> fromAssetFile(
      String language, String fileName) async {
    return {language: _load(await rootBundle.loadString(fileName))};
  }

  Future<Map<String, Map<String, String>>> fromAssetDirectory(
      String dir) async {
    var manifestContent = await rootBundle.loadString("AssetManifest.json");
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    Map<String, Map<String, String>> translations = HashMap();

    for (String path in manifestMap.keys) {
      if (!path.startsWith(dir)) continue;
      var fileName = path.split("/").last;
      if (!fileName.endsWith(_extension)) {
        print("➜ Ignoring file $path with unexpected file type "
            "(expected: $_extension).");
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

// /////////////////////////////////////////////////////////////////////////////

class JSONImporter extends Importer {
  @override
  String get _extension => ".json";

  @override
  Map<String, String> _load(String source) {
    return Map<String, String>.from(json.decode(source));
  }
}

// /////////////////////////////////////////////////////////////////////////////
const _splitter1 = "\uFFFF";
const _splitter2 = "\uFFFE";

class GettextImporter extends Importer {
  @override
  String get _extension => ".po";

  @override
  Map<String, String> _load(String source) {
    Map<String, String> out = {};
    Map translations = gettext_parser.po.parse(source)["translations"][""];
    for (Map translation in translations.values) {
      if (translation.isNotEmpty) {
        if (translation["msgstr"].length == 1) {
          String? msgstr = translation["msgstr"][0];
          if (msgstr != null && msgstr.isNotEmpty) {
            String? msgid = translation["msgid"];
            if (msgid != null && msgid.isNotEmpty) out[msgid] = msgstr;
          }
        } else {
          String? msgid = translation["msgid"];
          if (msgid != null && msgid.isNotEmpty)
            out[msgid] = _splitter1 +
                translation["msgstr"][0] +
                _splitter1 +
                '1' +
                _splitter2 +
                translation["msgstr"][0] +
                _splitter1 +
                'M' +
                _splitter2 +
                translation["msgstr"][1];
        }
      }
    }
    return out;
  }
}

// /////////////////////////////////////////////////////////////////////////////
