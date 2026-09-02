import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/src/i18n_json_loader.dart';

import 'loader_test_utils.dart';

/// Tests for the `failOnMissingResource` flag of [Translations.byFile] and
/// [Translations.byHttp], which is applied by [I18nLoader.fromAssetDir],
/// [I18nLoader.fromUrl], and the `defaultLoadByFile`/`defaultLoadByHttp` methods.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dir = 'assets/translations';
  const enUs = '$dir/en-US.json';
  const esEs = '$dir/es-ES.json';
  const ptBr = '$dir/pt-BR.json';

  const baseUrl = 'https://example.com/translations';
  const enUsUrl = '$baseUrl/en-US.json';
  const esEsUrl = '$baseUrl/es-ES.json';
  const ptBrUrl = '$baseUrl/pt-BR.json';

  const goodEnUs = '{"Hello": "Hello", "Goodbye": "Goodbye"}';
  const goodEsEs = '{"Hello": "Hola", "Goodbye": "Adiós"}';
  const goodPtBr = '{"Hello": "Olá", "Goodbye": "Adeus"}';

  /// Invalid JSON (truncated).
  const corrupt = '{"Hello": "Hola", ';

  /// Valid JSON, but one of the values is not a String.
  const notString = '{"Hello": "Olá", "Goodbye": 123}';

  /// Records every call to [I18n.failedResourceCallback] as (resource, error).
  late List<(String, Object)> failures;

  setUp(() {
    I18nTranslationsExtension.initLoadProcess();
    failures = [];
    I18n.failedResourceCallback =
        (resource, error) => failures.add((resource, error));
  });

  tearDown(() {
    I18n.failedResourceCallback = I18n.defaultFailedResourceCallback;
    rootBundle.clear();
  });

  group('I18nLoader.fromAssetDir', () {
    //
    test(
        'failOnMissingResource: false — '
        'a corrupt file is skipped, and the other files still load', () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var result = await I18nJsonLoader()
          .fromAssetDir(dir, failOnMissingResource: false);

      expect(result, {
        'Hello': {'en-US': 'Hello', 'pt-BR': 'Olá'},
        'Goodbye': {'en-US': 'Goodbye', 'pt-BR': 'Adeus'},
      });

      expect(failures.map((f) => f.$1), [esEs]);
      expect(failures.single.$2,
          isTranslationsException(startsWith('Error decoding $esEs: ')));
    });

    test(
        'failOnMissingResource: false — '
        'a file with a non-String value is skipped as a whole', () async {
      mockAssets({enUs: goodEnUs, ptBr: notString});

      var result = await I18nJsonLoader()
          .fromAssetDir(dir, failOnMissingResource: false);

      // The good entry ("Hello") of the bad file is not kept either:
      // a file is either fully loaded or fully skipped.
      expect(result, {
        'Hello': {'en-US': 'Hello'},
        'Goodbye': {'en-US': 'Goodbye'},
      });

      expect(failures.map((f) => f.$1), [ptBr]);
      expect(
          failures.single.$2,
          isTranslationsException(
              "Error in $ptBr: Value '123' for key 'Goodbye' is not a String."));
    });

    test(
        'failOnMissingResource: false — '
        'a file that cannot be read from the bundle is skipped', () async {
      mockAssets({enUs: goodEnUs, esEs: null});

      var result = await I18nJsonLoader()
          .fromAssetDir(dir, failOnMissingResource: false);

      expect(result, {
        'Hello': {'en-US': 'Hello'},
        'Goodbye': {'en-US': 'Goodbye'},
      });

      expect(failures.map((f) => f.$1), [esEs]);
      expect(failures.single.$2, isA<FlutterError>());
    });

    test(
        'failOnMissingResource: false — '
        'when all files fail, it returns an empty map and does not throw',
        () async {
      mockAssets({enUs: corrupt, esEs: notString, ptBr: null});

      var result = await I18nJsonLoader()
          .fromAssetDir(dir, failOnMissingResource: false);

      expect(result, isEmpty);
      expect(failures.map((f) => f.$1), unorderedEquals([enUs, esEs, ptBr]));
    });

    test(
        'failOnMissingResource: true (the default) — '
        'a corrupt file fails the whole load, as before', () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir),
        throwsA(isTranslationsException(startsWith('Error decoding $esEs: '))),
      );

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir, failOnMissingResource: true),
        throwsA(isTranslationsException(startsWith('Error decoding $esEs: '))),
      );

      // The callback is not called in this case.
      expect(failures, isEmpty);
    });

    test(
        'failOnMissingResource: true (the default) — '
        'a non-String value fails the whole load, as before', () async {
      mockAssets({enUs: goodEnUs, ptBr: notString});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir),
        throwsA(isTranslationsException(
            "Error in $ptBr: Value '123' for key 'Goodbye' is not a String.")),
      );

      expect(failures, isEmpty);
    });

    test('The default callback prints the failed resource and the error',
        () async {
      I18n.failedResourceCallback = I18n.defaultFailedResourceCallback;
      mockAssets({enUs: goodEnUs, esEs: corrupt});

      var printed = <String>[];

      await runZoned(
        () => I18nJsonLoader().fromAssetDir(dir, failOnMissingResource: false),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      );

      expect(
        printed,
        contains(startsWith('Failed to load $esEs (skipping it): '
            'TranslationsException{msg: Error decoding $esEs: ')),
      );
    });
  });

  group('I18nLoader.fromUrl', () {
    //
    test(
        'failOnMissingResource: false — '
        'a 404 is skipped, returning an empty map', () async {
      var result = await withMockHttp(
        {enUsUrl: goodEnUs},
        () => I18nJsonLoader().fromUrl(esEsUrl, failOnMissingResource: false),
      );

      expect(result, isEmpty);
      expect(failures.map((f) => f.$1), [esEsUrl]);
      expect(failures.single.$2,
          isTranslationsException(startsWith('Error reading $esEsUrl: ')));
    });

    test(
        'failOnMissingResource: false — '
        'a corrupt resource is skipped, returning an empty map', () async {
      var result = await withMockHttp(
        {esEsUrl: corrupt},
        () => I18nJsonLoader().fromUrl(esEsUrl, failOnMissingResource: false),
      );

      expect(result, isEmpty);
      expect(failures.map((f) => f.$1), [esEsUrl]);
      expect(failures.single.$2,
          isTranslationsException(startsWith('Error decoding $esEsUrl: ')));
    });

    test('failOnMissingResource: false — a good resource loads normally',
        () async {
      var result = await withMockHttp(
        {esEsUrl: goodEsEs},
        () => I18nJsonLoader().fromUrl(esEsUrl, failOnMissingResource: false),
      );

      expect(result, {
        'Hello': {'es-ES': 'Hola'},
        'Goodbye': {'es-ES': 'Adiós'},
      });
      expect(failures, isEmpty);
    });

    test('failOnMissingResource: true (the default) — a 404 throws, as before',
        () async {
      await withMockHttp({enUsUrl: goodEnUs}, () async {
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl),
          throwsA(
              isTranslationsException(startsWith('Error reading $esEsUrl: '))),
        );
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl, failOnMissingResource: true),
          throwsA(
              isTranslationsException(startsWith('Error reading $esEsUrl: '))),
        );
      });

      expect(failures, isEmpty);
    });

    test(
        'failOnMissingResource: true (the default) — '
        'a corrupt resource throws, as before', () async {
      await withMockHttp({esEsUrl: corrupt}, () async {
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl),
          throwsA(
              isTranslationsException(startsWith('Error decoding $esEsUrl: '))),
        );
      });

      expect(failures, isEmpty);
    });
  });

  group('Translations.byHttp (defaultLoadByHttp)', () {
    //
    test(
        'failOnMissingResource: false — '
        'one 404 among several resources: the others are loaded and merged',
        () async {
      await withMockHttp({enUsUrl: goodEnUs, ptBrUrl: goodPtBr}, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['en-US.json', 'es-ES.json', 'pt-BR.json'],
          failOnMissingResource: false,
        );

        await t.load();

        expect(t.translationByLocale_ByTranslationKey, {
          'Hello': {'en-US': 'Hello', 'pt-BR': 'Olá'},
          'Goodbye': {'en-US': 'Goodbye', 'pt-BR': 'Adeus'},
        });

        expect(localize('Hello', t, languageTag: 'pt-BR'), 'Olá');

        // Spanish was not loaded, so it falls back to the default locale.
        expect(localize('Hello', t, languageTag: 'es-ES'), 'Hello');
      });

      expect(failures.map((f) => f.$1), [esEsUrl]);
      expect(failures.single.$2,
          isTranslationsException(startsWith('Error reading $esEsUrl: ')));
    });

    test(
        'failOnMissingResource: false — '
        'when all resources fail, load() completes, and the app falls back '
        'to the default-locale strings', () async {
      await withMockHttp({}, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['en-US.json', 'es-ES.json'],
          failOnMissingResource: false,
        );

        await t.load();

        expect(t.translationByLocale_ByTranslationKey, isEmpty);
        expect(localize('Hello', t, languageTag: 'es-ES'), 'Hello');
      });

      expect(failures.map((f) => f.$1), unorderedEquals([enUsUrl, esEsUrl]));
    });

    test(
        'failOnMissingResource: true (the default) — '
        'one 404 fails the whole load, and nothing is merged, as before',
        () async {
      await withMockHttp({enUsUrl: goodEnUs, ptBrUrl: goodPtBr}, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['en-US.json', 'es-ES.json', 'pt-BR.json'],
        );

        await expectLater(
          t.load(),
          throwsA(isTranslationsException(contains('Error reading $esEsUrl'))),
        );

        expect(t.translationByLocale_ByTranslationKey, isEmpty);
      });

      expect(failures, isEmpty);
    });
  });

  group('Translations.byFile (defaultLoadByFile)', () {
    //
    test(
        'failOnMissingResource: false — '
        'one corrupt file among several: the others are loaded and merged',
        () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var t = Translations.byFile(
        'en-US',
        dir: dir,
        failOnMissingResource: false,
      );

      await t.load();

      expect(t.translationByLocale_ByTranslationKey, {
        'Hello': {'en-US': 'Hello', 'pt-BR': 'Olá'},
        'Goodbye': {'en-US': 'Goodbye', 'pt-BR': 'Adeus'},
      });

      expect(localize('Hello', t, languageTag: 'pt-BR'), 'Olá');
      expect(localize('Hello', t, languageTag: 'es-ES'), 'Hello');

      expect(failures.map((f) => f.$1), [esEs]);
    });

    test(
        'failOnMissingResource: false — '
        'when all files fail, load() completes with empty translations',
        () async {
      mockAssets({enUs: corrupt, esEs: corrupt});

      var t = Translations.byFile(
        'en-US',
        dir: dir,
        failOnMissingResource: false,
      );

      await t.load();

      expect(t.translationByLocale_ByTranslationKey, isEmpty);
      expect(localize('Hello', t, languageTag: 'es-ES'), 'Hello');
      expect(failures.map((f) => f.$1), unorderedEquals([enUs, esEs]));
    });

    test(
        'failOnMissingResource: true (the default) — '
        'one corrupt file fails the whole load, and nothing is merged, as before',
        () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var t = Translations.byFile('en-US', dir: dir);

      await expectLater(
        t.load(),
        throwsA(isTranslationsException(contains('Error decoding $esEs'))),
      );

      expect(t.translationByLocale_ByTranslationKey, isEmpty);
      expect(failures, isEmpty);
    });

    testWidgets(
        'failOnMissingResource: false — '
        'partially loaded translations trigger a rebuild of the I18n widget',
        (WidgetTester tester) async {
      //
      // The assets are only served after the gate opens, so that the
      // translations finish loading only after the first frame was built.
      var gate = Completer<void>();
      mockAssets({enUs: goodEnUs, esEs: goodEsEs, ptBr: corrupt},
          gate: gate.future);

      var t = Translations.byFile(
        'en-US',
        dir: dir,
        failOnMissingResource: false,
      );

      var builds = 0;

      await tester.pumpWidget(
        I18n(
          child: Builder(
            builder: (context) {
              builds++;
              return Text(
                localize('Hello', t, languageTag: 'es-ES'),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      );

      // Nothing loaded yet: falls back to the key.
      expect(find.text('Hello'), findsOneWidget);
      var buildsBeforeLoad = builds;

      gate.complete();
      await tester.pump();
      await tester.pump();

      // The good files were merged, and the widget was rebuilt.
      expect(find.text('Hola'), findsOneWidget);
      expect(builds, greaterThan(buildsBeforeLoad));
      expect(failures.map((f) => f.$1), [ptBr]);
    });
  });
}
