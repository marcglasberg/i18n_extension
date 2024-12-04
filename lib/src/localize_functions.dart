import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_core/src/core_localize_functions.dart' as core;

/// The [localize] function localizes a "translatable string" to the given [languageTag].
/// You must provide the [key], which is usually the string you want to translate, and
/// also the [translations] object which holds the translations.
///
/// The [languageTag] is a string like "en-US", "pt-BR", etc. If it's not provided
/// (i.e., it's null), it will use the default language tag found in [I18n.languageTag].
///
/// ---
///
/// Fallback order:
///
/// - If the translation to the exact language tag is found, this will be returned.
/// - Otherwise, it tries to return a translation for the general language of the tag.
/// - Otherwise, it tries to return a translation for any locale with that language.
/// - Otherwise, it returns the key itself (which is usually the translation for the
///   default locale).
///
/// Example 1:
/// If "pt-BR" is asked, and "pt-BR" is available, return the translation for "pt-BR".
///
/// Example 2:
/// If "pt-BR" is asked, and "pt-BR" is not available, but "pt" is available,
/// return the translation for "pt".
///
/// Example 3:
/// If "pt-MO" is asked, and "pt-MO" and "pt" are not available, but "pt-BR" is
/// available, return the translation for "pt-BR".
///
String localize(
  Object? key,
  Translations translations, {
  String? languageTag,
}) =>
    core.localize(key, translations, locale: languageTag ?? I18n.languageTag);

/// The [localizeFill] function applies a `sprintf` on the [text] with the [params].
/// This is implemented with the `sprintf` package: https://pub.dev/packages/sprintf
///
/// Possible format values:
///
/// * `%s` - String
/// * `%b` - Binary number
/// * `%c` - Character according to the ASCII value of `c`
/// * `%d` - Signed decimal number (negative, zero or positive)
/// * `%u` - Unsigned decimal number (equal to or greater than zero)
/// * `%f` - Floating-point number
/// * `%e` - Scientific notation using a lowercase, like `1.2e+2`
/// * `%E` - Scientific notation using a uppercase, like `1.2E+2`
/// * `%g` - shorter of %e and %f
/// * `%G` - shorter of %E and %f
/// * `%o` - Octal number
/// * `%X` - Hexadecimal number, uppercase letters
/// * `%x` - Hexadecimal number, lowercase letters
///
/// Additional format values may be placed between the % and the letter.
/// If multiple of these are used, they must be in the same order as below.
///
/// * `+` - Forces both + and - in front of numbers. By default, only negative numbers are marked
/// * `'` - Specifies the padding char. Space is the default. Used together with the width specifier: %'x20s uses "x" as padding
/// * `-` - Left-justifies the value
/// * `[0-9]` -  Specifies the minimum width held of to the variable value
/// * `.[0-9]` - Specifies the number of decimal digits or maximum string length. Example: `%.2f`:
///
String localizeFill(Object? text, List<Object> params) => core.localizeFill(text, params);

/// Returns the translated version for the plural [modifier].
/// After getting the version, substring `%d` will be replaced with the modifier.
///
/// Note: This will try to get the most specific plural modifier. For example, `.two`
/// is more specific than `.many`.
///
/// If no applicable modifier can be found, it will default to the unversioned
/// string. For example, this: `"a".zero("b").four("c:")` will default to `"a"`
/// for 1, 2, 3, or more than 5 elements.
///
/// The modifier should usually be an integer. But in case it's not, it will
/// be converted into an integer. The rules are:
///
/// 1) If the modifier is an `int`, its absolute value will be used.
/// Note: absolute value means a negative value will become positive.
///
/// 2) If the modifier is a `double`, its absolute value will be used, like so:
/// - 1.0 will be 1.
/// - Values below 1.0 will become 0.
/// - Values larger than 1.0 will be rounded up.
///
/// 3) A `String` will be converted to `int` or, if that fails, to a `double`.
/// Conversion is done like so:
/// - First, it will discard other chars than numbers, dot and the minus sign,
///   by converting them to spaces.
/// - Then it will convert to int using `int.tryParse`.
/// - Then it will convert to double using `double.tryParse`.
/// - If all fails, it will be zero.
///
/// 4) Other objects will be converted to a string (using the toString method), and then the above
/// rules will apply.
///
String localizePlural(
  Object? modifier,
  Object? key,
  Translations translations, {
  String? languageTag,
}) =>
    core.localizePlural(modifier, key, translations,
        locale: languageTag ?? I18n.languageTag);

/// The [localizeVersion] function localizes a "translatable string" to the given
/// [languageTag]. You must provide the [key] (which is usually the string you want to
/// translate), a [modifier], and the [translations] object which holds the translations.
///
/// You may use an object of any type as the [modifier], but it will do a `toString()`
/// in it and use resulting String. So, make sure your object has a suitable
/// string representation.
///
/// If [languageTag] is not provided (it's `null`), it will use the default language tag
/// found in [I18n.languageTag].
///
String localizeVersion(
  Object modifier,
  Object? key,
  Translations translations, {
  String? languageTag,
}) =>
    core.localizeVersion(modifier, key, translations,
        locale: languageTag ?? I18n.languageTag);

/// Use the [localizeAllVersions] method to return a [Map] of all translated strings,
/// where modifiers are the keys. In special, the unversioned text is indexed with
/// a `null` key.
///
/// If [languageTag] is not provided (it's `null`), the method will use the default
/// language tag found in [I18n.languageTag]
///
Map<String?, String> localizeAllVersions(
  Object? key,
  Translations translations, {
  String? languageTag,
}) =>
    core.localizeAllVersions(key, translations, locale: languageTag ?? I18n.languageTag);

/// Function [recordMissingKey] simply records the given key as a missing translation
/// with unknown locale. It returns the same [key] provided, unaffected.
String recordMissingKey(Object? key) => core.recordMissingKey(key);
