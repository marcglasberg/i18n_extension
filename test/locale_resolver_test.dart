import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

void main() {
  const ptPT = Locale('pt', 'PT');
  const ptBR = Locale('pt', 'BR');
  const enUS = Locale('en', 'US');
  const enGB = Locale('en', 'GB');
  const frFR = Locale('fr', 'FR');
  const deDE = Locale('de', 'DE');

  group('I18n.exactMatchResolver', () {
    //
    test('Picks the first device locale that exactly matches a supported locale',
        () {
      expect(I18n.exactMatchResolver([ptPT, enUS], [ptBR, enUS]), enUS);
      expect(I18n.exactMatchResolver([ptBR, enUS], [enUS, ptBR]), ptBR);
      expect(I18n.exactMatchResolver([frFR, deDE, enUS], [enUS, deDE]), deDE);
    });

    test('Does not match a different variant of the same language', () {
      // pt-PT is not pt-BR, so nothing matches: returns the first device locale.
      expect(I18n.exactMatchResolver([ptPT], [ptBR, enUS]), ptPT);
      expect(I18n.exactMatchResolver([ptPT, enGB], [ptBR, enUS]), ptPT);
    });

    test('Returns the first device locale when nothing matches', () {
      expect(I18n.exactMatchResolver([frFR, deDE], [ptBR, enUS]), frFR);
    });

    test('Returns the first device locale when supportedLocales is empty', () {
      expect(I18n.exactMatchResolver([ptPT, enUS], []), ptPT);
    });

    test('Compares normalized language tags', () {
      expect(I18n.exactMatchResolver([enUS], ['en-US'.asLocale]), enUS);
      expect(
        I18n.exactMatchResolver([const Locale('es')], [const Locale('es')]),
        const Locale('es'),
      );
    });

    test('Returns the preInitializationLocale when deviceLocales is empty', () {
      expect(
        I18n.exactMatchResolver([], [ptBR, enUS]),
        I18n.preInitializationLocale,
      );
    });
  });

  group('I18n.languageMatchResolver', () {
    //
    test(
        'Prefers a variant of the first device language '
        'over the second device language', () {
      expect(I18n.languageMatchResolver([ptPT, enUS], [ptBR, enUS]), ptBR);
      expect(I18n.languageMatchResolver([ptPT, enUS], [enUS, ptBR]), ptBR);
    });

    test('Returns the supported locale, not the device locale, on a partial match',
        () {
      expect(I18n.languageMatchResolver([ptPT], [ptBR, enUS]), ptBR);
      expect(I18n.languageMatchResolver([enGB], [ptBR, enUS]), enUS);
    });

    test('Still prefers an exact match when available', () {
      expect(I18n.languageMatchResolver([ptBR, enUS], [enUS, ptBR]), ptBR);
      expect(I18n.languageMatchResolver([enUS, ptPT], [ptBR, enUS]), enUS);
    });

    test(
        'Prefers an exact match of the second device locale over a language-only '
        'match of the first one, when both are the same language', () {
      expect(I18n.languageMatchResolver([ptPT, ptBR], [ptBR]), ptBR);
      expect(I18n.languageMatchResolver([ptPT, ptBR], [ptBR, ptPT]), ptPT);
    });

    test('Falls back to the second device language when the first is not supported',
        () {
      expect(I18n.languageMatchResolver([frFR, enGB], [ptBR, enUS]), enUS);
    });

    test('Returns the first supported locale when nothing matches', () {
      expect(I18n.languageMatchResolver([frFR, deDE], [ptBR, enUS]), ptBR);
      expect(I18n.languageMatchResolver([frFR, deDE], [enUS, ptBR]), enUS);
    });

    test('Returns the first device locale when supportedLocales is empty', () {
      expect(I18n.languageMatchResolver([ptPT, enUS], []), ptPT);
    });

    test('Returns the first supported locale when deviceLocales is empty', () {
      expect(I18n.languageMatchResolver([], [ptBR, enUS]), ptBR);
    });

    test('Returns the preInitializationLocale when both lists are empty', () {
      expect(I18n.languageMatchResolver([], []), I18n.preInitializationLocale);
    });
  });

  group('I18n widget with localeResolver', () {
    //
    testWidgets(
        'The default keeps the previous behavior: '
        'an exact match of the second device locale wins over a variant of the first',
        (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [ptPT, enUS];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [ptBR, enUS],
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(I18n.locale, enUS);
      expect(I18n.systemLocale, enUS);
      expect(I18n.forcedLocale, isNull);
    });

    testWidgets('languageMatchResolver picks a variant of the first device language',
        (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [ptPT, enUS];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [ptBR, enUS],
          localeResolver: I18n.languageMatchResolver,
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(I18n.locale, ptBR);
      expect(I18n.systemLocale, ptBR);
      expect(I18n.forcedLocale, isNull);
    });

    testWidgets(
        'languageMatchResolver returns the first supported locale '
        'when no device language is supported', (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [frFR, deDE];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [ptBR, enUS],
          localeResolver: I18n.languageMatchResolver,
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(I18n.locale, ptBR);
    });

    testWidgets(
        'languageMatchResolver resolves the undefined locale '
        'to the first supported locale', (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale.fromSubtags()];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [ptBR, enUS],
          localeResolver: I18n.languageMatchResolver,
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(I18n.locale, ptBR);
    });

    testWidgets('The resolver is applied again when the device locales change',
        (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [frFR, enGB];

      await tester.pumpWidget(
        I18n(
          supportedLocales: [ptBR, enUS],
          localeResolver: I18n.languageMatchResolver,
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(I18n.locale, enUS);

      tester.platformDispatcher.localesTestValue = [ptPT];
      tester.platformDispatcher.onLocaleChanged?.call();
      await tester.pumpAndSettle();

      expect(I18n.locale, ptBR);
    });

    testWidgets('A custom resolver receives the device and supported locales',
        (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [ptPT, enUS];

      List<Locale>? receivedDeviceLocales;
      Iterable<Locale>? receivedSupportedLocales;

      await tester.pumpWidget(
        I18n(
          supportedLocales: [ptBR, enUS, deDE],
          localeResolver: (deviceLocales, supportedLocales) {
            receivedDeviceLocales = deviceLocales;
            receivedSupportedLocales = supportedLocales;
            // Always picks the last supported locale.
            return supportedLocales.last;
          },
          child: MaterialApp(
            locale: I18n.locale,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(receivedDeviceLocales, [ptPT, enUS]);
      expect(receivedSupportedLocales, [ptBR, enUS, deDE]);
      expect(I18n.locale, deDE);
    });

    testWidgets('A forced locale wins over the resolver',
        (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [ptPT];

      late BuildContext capturedContext;

      await tester.pumpWidget(
        I18n(
          initialLocale: frFR,
          supportedLocales: [ptBR, enUS],
          localeResolver: I18n.languageMatchResolver,
          child: MaterialApp(
            locale: I18n.locale,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const Scaffold(body: Text('Test'));
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(I18n.locale, frFR);
      expect(I18n.forcedLocale, frFR);
      expect(I18n.systemLocale, ptBR);

      // Removing the forced locale goes back to the resolved system locale.
      I18n.of(capturedContext).locale = null;
      await tester.pumpAndSettle();

      expect(I18n.locale, ptBR);
      expect(I18n.forcedLocale, isNull);
    });

    testWidgets('Changing the resolver re-resolves the locale',
        (WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [ptPT, enUS];

      Widget app(LocaleResolver localeResolver) => I18n(
            supportedLocales: [ptBR, enUS],
            localeResolver: localeResolver,
            child: MaterialApp(
              locale: I18n.locale,
              home: const Scaffold(body: Text('Test')),
            ),
          );

      await tester.pumpWidget(app(I18n.exactMatchResolver));
      await tester.pumpAndSettle();
      expect(I18n.locale, enUS);

      await tester.pumpWidget(app(I18n.languageMatchResolver));
      await tester.pumpAndSettle();
      expect(I18n.locale, ptBR);

      await tester.pumpWidget(app(I18n.exactMatchResolver));
      await tester.pumpAndSettle();
      expect(I18n.locale, enUS);
    });
  });
}
