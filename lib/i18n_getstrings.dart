import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class GetI18nStrings {
  final List<String> suffixes;
  final String? sourceDir;

  GetI18nStrings(this.sourceDir,
      {this.suffixes = const [
        "i18n",
        "fill",
        "plural",
        "version",
        "allVersions"
      ]});

  List<String> run() {
    var libDir = Directory(sourceDir!);
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
    CompilationUnit unit =
        parseString(content: s, throwIfDiagnostics: false).unit;
    var extractor = StringExtractor(suffixes);
    unit.visitChildren(extractor);
    return extractor.strings;
  }
}


class StringExtractor extends UnifyingAstVisitor<void> {
  List<String> strings = [];
  List<String> suffixes;

  StringExtractor(this.suffixes);

  @override
  void visitNode(AstNode node) {
    return super.visitNode(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (_hasI18nSyntax(node, node.parent!)) {
      strings.add(node.value);
    }

    return super.visitSimpleStringLiteral(node);
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    if (_hasI18nSyntax(node.strings.last, node.parent!)) {
      strings.add(node.stringValue!);
    }

    // Dont' call the super method here, since we don't want to visit the
    // child strings.
  }

  /*
  Check if the next sibling in the AST is a DOT operator
  and after that comes a literal included in our suffixes.
   */
  bool _hasI18nSyntax(AstNode self, AstNode parent) {
    var here = parent.beginToken;
    while (here != parent.endToken) {
      if (here == self.beginToken &&
          here.next!.type.lexeme == "." &&
          suffixes.contains(here.next!.next!.value())) {
        return true;
      }
      here = here.next!;
    }
    return false;
  }
}
