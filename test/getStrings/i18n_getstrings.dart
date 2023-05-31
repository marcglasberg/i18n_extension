import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:equatable/equatable.dart';

enum I18nRequiredModifiers { plural }

class I18nSuffixes {
  static const String i18n = 'i18n';
  static const String fill = 'fill';
  static const String plural = 'plural';
  static const String version = 'version';
  static const String allVersions = 'allVersions';

  static const List<String> allSuffixes = const [
    i18n,
    fill,
    plural,
    version,
    allVersions,
  ];
}

class ExtractedString extends Equatable {
  final String string;
  final int lineNumber;
  final String sourceFile;
  final bool pluralRequired;

  ExtractedString(this.string, this.lineNumber,
      {this.pluralRequired = false, this.sourceFile = ""});

  @override
  List<Object> get props => [string, sourceFile, lineNumber, pluralRequired];
}

class DecodedSyntax {
  DecodedSyntax._({
    required this.valid,
    this.modifiers = const [],
  });

  DecodedSyntax.valid(List<I18nRequiredModifiers> modifiers)
      : this._(valid: true, modifiers: modifiers);

  DecodedSyntax.invalid() : this._(valid: false);

  final bool valid;
  final List<I18nRequiredModifiers> modifiers;
}

class GetI18nStrings {
  final String? sourceDir;

  GetI18nStrings(
    this.sourceDir,
  );

  List<ExtractedString> run() {
    var libDir = Directory(sourceDir!);
    List<ExtractedString> sourceStrings = [];
    for (var f in libDir.listSync(recursive: true)) {
      if (f is File && f.path.endsWith(".dart")) {
        sourceStrings += processFile(f);
      }
    }
    return sourceStrings;
  }

  List<ExtractedString> processFile(File f) {
    return processString(f.readAsStringSync(), fileName: f.path);
  }

  List<ExtractedString> processString(String s, {fileName = ""}) {
    CompilationUnit unit = parseString(content: s, throwIfDiagnostics: false).unit;
    var extractor = StringExtractor(I18nSuffixes.allSuffixes, s, fileName);
    unit.visitChildren(extractor);
    return extractor.strings;
  }
}

class StringExtractor extends UnifyingAstVisitor<void> {
  List<ExtractedString> strings = [];
  List<String> suffixes;
  final String source;
  final String fileName;

  StringExtractor(this.suffixes, this.source, this.fileName);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final DecodedSyntax syntax = _hasI18nSyntax(node, node.parent!);
    _handleI18nSyntax(syntax, node);
    return super.visitSimpleStringLiteral(node);
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    final DecodedSyntax syntax = _hasI18nSyntax(node.strings.last, node.parent!);
    _handleI18nSyntax(syntax, node);

    // Don't call the super method here, since we don't want to visit the
    // child strings.
  }

  void _handleI18nSyntax(DecodedSyntax syntax, StringLiteral node) {
    if (syntax.valid && node.stringValue != null) {
      var lineNo = "\n".allMatches(source.substring(0, node.offset)).length + 1;
      final ExtractedString s = ExtractedString(node.stringValue!, lineNo,
          pluralRequired: syntax.modifiers.contains(I18nRequiredModifiers.plural),
          sourceFile: fileName);
      strings.add(s);
    }
  }

  /// Check if the next sibling in the AST is a DOT operator
  /// and after that comes a literal included in our suffixes.
  DecodedSyntax _hasI18nSyntax(AstNode self, AstNode parent) {
    Token? here = parent.beginToken;
    while (here != null && here != parent.endToken) {
      if (here == self.beginToken &&
          here.next!.type.lexeme == "." &&
          suffixes.contains(here.next!.next!.value())) {
        List<I18nRequiredModifiers> modifiers = List.empty(growable: true);
        if (here.next!.next!.value() == I18nSuffixes.plural) {
          modifiers.add(I18nRequiredModifiers.plural);
        }
        return DecodedSyntax.valid(modifiers);
      }
      here = here.next;
    }
    return DecodedSyntax.invalid();
  }
}
