import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //
  test("Locale toString()", () {
    //
    // Default constructor
    var locale = const Locale('en', 'US');
    expect(locale.toString(), 'en_US');
    expect(locale.languageCode, 'en');
    expect(locale.countryCode, 'US');
    expect(locale.scriptCode, isNull);

    // ---

    // Constructor with scriptCode
    locale = const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    );
    expect(locale.toString(), 'zh_Hans_CN');
    expect(locale.languageCode, 'zh');
    expect(locale.countryCode, 'CN');
    expect(locale.scriptCode, 'Hans');

    // ---

    // Locale with only languageCode
    locale = const Locale('en');
    expect(locale.toString(), 'en');
    expect(locale.languageCode, 'en');
    expect(locale.countryCode, isNull);
    expect(locale.scriptCode, isNull);

    // ---

    // Wrong way of creating a Locale
    locale = const Locale('en_US');
    expect(locale.toString(), 'en_US');
    expect(locale.languageCode, 'en_US');
    expect(locale.countryCode, isNull);
    expect(locale.scriptCode, isNull);
  });

  test("Locale toLanguageTag()", () {
    //
    // Default constructor
    var locale = const Locale('en', 'US');
    expect(locale.toLanguageTag(), 'en-US');

    // Default constructor
    locale = const Locale('en', 'us');
    expect(locale.toLanguageTag(), 'en-us');

    // ---

    // Constructor with scriptCode
    locale = const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    );
    expect(locale.toLanguageTag(), 'zh-Hans-CN');

    // ---

    // Locale with only languageCode
    locale = const Locale('en');
    expect(locale.toLanguageTag(), 'en');

    // ---

    // Wrong way of creating a Locale
    locale = const Locale('en_US');
    expect(locale.toLanguageTag(), 'en_US');

    // Wrong way of creating a Locale
    locale = const Locale('en', 'us');
    expect(locale.toLanguageTag(), 'en-us');
  });
}
