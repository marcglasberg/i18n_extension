import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:i18n_extension/i18n_extension.dart';

import 'loader_test_utils.dart';

/// Tests for the `failOnMissingResource` and `failOnInvalidResource` flags of
/// [Translations.byFile] and [Translations.byHttp], which are applied by
/// [I18nLoader.fromAssetDir], [I18nLoader.fromUrl], and the
/// `defaultLoadByFile`/`defaultLoadByHttp` methods.
///
/// A resource is "missing" when it cannot be read: a 404 or network error, or an
/// asset that fails to load. It's "invalid" when it was read, but cannot be
/// decoded, or has invalid content, like a value that is not a String. The
/// errors are a [MissingTranslationsResourceException] or an [InvalidTranslationsResourceException].
///
/// Note the core package wraps the error that fails `load()` in a plain
/// [TranslationsException], whose message contains the typed exception. The
/// [I18n.failedResourceCallback] receives the typed exception itself.
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

  /// Matches a [MissingTranslationsResourceException] whose message matches [msg].
  Matcher isMissing(Object msg) => isA<MissingTranslationsResourceException>()
      .having((e) => e.msg, 'msg', msg);

  /// Matches an [InvalidTranslationsResourceException] whose message matches [msg].
  Matcher isInvalid(Object msg) => isA<InvalidTranslationsResourceException>()
      .having((e) => e.msg, 'msg', msg);

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
        'failOnInvalidResource: false — '
        'a corrupt file is skipped, and the other files still load', () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var result = await I18nJsonLoader()
          .fromAssetDir(dir, failOnInvalidResource: false);

      expect(result, {
        'Hello': {'en-US': 'Hello', 'pt-BR': 'Olá'},
        'Goodbye': {'en-US': 'Goodbye', 'pt-BR': 'Adeus'},
      });

      expect(failures.map((f) => f.$1), [esEs]);
      expect(
          failures.single.$2, isInvalid(startsWith('Error decoding $esEs: ')));
    });

    test(
        'failOnInvalidResource: false — '
        'a file with a non-String value is skipped as a whole', () async {
      mockAssets({enUs: goodEnUs, ptBr: notString});

      var result = await I18nJsonLoader()
          .fromAssetDir(dir, failOnInvalidResource: false);

      // The good entry ("Hello") of the bad file is not kept either:
      // a file is either fully loaded or fully skipped.
      expect(result, {
        'Hello': {'en-US': 'Hello'},
        'Goodbye': {'en-US': 'Goodbye'},
      });

      expect(failures.map((f) => f.$1), [ptBr]);
      expect(
          failures.single.$2,
          isInvalid(
              "Error decoding $ptBr: FormatException: Value '123' for key 'Goodbye' is not a String."));
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
      expect(
          failures.single.$2, isMissing(startsWith('Error reading $esEs: ')));
    });

    test('failOnMissingResource: false does NOT skip an invalid file',
        () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir, failOnMissingResource: false),
        throwsA(isInvalid(startsWith('Error decoding $esEs: '))),
      );

      expect(failures, isEmpty);
    });

    test(
        'failOnInvalidResource: false does NOT skip a file that cannot be read',
        () async {
      mockAssets({enUs: goodEnUs, esEs: null});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir, failOnInvalidResource: false),
        throwsA(isMissing(startsWith('Error reading $esEs: '))),
      );

      expect(failures, isEmpty);
    });

    test(
        'Both flags false — '
        'when all files fail, it returns an empty map and does not throw',
        () async {
      mockAssets({enUs: corrupt, esEs: notString, ptBr: null});

      var result = await I18nJsonLoader().fromAssetDir(dir,
          failOnMissingResource: false, failOnInvalidResource: false);

      expect(result, isEmpty);
      expect(failures.map((f) => f.$1), unorderedEquals([enUs, esEs, ptBr]));

      expect(failures.singleWhere((f) => f.$1 == enUs).$2,
          isInvalid(startsWith('Error decoding $enUs: ')));
      expect(failures.singleWhere((f) => f.$1 == esEs).$2,
          isInvalid(startsWith('Error decoding $esEs: ')));
      expect(failures.singleWhere((f) => f.$1 == ptBr).$2,
          isMissing(startsWith('Error reading $ptBr: ')));
    });

    test(
        'Both flags true (the default) — '
        'a corrupt file fails the whole load, as before', () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir),
        throwsA(isInvalid(startsWith('Error decoding $esEs: '))),
      );

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir,
            failOnMissingResource: true, failOnInvalidResource: true),
        throwsA(isInvalid(startsWith('Error decoding $esEs: '))),
      );

      // The callback is not called in this case.
      expect(failures, isEmpty);
    });

    test(
        'Both flags true (the default) — '
        'a non-String value fails the whole load, as before', () async {
      mockAssets({enUs: goodEnUs, ptBr: notString});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir),
        throwsA(isInvalid(
            "Error decoding $ptBr: FormatException: Value '123' for key 'Goodbye' is not a String.")),
      );

      expect(failures, isEmpty);
    });

    test(
        'Both flags true (the default) — '
        'a file that cannot be read fails the whole load', () async {
      mockAssets({enUs: goodEnUs, esEs: null});

      await expectLater(
        I18nJsonLoader().fromAssetDir(dir),
        throwsA(isMissing(startsWith('Error reading $esEs: '))),
      );

      expect(failures, isEmpty);
    });

    test('The exceptions carry the resource and the underlying error',
        () async {
      mockAssets({enUs: corrupt, esEs: notString, ptBr: null});

      await I18nJsonLoader().fromAssetDir(dir,
          failOnMissingResource: false, failOnInvalidResource: false);

      var corruptFile = failures.singleWhere((f) => f.$1 == enUs).$2
          as InvalidTranslationsResourceException;
      expect(corruptFile.resource, enUs);
      expect(corruptFile.error, isA<FormatException>());

      var notStringFile = failures.singleWhere((f) => f.$1 == esEs).$2
          as InvalidTranslationsResourceException;
      expect(notStringFile.resource, esEs);
      expect(
          notStringFile.error,
          isA<FormatException>().having((e) => e.message, 'message',
              "Value '123' for key 'Goodbye' is not a String."));

      var unreadableFile = failures.singleWhere((f) => f.$1 == ptBr).$2
          as MissingTranslationsResourceException;
      expect(unreadableFile.resource, ptBr);
      expect(unreadableFile.error, isA<FlutterError>());
    });

    test('The errors are TranslationsExceptions', () async {
      mockAssets({enUs: corrupt, esEs: null});

      await I18nJsonLoader().fromAssetDir(dir,
          failOnMissingResource: false, failOnInvalidResource: false);

      expect(failures.map((f) => f.$2),
          everyElement(isA<TranslationsException>()));
    });

    test('The default callback prints the failed resource and the error',
        () async {
      I18n.failedResourceCallback = I18n.defaultFailedResourceCallback;
      mockAssets({enUs: goodEnUs, esEs: corrupt});

      var printed = <String>[];

      await runZoned(
        () => I18nJsonLoader().fromAssetDir(dir, failOnInvalidResource: false),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      );

      expect(
        printed,
        contains(startsWith('Failed to load $esEs (skipping it): '
            'InvalidTranslationsResourceException{msg: Error decoding $esEs: ')),
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
          isMissing(startsWith('Error reading $esEsUrl: ')));
    });

    test('The 404 exception carries the url and the ClientException', () async {
      await withMockHttp(
        {enUsUrl: goodEnUs},
        () => I18nJsonLoader().fromUrl(esEsUrl, failOnMissingResource: false),
      );

      var missing = failures.single.$2 as MissingTranslationsResourceException;
      expect(missing.resource, esEsUrl);
      expect(missing.error, isA<ClientException>());
    });

    test(
        'failOnInvalidResource: false — '
        'a corrupt resource is skipped, returning an empty map', () async {
      var result = await withMockHttp(
        {esEsUrl: corrupt},
        () => I18nJsonLoader().fromUrl(esEsUrl, failOnInvalidResource: false),
      );

      expect(result, isEmpty);
      expect(failures.map((f) => f.$1), [esEsUrl]);
      expect(failures.single.$2,
          isInvalid(startsWith('Error decoding $esEsUrl: ')));
    });

    test('failOnMissingResource: false does NOT skip a corrupt resource',
        () async {
      await withMockHttp({esEsUrl: corrupt}, () async {
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl, failOnMissingResource: false),
          throwsA(isInvalid(startsWith('Error decoding $esEsUrl: '))),
        );
      });

      expect(failures, isEmpty);
    });

    test('failOnInvalidResource: false does NOT skip a 404', () async {
      await withMockHttp({enUsUrl: goodEnUs}, () async {
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl, failOnInvalidResource: false),
          throwsA(isMissing(startsWith('Error reading $esEsUrl: '))),
        );
      });

      expect(failures, isEmpty);
    });

    test('Both flags false — a good resource loads normally', () async {
      var result = await withMockHttp(
        {esEsUrl: goodEsEs},
        () => I18nJsonLoader().fromUrl(esEsUrl,
            failOnMissingResource: false, failOnInvalidResource: false),
      );

      expect(result, {
        'Hello': {'es-ES': 'Hola'},
        'Goodbye': {'es-ES': 'Adiós'},
      });
      expect(failures, isEmpty);
    });

    test('Both flags true (the default) — a 404 throws, as before', () async {
      await withMockHttp({enUsUrl: goodEnUs}, () async {
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl),
          throwsA(isMissing(startsWith('Error reading $esEsUrl: '))),
        );
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl,
              failOnMissingResource: true, failOnInvalidResource: true),
          throwsA(isMissing(startsWith('Error reading $esEsUrl: '))),
        );
      });

      expect(failures, isEmpty);
    });

    test(
        'Both flags true (the default) — '
        'a corrupt resource throws, as before', () async {
      await withMockHttp({esEsUrl: corrupt}, () async {
        await expectLater(
          I18nJsonLoader().fromUrl(esEsUrl),
          throwsA(isInvalid(startsWith('Error decoding $esEsUrl: '))),
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
          isMissing(startsWith('Error reading $esEsUrl: ')));
    });

    test(
        'failOnInvalidResource: false — '
        'one corrupt resource among several: the others are loaded and merged',
        () async {
      await withMockHttp(
          {enUsUrl: goodEnUs, esEsUrl: corrupt, ptBrUrl: goodPtBr}, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['en-US.json', 'es-ES.json', 'pt-BR.json'],
          failOnInvalidResource: false,
        );

        await t.load();

        expect(t.translationByLocale_ByTranslationKey, {
          'Hello': {'en-US': 'Hello', 'pt-BR': 'Olá'},
          'Goodbye': {'en-US': 'Goodbye', 'pt-BR': 'Adeus'},
        });
      });

      expect(failures.map((f) => f.$1), [esEsUrl]);
      expect(failures.single.$2,
          isInvalid(startsWith('Error decoding $esEsUrl: ')));
    });

    test(
        'failOnMissingResource: false — '
        'a corrupt resource still fails the whole load', () async {
      await withMockHttp(
          {enUsUrl: goodEnUs, esEsUrl: corrupt, ptBrUrl: goodPtBr}, () async {
        var t = Translations.byHttp(
          'en-US',
          url: baseUrl,
          resources: ['en-US.json', 'es-ES.json', 'pt-BR.json'],
          failOnMissingResource: false,
        );

        await expectLater(
          t.load(),
          throwsA(isTranslationsException(contains(
              'InvalidTranslationsResourceException{msg: Error decoding $esEsUrl'))),
        );

        expect(t.translationByLocale_ByTranslationKey, isEmpty);
      });

      expect(failures, isEmpty);
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
        'Both flags true (the default) — '
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
          throwsA(isTranslationsException(contains(
              'MissingTranslationsResourceException{msg: Error reading $esEsUrl'))),
        );

        expect(t.translationByLocale_ByTranslationKey, isEmpty);
      });

      expect(failures, isEmpty);
    });
  });

  group('Translations.byFile (defaultLoadByFile)', () {
    //
    test(
        'failOnInvalidResource: false — '
        'one corrupt file among several: the others are loaded and merged',
        () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var t = Translations.byFile(
        'en-US',
        dir: dir,
        failOnInvalidResource: false,
      );

      await t.load();

      expect(t.translationByLocale_ByTranslationKey, {
        'Hello': {'en-US': 'Hello', 'pt-BR': 'Olá'},
        'Goodbye': {'en-US': 'Goodbye', 'pt-BR': 'Adeus'},
      });

      expect(localize('Hello', t, languageTag: 'pt-BR'), 'Olá');
      expect(localize('Hello', t, languageTag: 'es-ES'), 'Hello');

      expect(failures.map((f) => f.$1), [esEs]);
      expect(
          failures.single.$2, isInvalid(startsWith('Error decoding $esEs: ')));
    });

    test(
        'failOnMissingResource: false — '
        'one file that cannot be read among several: the others are loaded',
        () async {
      mockAssets({enUs: goodEnUs, esEs: null, ptBr: goodPtBr});

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

      expect(failures.map((f) => f.$1), [esEs]);
      expect(
          failures.single.$2, isMissing(startsWith('Error reading $esEs: ')));
    });

    test(
        'failOnMissingResource: false — '
        'a corrupt file still fails the whole load', () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var t = Translations.byFile(
        'en-US',
        dir: dir,
        failOnMissingResource: false,
      );

      await expectLater(
        t.load(),
        throwsA(isTranslationsException(contains(
            'InvalidTranslationsResourceException{msg: Error decoding $esEs'))),
      );

      expect(t.translationByLocale_ByTranslationKey, isEmpty);
      expect(failures, isEmpty);
    });

    test(
        'failOnInvalidResource: false — '
        'when all files fail, load() completes with empty translations',
        () async {
      mockAssets({enUs: corrupt, esEs: corrupt});

      var t = Translations.byFile(
        'en-US',
        dir: dir,
        failOnInvalidResource: false,
      );

      await t.load();

      expect(t.translationByLocale_ByTranslationKey, isEmpty);
      expect(localize('Hello', t, languageTag: 'es-ES'), 'Hello');
      expect(failures.map((f) => f.$1), unorderedEquals([enUs, esEs]));
    });

    test(
        'Both flags true (the default) — '
        'one corrupt file fails the whole load, and nothing is merged, as before',
        () async {
      mockAssets({enUs: goodEnUs, esEs: corrupt, ptBr: goodPtBr});

      var t = Translations.byFile('en-US', dir: dir);

      await expectLater(
        t.load(),
        throwsA(isTranslationsException(contains(
            'InvalidTranslationsResourceException{msg: Error decoding $esEs'))),
      );

      expect(t.translationByLocale_ByTranslationKey, isEmpty);
      expect(failures, isEmpty);
    });

    testWidgets(
        'failOnInvalidResource: false — '
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
        failOnInvalidResource: false,
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
