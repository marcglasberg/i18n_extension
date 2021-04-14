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
  final bool pluralRequired;

  ExtractedString(this.string, {this.pluralRequired = false});

  @override
  List<Object> get props => [string, pluralRequired];
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
    return processString(f.readAsStringSync());
  }

  List<ExtractedString> processString(String s) {
    CompilationUnit unit =
        parseString(content: s, throwIfDiagnostics: false).unit;
    var extractor = StringExtractor(I18nSuffixes.allSuffixes);
    unit.visitChildren(extractor);
    return extractor.strings;
  }
}

class StringExtractor extends UnifyingAstVisitor<void> {
  List<ExtractedString> strings = [];
  List<String> suffixes;

  StringExtractor(this.suffixes);

  @override
  void visitNode(AstNode node) {
    return super.visitNode(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _handleI18nSyntax(node);
    return super.visitSimpleStringLiteral(node);
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    _handleI18nSyntax(node);

    final DecodedSyntax syntax =
        _hasI18nSyntax(node.strings.last, node.parent!);
    if (syntax.valid) {
      final ExtractedString s = ExtractedString(node.stringValue!,
          pluralRequired:
              syntax.modifiers.contains(I18nRequiredModifiers.plural));
      strings.add(s);
    }

    // Dont' call the super method here, since we don't want to visit the
    // child strings.
  }

  void _handleI18nSyntax(StringLiteral node) {
    final DecodedSyntax syntax = _hasI18nSyntax(node, node.parent!);
    if (syntax.valid && node.stringValue != null) {
      final ExtractedString s = ExtractedString(node.stringValue!,
          pluralRequired:
              syntax.modifiers.contains(I18nRequiredModifiers.plural));
      strings.add(s);
    }
  }

  /*
  Check if the next sibling in the AST is a DOT operator
  and after that comes a literal included in our suffixes.
   */
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
