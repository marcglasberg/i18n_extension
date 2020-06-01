import 'dart:io';

import 'dart:math';

class GetI18nStrings {
  final String regexTemplate = '"([^"]*)"\.<getter>';
  final List<String> stringDelimiters = ["\"", "'", '"""', "'''"];
  final List<String> suffixes;
  final String sourceDir;

  GetI18nStrings(this.sourceDir,
      {this.suffixes = const [
        ".i18n",
        ".fill",
        ".plural",
        ".version",
        ".allVersions"
      ]});

  List<String> run() {
    var libDir = new Directory(this.sourceDir);
    List<String> sourceStrings = [];
    for (var f in libDir.listSync(recursive: true)) {
      if (f is File && f.path.endsWith(".dart")) {
        sourceStrings += processFile(f);
      }
    }
    return sourceStrings;
  }

  List<String> processFile(File f) {
    return processString(f.readAsStringSync());
  }

  List<String> processString(String s) {
    return DartStringParser(s, suffixes).parse();
  }
}

class DartStringParser {
  /// [source] should be Dart code, [suffixes] a list of strings.
  /// The parser will find all Dart strings within the code that are
  /// followed by any of the suffixes.
  ///
  int pos = 0;
  List<String> strings = [];

  final String source;
  final List<String> suffixes;

  DartStringParser(this.source, this.suffixes);

  List<String> parse() {
    while (seek()) {
      _parseString();
    }
    return strings;
  }

  void _parseString() {
    String endSequence;
    assert(source[pos] == "'" || source[pos] == '"');

    if (source[pos + 1] == source[pos] && source[pos + 2] == source[pos]) {
      // start triple-quoted string
      endSequence = source[pos] * 3;
      pos += 3;
    } else {
      // start single-quoted string
      endSequence = source[pos];
      pos += 1;
    }

    int matchPos = -1, _pos = pos;
    // Make sure this is not an escaped quotation mark (\" or \""")
    while (matchPos < 0 || source[matchPos - 1] == "\\") {
      matchPos = source.indexOf(endSequence, _pos);
      if (matchPos < 0) return;
      _pos = matchPos + 1;
    }
    if (matchPos <= source.length &&
        suffixes.any((s) =>
            source.substring(matchPos + endSequence.length).startsWith(s)))
      strings.add(source.substring(pos, matchPos));
    pos = matchPos + endSequence.length;
  }

  bool seek() {
    List<int> possible = [];
    int nextOne = source.indexOf("'", pos);
    int nextTwo = source.indexOf('"', pos);

    if (nextOne > -1) {
      possible.add(nextOne);
    }

    if (nextTwo > -1) {
      possible.add(nextTwo);
    }

    if (possible.length == 0) {
      return false;
    }

    pos = possible.reduce(min);

    if (pos > 0 && source[pos - 1] == "\\" && source[pos - 2] != "\\") {
      return seek();
    }

    return true;
  }
}
