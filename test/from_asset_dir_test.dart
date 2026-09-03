import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'loader_test_utils.dart';

/// Tests for how [I18nLoader.fromAssetDir] selects which files to load,
/// given the directory.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const inDir = 'assets/translations/en-US.json';
  const inSubDir = 'assets/translations/more_translations/es-ES.json';
  const inSiblingDir = 'assets/translations_old/fr-FR.json';
  const elsewhere = 'assets/other/pt-BR.json';

  const files = {
    inDir: '{"Hello": "Hello"}',
    inSubDir: '{"Hello": "Hola"}',
    inSiblingDir: '{"Hello": "Bonjour"}',
    elsewhere: '{"Hello": "Olá"}',
  };

  setUp(() => mockAssets(files));
  tearDown(() => rootBundle.clear());

  test('Loads the files in the directory and in its subdirectories', () async {
    var result = await I18nJsonLoader().fromAssetDir('assets/translations');

    expect(result['Hello'], containsPair('en-US', 'Hello'));
    expect(result['Hello'], containsPair('es-ES', 'Hola'));
  });

  test(
      'Does NOT load files from a sibling directory '
      'that starts with the same text', () async {
    //
    // `assets/translations_old` starts with `assets/translations`, but it's a
    // different directory, so its files must not be loaded.
    var result = await I18nJsonLoader().fromAssetDir('assets/translations');

    expect(result['Hello'], isNot(contains('fr-FR')));
    expect(result['Hello'], isNot(contains('pt-BR')));

    expect(result, {
      'Hello': {'en-US': 'Hello', 'es-ES': 'Hola'},
    });
  });

  test('Works the same when the directory already ends with a slash', () async {
    var result = await I18nJsonLoader().fromAssetDir('assets/translations/');

    expect(result, {
      'Hello': {'en-US': 'Hello', 'es-ES': 'Hola'},
    });
  });

  test('An empty directory matches all assets', () async {
    var result = await I18nJsonLoader().fromAssetDir('');

    expect(result, {
      'Hello': {
        'en-US': 'Hello',
        'es-ES': 'Hola',
        'fr-FR': 'Bonjour',
        'pt-BR': 'Olá',
      },
    });
  });

  test('Loads nothing when the directory does not exist', () async {
    var result = await I18nJsonLoader().fromAssetDir('assets/translation');

    expect(result, isEmpty);
  });
}
