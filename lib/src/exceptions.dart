import 'package:i18n_extension/i18n_extension.dart';

/// Thrown by the loaders ([I18nLoader]) when a translations file or resource
/// could not be read, when loading translations with `Translations.byFile()` or
/// `Translations.byHttp()`: for example, a 404 or network error, or an asset that
/// fails to load (which on the web is also a download).
///
/// The [resource] is the asset path or url that failed, and [error] is the error
/// thrown while reading it. Whether this failure fails the whole load, or is only
/// reported to [I18n.failedResourceCallback] and skipped, is controlled by the
/// `failOnMissingResource` flag of the translations object.
///
/// See also: [InvalidTranslationsResourceException], for a file or resource that
/// was read, but is invalid.
///
class MissingTranslationsResourceException extends TranslationsException {
  //
  /// The asset path (like `assets/translations/es.json`) or url (like
  /// `https://example.com/translations/es.json`) that could not be read.
  final String resource;

  /// The error thrown while reading the [resource]: for example, a
  /// `ClientException` for a 404 or a network error, or a `FlutterError` for an
  /// asset that fails to load.
  final Object error;

  /// Creates the exception for the [resource] that could not be read, because of
  /// the given [error]. The message is `Error reading <resource>: <error>`.
  MissingTranslationsResourceException(this.resource, this.error)
      : super('Error reading $resource: $error');

  @override
  String toString() => 'MissingTranslationsResourceException{msg: $msg}';

  /// Two exceptions are equal if they have the same [resource] and message (which
  /// includes the text of the [error]).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissingTranslationsResourceException &&
          runtimeType == other.runtimeType &&
          resource == other.resource &&
          msg == other.msg;

  @override
  int get hashCode => Object.hash(resource, msg);
}

/// Thrown by the loaders ([I18nLoader]) when a translations file or resource was
/// read, but is invalid, when loading translations with `Translations.byFile()`
/// or `Translations.byHttp()`: it could not be decoded (invalid JSON, YAML, ARB,
/// or ICU message), or it has invalid content (for example, a value that is not
/// a String, or a map of versions without the `other` version).
///
/// The [resource] is the asset path or url that failed, and [error] is the error
/// thrown while decoding or checking it. Whether this failure fails the whole
/// load, or is only reported to [I18n.failedResourceCallback] and skipped, is
/// controlled by the `failOnInvalidResource` flag of the translations object.
///
/// See also: [MissingTranslationsResourceException], for a file or resource that
/// could not be read.
///
class InvalidTranslationsResourceException extends TranslationsException {
  //
  /// The asset path (like `assets/translations/es.json`) or url (like
  /// `https://example.com/translations/es.json`) that is invalid.
  final String resource;

  /// The error thrown while decoding or checking the [resource]: for example, a
  /// `FormatException` for invalid JSON, or for a value that is not a String.
  final Object error;

  /// Creates the exception for the [resource] that is invalid, because of the
  /// given [error]. The message is `Error decoding <resource>: <error>`.
  InvalidTranslationsResourceException(this.resource, this.error)
      : super('Error decoding $resource: $error');

  @override
  String toString() => 'InvalidTranslationsResourceException{msg: $msg}';

  /// Two exceptions are equal if they have the same [resource] and message (which
  /// includes the text of the [error]).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidTranslationsResourceException &&
          runtimeType == other.runtimeType &&
          resource == other.resource &&
          msg == other.msg;

  @override
  int get hashCode => Object.hash(resource, msg);
}
