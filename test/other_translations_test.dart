import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

void main() {
  //
  test("Translations.byId", () {
    I18n.define(const Locale("en", "US"));

    expect(12.i18n, "Twelve");
    expect(true.i18n, "True");
    expect("Hi".i18n, "Hi");
    expect(MyColors.red.i18n, "Red");
    expect(MyColors.green.i18n, "Green");
    expect(legalTerms.i18n, "Legal Terms");
    expect(privacyPolicy.i18n, "Privacy Policy");
    expect(faq.i18n, "FAQ");
    expect(DateTime(2021, 1, 1).i18n, "New Year");
    expect(SomeObj("abc").i18n, "SomeObj abc");
    expect(SomeObj("def").i18n, "SomeObj def");

    // ---

    I18n.define(const Locale("pt", "BR"));

    expect(12.i18n, "Doze");
    expect(true.i18n, "Verdadeiro");
    expect("Hi".i18n, "Oi");
    expect(MyColors.red.i18n, "Vermelho");
    expect(MyColors.green.i18n, "Verde");
    expect(legalTerms.i18n, "Termos Legais");
    expect(privacyPolicy.i18n, "Política de Privacidade");
    expect(faq.i18n, "Perguntas Frequentes");
    expect(DateTime(2021, 1, 1).i18n, "Ano Novo");
    expect(SomeObj("abc").i18n, "SomeObj abc");
    expect(SomeObj("def").i18n, "SomeObj def");
  });
}

enum MyColors { red, green }

const legalTerms = "legalTerms";
var privacyPolicy = UniqueKey();
var faq = UniqueKey();

extension Localization on Object? {
  //
  static final _t = Translations.byId("en_us", {
    12: {"en_us": "Twelve", "pt_br": "Doze"},
    true: {"en_us": "True", "pt_br": "Verdadeiro"},
    "Hi": {"en_us": "Hi", "pt_br": "Oi"},
    MyColors.red: {"en_us": "Red", "pt_br": "Vermelho"},
    MyColors.green: {"en_us": "Green", "pt_br": "Verde"},
    legalTerms: {"en_us": "Legal Terms", "pt_br": "Termos Legais"},
    privacyPolicy: {"en_us": "Privacy Policy", "pt_br": "Política de Privacidade"},
    faq: {"en_us": "FAQ", "pt_br": "Perguntas Frequentes"},
    DateTime(2021, 1, 1): {"en_us": "New Year", "pt_br": "Ano Novo"},
    SomeObj("abc"): {"en_us": "SomeObj abc", "pt_br": "SomeObj abc"},
    SomeObj("def"): {"en_us": "SomeObj def", "pt_br": "SomeObj def"},
  });

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String? plural(value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);

  Map<String?, String> allVersions() => localizeAllVersions(this, _t);

  String gender(Gender gnd) => localizeVersion(gnd, this, _t);
}

enum Gender { they, female, male, x }

/// IMPORTANT: You can create your own class and use its objects as identifiers, but it
/// must implement the `==` and `hashCode` methods. Otherwise, it won't be possible to
/// find it as one of the translation keys.
class SomeObj {
  final String value;

  SomeObj(this.value);

  @override
  String toString() => 'SomeObj{value: $value}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SomeObj && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
