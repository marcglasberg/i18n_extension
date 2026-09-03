import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';

/// Tests for [MissingTranslationsResourceException] and
/// [InvalidTranslationsResourceException], which are thrown by the loaders
/// ([I18nLoader]) and received by [I18n.failedResourceCallback]. The loading
/// itself is tested in `fail_on_missing_resource_test.dart`.
void main() {
  const resource = 'assets/translations/en-US.json';

  group('MissingTranslationsResourceException', () {
    //
    final error = Exception('404');
    final exception = MissingTranslationsResourceException(resource, error);

    test('Is a TranslationsException, and not an invalid resource exception',
        () {
      expect(exception, isA<TranslationsException>());
      expect(exception, isNot(isA<InvalidTranslationsResourceException>()));
    });

    test('Carries the resource, the error, and a message with both', () {
      expect(exception.resource, resource);
      expect(exception.error, same(error));
      expect(exception.msg, 'Error reading $resource: Exception: 404');
    });

    test('toString uses its own class name', () {
      expect(
        exception.toString(),
        'MissingTranslationsResourceException'
        '{msg: Error reading $resource: Exception: 404}',
      );
    });

    test('Is equal to another one with the same resource and error text', () {
      var other =
          MissingTranslationsResourceException(resource, Exception('404'));
      expect(exception, other);
      expect(exception.hashCode, other.hashCode);
    });

    test('Is not equal to one with a different resource or error', () {
      expect(exception,
          isNot(MissingTranslationsResourceException('other.json', error)));
      expect(
          exception,
          isNot(MissingTranslationsResourceException(
              resource, Exception('500'))));
    });

    test('Is not equal to other exceptions with the same message', () {
      var plain = TranslationsException(exception.msg);
      expect(exception, isNot(plain));
      expect(plain, isNot(exception));
    });

    test('Can be caught as a TranslationsException', () {
      expect(
        () => throw exception,
        throwsA(isA<TranslationsException>().having(
            (e) => e.msg, 'msg', startsWith('Error reading $resource'))),
      );
    });
  });

  group('InvalidTranslationsResourceException', () {
    //
    const error = FormatException('Unexpected end of input');
    final exception = InvalidTranslationsResourceException(resource, error);

    test('Is a TranslationsException, and not a missing resource exception',
        () {
      expect(exception, isA<TranslationsException>());
      expect(exception, isNot(isA<MissingTranslationsResourceException>()));
    });

    test('Carries the resource, the error, and a message with both', () {
      expect(exception.resource, resource);
      expect(exception.error, same(error));
      expect(exception.msg,
          'Error decoding $resource: FormatException: Unexpected end of input');
    });

    test('toString uses its own class name', () {
      expect(
        exception.toString(),
        'InvalidTranslationsResourceException'
        '{msg: Error decoding $resource: FormatException: Unexpected end of input}',
      );
    });

    test('Is equal to another one with the same resource and error text', () {
      var other = InvalidTranslationsResourceException(
          resource, const FormatException('Unexpected end of input'));
      expect(exception, other);
      expect(exception.hashCode, other.hashCode);
    });

    test('Is not equal to one with a different resource or error', () {
      expect(exception,
          isNot(InvalidTranslationsResourceException('other.json', error)));
      expect(
          exception,
          isNot(InvalidTranslationsResourceException(
              resource, const FormatException('Other'))));
    });

    test('Is not equal to other exceptions with the same message', () {
      var plain = TranslationsException(exception.msg);
      expect(exception, isNot(plain));
      expect(plain, isNot(exception));

      // Not even a missing resource exception that happens to have the same text.
      var missing = MissingTranslationsResourceException(resource, error);
      expect(exception, isNot(missing));
      expect(missing, isNot(exception));
    });

    test('Can be caught as a TranslationsException', () {
      expect(
        () => throw exception,
        throwsA(isA<TranslationsException>().having(
            (e) => e.msg, 'msg', startsWith('Error decoding $resource'))),
      );
    });
  });
}
