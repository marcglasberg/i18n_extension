import 'dart:ui';

import 'package:i18n_extension/i18n_extension.dart';
import 'package:test/test.dart';

void main() {
  group('toLocale()', () {
    test('handles simple language code', () {
      final locale = 'en'.toLocale();
      expect(locale.languageCode, 'en');
      expect(locale.scriptCode, isNull);
      expect(locale.countryCode, isNull);
    });

    test('handles language-region', () {
      final locale = 'en-US'.toLocale();
      expect(locale.languageCode, 'en');
      expect(locale.scriptCode, isNull);
      expect(locale.countryCode, 'US');
    });

    test('handles language-script-region', () {
      final locale = 'en-Latn-US'.toLocale();
      expect(locale.languageCode, 'en');
      expect(locale.scriptCode, 'Latn');
      expect(locale.countryCode, 'US');
    });

    test('handles lowercase language and uppercase country', () {
      final locale = 'pt-br'.toLocale(); // normalized to pt-BR
      expect(locale.languageCode, 'pt');
      expect(locale.countryCode, 'BR');
      expect(locale.scriptCode, isNull);
    });

    test('converts underscores to hyphens', () {
      var locale = 'en_US'.toLocale(); // normalized to en-US
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, 'US');

      locale = 'en_us'.toLocale(); // normalized to en-US
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, 'US');
    });

    test('handles script without region', () {
      var locale = 'en-Latn'.toLocale();
      expect(locale.languageCode, 'en');
      expect(locale.scriptCode, 'Latn');
      expect(locale.countryCode, isNull);

      locale = 'en_latn'.toLocale();
      expect(locale.languageCode, 'en');
      expect(locale.scriptCode, 'Latn');
      expect(locale.countryCode, isNull);
    });

    test('handles invalid empty string', () {
      expect(''.toLocale(), const Locale('und'));
    });

    test('cannot fix some invalid language tags, then simply returns an invalid Locale',
        () {
      expect('xyz123'.toLocale(), const Locale('xyz123'));
      expect('abc-'.toLocale(), const Locale('abc'));
      expect('-abc'.toLocale(), const Locale('abc'));
    });
  });

  group('StringFromLocaleExtension.format', () {
    test('formats locale with lowercase country code', () {
      const locale = Locale('en', 'us');
      expect(locale.format(), equals('en-US'));
    });

    test('formats locale with uppercase country code', () {
      const locale = Locale('en', 'US');
      expect(locale.format(), equals('en-US'));
    });

    test('formats locale with language, script, and country', () {
      const locale =
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN');
      expect(locale.format(), equals('zh-Hans-CN'));
    });

    test('formats locale with language and script, no country', () {
      const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');
      expect(locale.format(), equals('sr-Latn'));
    });

    test('formats locale with different separator', () {
      const locale = Locale('en', 'US');
      expect(locale.format(separator: '|'), equals('en|US'));
    });

    test('formats locale with uppercase language code', () {
      const locale = Locale('EN', 'US');
      expect(locale.format(), equals('en-US'));
    });

    test('formats locale with lowercase script and country codes', () {
      const locale =
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'hans', countryCode: 'cn');
      expect(locale.format(), equals('zh-Hans-CN'));
    });

    test('formats locale with only language code', () {
      const locale = Locale('en');
      expect(locale.format(), equals('en'));
    });

    test('formats locale with language and script, missing country', () {
      const locale = Locale.fromSubtags(languageCode: 'es', scriptCode: 'Latn');
      expect(locale.format(), equals('es-Latn'));
    });

    test('formats invalid locale as "und" (undefined)', () {
      const locale = Locale(' ', ' ');
      expect(locale.format(), 'und');
    });

    test('formats locale with multiple separators', () {
      const locale = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

      expect(locale.format(separator: '_'), equals('zh_Hans_CN'));
    });

    test('handles empty script and country codes gracefully', () {
      const locale = Locale.fromSubtags(
        languageCode: 'fr',
        scriptCode: null,
        countryCode: null,
      );

      expect(locale.format(), equals('fr'));
    });

    test('handles null script and country codes gracefully', () {
      const locale = Locale.fromSubtags(languageCode: 'de');
      expect(locale.format(), equals('de'));
    });
  });
}
