import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_core/src/core_localize_functions.dart' as core;

/// Use the [localize] method to localize a "translatable string" to the given [locale].
/// You must provide the [key] (which is usually the string you want to translate)
/// and the [translations] object which holds the translations.
///
/// If [locale] is not provided (it's `null`), the method will use the default locale
/// in [I18n.localeStr].
///
/// ---
///
/// Fallback order:
///
/// - If the translation to the exact locale is found, this will be returned.
/// - Otherwise, it tries to return a translation for the general language of
///   the locale.
/// - Otherwise, it tries to return a translation for any locale with that
///   language.
/// - Otherwise, it tries to return the key itself (which is the translation
///   for the default locale).
///
/// Example 1:
/// If "pt_br" is asked, and "pt_br" is available, return for "pt_br".
///
/// Example 2:
/// If "pt_br" is asked, "pt_br" is not available, and "pt" is available,
/// return for "pt".
///
/// Example 3:
/// If "pt_mo" is asked, "pt_mo" and "pt" are not available, but "pt_br" is,
/// return for "pt_br".
///
///
/// This class is visible only from the [i18_exception_core] package.
/// The [i18_exception] package uses a different function with the same name.
///
String localize(
  Object? key,
  Translations translations, {
  String? locale,
}) =>
    core.localize(key, translations, locale: locale ?? I18n.localeStr);

/// Does an `sprintf` on the [text] with the [params].
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
/// Note: This will try to get the most specific plural modifier. For example,
/// `.two` is more specific than `.many`.
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
  String? locale,
}) =>
    core.localizePlural(modifier, key, translations, locale: locale ?? I18n.localeStr);

/// Use the [localizeVersion] method to localize a "translatable string" to the given [locale].
/// You must provide the [key] (which is usually the string you want to translate),
/// a [modifier], and the [translations] object which holds the translations.
///                 
/// You may use an object of any type as the [modifier], but it will do a `toString()`
/// in it and use resulting String. So, make sure your object has a suitable
/// string representation.
///
/// If [locale] is not provided (it's `null`), the method will use the default locale
/// in [DefaultLocale.locale] (which may be set with [DefaultLocale.set].
///
/// If both [locale] and [DefaultLocale.locale] are not provided, it defaults to 'en_US'.
///
String localizeVersion(
  Object modifier,
  Object? key,
  Translations translations, {
  String? locale,
}) =>
    core.localizeVersion(modifier, key, translations, locale: locale ?? I18n.localeStr);

/// Use the [localizeAllVersions] method to return a [Map] of all translated strings,
/// where modifiers are the keys. In special, the unversioned text is indexed with a `null` key.
///
/// If [locale] is not provided (it's `null`), the method will use the default locale
/// in [DefaultLocale.locale] (which may be set with [DefaultLocale.set].
///
/// If both [locale] and [DefaultLocale.locale] are not provided, it defaults to 'en_US'.
///
Map<String?, String> localizeAllVersions(
  Object? key,
  Translations translations, {
  String? locale,
}) =>
    core.localizeAllVersions(key, translations, locale: locale ?? I18n.localeStr);

/// Function [recordMissingKey] simply records the given key as a missing
/// translation with unknown locale. It returns the same [key] provided,
/// unaffected.
String recordMissingKey(Object? key) => core.recordMissingKey(key);
