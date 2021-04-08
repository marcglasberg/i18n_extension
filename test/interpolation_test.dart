import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/i18n_widget.dart';

void main() {
  //
  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("String interpolations.", () {
    //
    I18n.define(const Locale("en", "US"));
    expect("Hello %s, this is %s.".i18n, "Hello %s, this is %s.");
    expect("Hello %s, this is %s.".i18n.fill(["John", "Mary"]), "Hello John, this is Mary.");

    I18n.define(const Locale("pt", "BR"));
    expect("Hello %s, this is %s.".i18n, "Olá %s, aqui é %s.");
    expect("Hello %s, this is %s.".i18n.fill(["John", "Mary"]), "Olá John, aqui é Mary.");
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}

extension Localization on String {
  //
  static final _t = Translations("en_us") +
      {
        "en_us": "Hello %s, this is %s.",
        "pt_br": "Olá %s, aqui é %s.",
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);

  Map<String?, String> allVersions() => localizeAllVersions(this, _t);

  String gender(Gender gnd) => localizeVersion(gnd, this, _t);
}

enum Gender { they, female, male }
