import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

void main() {
  group('Multi-locale fallback functionality', () {
    testWidgets('Should use second device locale when first is not supported',
        (WidgetTester tester) async {
      // Set multiple platform locales: Filipino (not supported), German (supported), English (supported)
      tester.platformDispatcher.localesTestValue = [
        const Locale('fil', 'PH'), // Filipino - not supported
        const Locale('de', 'DE'), // German - supported
        const Locale('en', 'US'), // English - supported
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: Builder(
              builder: (context) {
                return Text('Locale: ${I18n.locale.toLanguageTag()}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should select German (de-DE) as it's the first supported locale in the device list
      expect(I18n.locale.languageCode, 'de');
      expect(I18n.locale.countryCode, 'DE');
      expect(I18n.systemLocale.languageCode, 'de');
    });

    testWidgets('Should use third device locale when first two are not supported',
        (WidgetTester tester) async {
      // Set multiple platform locales where only the third is supported
      tester.platformDispatcher.localesTestValue = [
        const Locale('fil', 'PH'), // Filipino - not supported
        const Locale('ja', 'JP'), // Japanese - not supported
        const Locale('es', 'ES'), // Spanish - supported
        const Locale('en', 'US'), // English - supported
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: Builder(
              builder: (context) {
                return Text('Locale: ${I18n.locale.toLanguageTag()}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should select Spanish (es-ES) as it's the first supported locale
      expect(I18n.locale.languageCode, 'es');
      expect(I18n.locale.countryCode, 'ES');
    });

    testWidgets('Should use first device locale when it is supported',
        (WidgetTester tester) async {
      // Set multiple platform locales where the first is supported
      tester.platformDispatcher.localesTestValue = [
        const Locale('en', 'US'), // English - supported
        const Locale('de', 'DE'), // German - supported
        const Locale('es', 'ES'), // Spanish - supported
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should select English (en-US) as it's the first device locale and is supported
      expect(I18n.locale.languageCode, 'en');
      expect(I18n.locale.countryCode, 'US');
    });

    testWidgets('Should fallback to first device locale when none are supported',
        (WidgetTester tester) async {
      // Set multiple platform locales where none are supported
      tester.platformDispatcher.localesTestValue = [
        const Locale('fil', 'PH'), // Filipino - not supported
        const Locale('ja', 'JP'), // Japanese - not supported
        const Locale('ko', 'KR'), // Korean - not supported
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should fallback to Filipino (fil-PH) as it's the first device locale
      expect(I18n.locale.languageCode, 'fil');
      expect(I18n.locale.countryCode, 'PH');
    });

    testWidgets('Should handle empty supported locales list',
        (WidgetTester tester) async {
      // Set multiple platform locales
      tester.platformDispatcher.localesTestValue = [
        const Locale('en', 'US'),
        const Locale('de', 'DE'),
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [], // Empty supported locales
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should use the first device locale when supportedLocales is empty
      expect(I18n.locale.languageCode, 'en');
      expect(I18n.locale.countryCode, 'US');
    });

    testWidgets('Should update locale when system locales change at runtime',
        (WidgetTester tester) async {
      // Start with Filipino and English
      tester.platformDispatcher.localesTestValue = [
        const Locale('fil', 'PH'), // Not supported
        const Locale('en', 'US'), // Supported
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: Builder(
              builder: (context) {
                return Text('Locale: ${I18n.locale.toLanguageTag()}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should select English
      expect(I18n.locale.languageCode, 'en');
      expect(I18n.locale.countryCode, 'US');

      // Change system locales: now German is second (and supported)
      tester.platformDispatcher.localesTestValue = [
        const Locale('fil', 'PH'), // Not supported
        const Locale('de', 'DE'), // Supported - should be selected
        const Locale('en', 'US'), // Also supported but comes later
      ];

      // Trigger locale change
      tester.platformDispatcher.onLocaleChanged?.call();
      await tester.pumpAndSettle();

      // Should now select German as it comes before English
      expect(I18n.locale.languageCode, 'de');
      expect(I18n.locale.countryCode, 'DE');
    });

    testWidgets('Should handle locale with only language code (no country)',
        (WidgetTester tester) async {
      // Set platform locales with and without country codes
      tester.platformDispatcher.localesTestValue = [
        const Locale('zh'), // Chinese without country - not exactly supported
        const Locale('es'), // Spanish without country - supported
        const Locale('en', 'US'), // English with country - supported
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('es'), // Spanish without country
            const Locale('de', 'DE'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should select Spanish (es) as it matches
      expect(I18n.locale.languageCode, 'es');
      expect(I18n.locale.countryCode, null);
    });

    testWidgets('Should maintain forced locale even when system locales change',
        (WidgetTester tester) async {
      // Set initial platform locales
      tester.platformDispatcher.localesTestValue = [
        const Locale('en', 'US'),
      ];

      await tester.pumpWidget(
        I18n(
          initialLocale: const Locale('de', 'DE'), // Force German
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should use forced German locale
      expect(I18n.locale.languageCode, 'de');
      expect(I18n.locale.countryCode, 'DE');
      expect(I18n.forcedLocale?.languageCode, 'de');

      // Change system locales
      tester.platformDispatcher.localesTestValue = [
        const Locale('es', 'ES'),
        const Locale('en', 'US'),
      ];

      // Trigger locale change
      tester.platformDispatcher.onLocaleChanged?.call();
      await tester.pumpAndSettle();

      // Should still use forced German locale, not Spanish
      expect(I18n.locale.languageCode, 'de');
      expect(I18n.locale.countryCode, 'DE');
    });

    testWidgets('Should handle undefined locale gracefully',
        (WidgetTester tester) async {
      // Set undefined locale
      tester.platformDispatcher.localesTestValue = [
        const Locale.fromSubtags(), // Creates locale with 'und' language code
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When locale is undefined, the code returns it as-is (und)
      // This is the actual behavior based on the current implementation
      expect(I18n.locale.languageCode, 'und');
    });

    testWidgets('Should correctly match locales with script codes',
        (WidgetTester tester) async {
      // Set platform locales with script codes
      tester.platformDispatcher.localesTestValue = [
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN'), // Simplified Chinese
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW'), // Traditional Chinese
        const Locale('en', 'US'),
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale.fromSubtags(
                languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
            const Locale('de', 'DE'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should select Traditional Chinese as it's the first match
      expect(I18n.locale.languageCode, 'zh');
      expect(I18n.locale.scriptCode, 'Hant');
      expect(I18n.locale.countryCode, 'TW');
    });

    testWidgets('Instance locale getter should also use fallback logic',
        (WidgetTester tester) async {
      // Set multiple platform locales
      tester.platformDispatcher.localesTestValue = [
        const Locale('ja', 'JP'), // Japanese - not supported
        const Locale('de', 'DE'), // German - supported
        const Locale('en', 'US'), // English - also supported
      ];

      late BuildContext capturedContext;
      String debugInfo = '';

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                // Capture debug info during build
                debugInfo = 'During build: '
                    'I18n.locale=${I18n.locale.toLanguageTag()}, '
                    'I18n.systemLocale=${I18n.systemLocale.toLanguageTag()}, '
                    'context.locale=${I18n.of(context).locale.toLanguageTag()}';
                return Scaffold(body: Text(debugInfo));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debug: Print what we're seeing
      print('Debug info: $debugInfo');
      print('After settle: I18n.locale=${I18n.locale.toLanguageTag()}');
      print('After settle: I18n.systemLocale=${I18n.systemLocale.toLanguageTag()}');
      print('After settle: instance=${I18n.of(capturedContext).locale.toLanguageTag()}');

      // Test instance getter - this should use the resolved locale
      final instanceLocale = I18n.of(capturedContext).locale;

      // The instance locale should select German as it's the first supported match
      expect(instanceLocale.languageCode, 'de');
      expect(instanceLocale.countryCode, 'DE');

      // Test static getter after build - should also be resolved to German
      expect(I18n.locale.languageCode, 'de');
      expect(I18n.locale.countryCode, 'DE');

      // Both should be the same after resolution
      expect(instanceLocale, I18n.locale);
    });
  });

  group('Edge cases', () {
    testWidgets('Should handle empty platform locales list',
        (WidgetTester tester) async {
      // Set empty locales list
      tester.platformDispatcher.localesTestValue = [];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should use preInitializationLocale (default: es-US)
      expect(I18n.locale.languageCode, 'es');
      expect(I18n.locale.countryCode, 'US');
    });

    testWidgets('Should handle rapid locale changes',
        (WidgetTester tester) async {
      // Start with one set of locales
      tester.platformDispatcher.localesTestValue = [
        const Locale('en', 'US'),
      ];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
            const Locale('es', 'ES'),
          ],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(I18n.locale.languageCode, 'en');

      // Rapid changes
      tester.platformDispatcher.localesTestValue = [
        const Locale('de', 'DE'),
      ];
      tester.platformDispatcher.onLocaleChanged?.call();

      tester.platformDispatcher.localesTestValue = [
        const Locale('es', 'ES'),
      ];
      tester.platformDispatcher.onLocaleChanged?.call();

      tester.platformDispatcher.localesTestValue = [
        const Locale('en', 'US'),
      ];
      tester.platformDispatcher.onLocaleChanged?.call();

      await tester.pumpAndSettle();

      // Should end up with the last change
      expect(I18n.locale.languageCode, 'en');
      expect(I18n.locale.countryCode, 'US');
    });
  });
}