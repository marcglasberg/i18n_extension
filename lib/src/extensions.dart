import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension_core/i18n_extension_core.dart' as core;

// ignore: implementation_imports
import 'package:i18n_extension_core/src/translations_by_locale.dart' as tbl;

extension I18nTranslationsExtension on Translations {
  //

  /// Calling [load] starts the process of loading the translations. It returns a future
  /// which you can use to wait for the translations to be loaded.
  ///
  /// While [load] can safely be called for any translation type, it only loads
  /// the translations for those types that need them, like those created
  /// with [Translations.byFile].
  ///
  /// Note translations are loaded automatically anyway when you use them for the first
  /// time, even if you don't call [load]. For this reason, calling [load] is optional,
  /// and only needed if you want to wait for the translations to be loaded before
  /// continuing.
  ///
  /// # Usage
  ///
  /// If you want to load the translations when the app starts:
  ///
  /// ```dart
  /// extension MyTranslations on String {
  ///   static final _t = Translations.byFile('en-US', dir: 'assets/translations');
  ///   static Future<void> load() => _t.load();
  ///   String get i18n => localize(this, _t);
  /// }
  ///
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await MyTranslations.load();
  ///   runApp(I18n(...));
  /// }
  /// ```
  ///
  /// Or you can also use a [FutureBuilder]:
  ///
  /// ```dart
  /// return FutureBuilder(
  ///   future: MyTranslations.load(),
  ///   builder: (context, snapshot) {
  ///     if (snapshot.connectionState == ConnectionState.done) {
  ///     return ...;
  ///   } else {
  ///     return const Center(child: CircularProgressIndicator());
  ///   }
  /// ...
  /// ```
  ///
  /// Note: The load process has a default timeout of 0.5 seconds. If the timeout is
  /// reached, the future returned by [load] will complete, but the load process still
  /// continues in the background, and the widgets will rebuild automatically when the
  /// translations finally finish loading. Optionally, you can provide your own [timeout]
  /// duration, as well as a [callback] function to be called only in case the timeout is
  /// reached.
  ///
  ///
  Future<void> load([
    Duration? timeout,
    VoidCallback? callback,
  ]) async {
    I18nTranslationsExtension.initLoadProcess();
    // ---

    var translations = this;

    if (translations is tbl.TranslationsByLocale) {
      //
      var completer = translations.completer;
      if (completer == null || completer.isCompleted) return;

      final startTime = DateTime.now();
      var timedOut = false;

      // Translations.byHttp have default timeout of 1 second.
      // Others, like Translations.byFile, have timeout of 0.5 seconds.
      timeout ??= (translations.url != null)
          ? const Duration(seconds: 1)
          : const Duration(milliseconds: 500);

      await (this as tbl.TranslationsByLocale).completer?.future.timeout(
        timeout,
        onTimeout: () {
          timedOut = true;
          if (callback == null) {
            var path = Uri.parse(translations.url ?? '').path;
            path += translations.resources.toString();
            print('Loading translations timed out. '
                'Still loading in the background: $path');
          } else {
            callback();
          }
        },
      );

      if (callback == null && !timedOut) {
        final endTime = DateTime.now();
        final loadTime = endTime.difference(startTime);
        print('Loaded all translations in ${loadTime.inMilliseconds} ms.');
      }
    }
  }

  /// Initialize the load process, for translations created with [Translations.byFile]
  /// and [Translations.byHttp].
  ///
  static void initLoadProcess() {
    Translations.loadByFile = defaultLoadByFile;
    Translations.loadByHttp = defaultLoadByHttp;
  }

  /// Load assets for translations created with [Translations.byFile].
  /// The loaders used are listed in [I18n.loaders].
  static Future<void> defaultLoadByFile(tbl.TranslationsByLocale translations) async {
    //
    String? dir = translations.dir;
    if (dir == null) return;

    if (kIsWeb) {
      return;
    }
    //
    else {
      var futures = I18n.loaders.map((loader) => loader().fromAssetDir(dir));
      var loadedTranslationsList = await Future.wait(futures);

      _mergeTranslations(loadedTranslationsList, translations);

      I18n.rebuild();
    }
  }

  /// Load assets for translations created with [Translations.byHttp].
  /// The loaders used are listed in [I18n.loaders].
  static Future<void> defaultLoadByHttp(tbl.TranslationsByLocale translations) async {
    //
    // The url is something like "https://example.com/translations/".
    String? url = translations.url;

    // The resources are something like ["en-US.json", "es-ES.json"].
    Iterable<String>? resources = translations.resources;

    if (url != null && resources != null && resources.isNotEmpty) {
      //
      if (!url.endsWith('/')) url += '/'; // Adds the last slash if necessary.

      List<String> urlCombinations =
          resources.map((resource) => '$url$resource').toList();

      var futures = I18n.loaders
          .expand((loader) => urlCombinations.map((url) => loader().fromUrl(url)));

      var loadedTranslationsList = await Future.wait(futures);

      // For each file loaded, merge the translations into the main translations.
      _mergeTranslations(loadedTranslationsList, translations);

      I18n.rebuild();
    }
  }

  /// For each file loaded, merge the translations into the main translations.
  static void _mergeTranslations(
      List<Map<String, Map<String, String>>> loadedTranslationsList,
      tbl.TranslationsByLocale<
              String,
              Map<core.StringLocale, core.StringTranslated>,
              Map<String, core.StringTranslated>,
              Map<core.StringLocale, Map<String, core.StringTranslated>>>
          translations) {
    for (var loadedTranslations in loadedTranslationsList) {
      //
      Map<String, Map<String, String>> dest =
          translations.translationByLocale_ByTranslationKey;

      for (MapEntry<String, Map<String, String>> entry in loadedTranslations.entries) {
        //
        String key = entry.key;
        Map<String, String> srcMap = entry.value;

        Map<String, String>? destMap = dest[key];
        if (destMap == null) {
          destMap = {};
          dest[key] = destMap;
        }

        destMap.addAll(srcMap);
      }
    }
  }
}

extension I18nMainExtension on String {
  //

  /// The [args] function applies interpolations on this string with the given
  /// params, [p1], [p2], [p3], ..., [p15].
  ///
  ///
  /// # 1. Interpolation with named placeholders
  ///
  /// Your translations file may contain interpolations:
  ///
  /// ```dart
  /// static var _t = Translations.byText('en-US') +
  ///     {
  ///       'en-US': 'Hello {student} and {teacher}',
  ///       'pt-BR': 'Olá {student} e {teacher}',
  ///     };
  ///
  /// String get i18n => localize(this, _t);
  /// ```
  ///
  /// Then use the [args] function:
  ///
  /// ```dart
  /// print('Hello {student} and {teacher}'.i18n
  ///   .args({'student': 'John', 'teacher': 'Mary'}));
  /// ```
  ///
  /// The above code will print `Hello John and Mary` if the locale is English,
  /// or `Olá John e Mary` if it's Portuguese. This interpolation method allows for the
  /// translated string to change the order of the parameters.
  ///
  /// # 2. Interpolation with numbered placeholders
  ///
  /// ```dart
  /// static var _t = Translations.byText('en-US') +
  ///     {
  ///       'en-US': 'Hello {1} and {2}',
  ///       'pt-BR': 'Olá {1} e {2}',
  ///     };
  ///
  /// String get i18n => localize(this, _t);
  /// ```
  ///
  /// Then use the [args] function:
  ///
  /// ```dart
  /// print('Hello {1} and {2}'.i18n
  ///   .args({1: 'John', 2: 'Mary'}));
  /// ```
  ///
  /// The above code will print `Hello John and Mary` if the locale is English,
  /// or `Olá John e Mary` if it's Portuguese. This interpolation method allows for the
  /// translated string to change the order of the parameters. For example:
  ///
  /// ```dart
  /// // Returns `Hello John and Mary`
  /// 'Hello {1} and {2}'.i18n.args({'1': 'John', '2': 'Mary'});
  ///
  /// // Returns `Hello Mary and John`
  /// 'Hello {2} and {1}'.i18n.args({'1': 'John', '2': 'Mary'});
  /// ```
  ///
  /// # 3. Interpolation with unnamed placeholders
  ///
  /// ```dart
  /// static var _t = Translations.byText('en-US') +
  ///     {
  ///       'en-US': 'Hello {} and {}',
  ///       'pt-BR': 'Olá {} e {}',
  ///     };
  ///
  /// String get i18n => localize(this, _t);
  /// ```
  ///
  /// Then use the [args] function:
  ///
  /// ```dart
  /// print('Hello {} and {}'.i18n.args('John', 'Mary'));
  /// print('Hello {} and {}'.i18n.args(['John', 'Mary'])); // Also works
  /// ```
  ///
  /// The above code will replace the `{}` in order,
  /// and print `Hello John and Mary` if the locale is English,
  /// or `Olá John e Mary` if it's Portuguese.
  ///
  /// The problem with this interpolation method is that it doesn’t allow for the
  /// translated string to change the order of the parameters.
  ///
  String args(Object p1,
          [Object? p2,
          Object? p3,
          Object? p4,
          Object? p5,
          Object? p6,
          Object? p7,
          Object? p8,
          Object? p9,
          Object? p10,
          Object? p11,
          Object? p12,
          Object? p13,
          Object? p14,
          Object? p15]) =>
      localizeArgs(
          this, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15);

  /// The [fill] function applies a `sprintf` on this string with the given
  /// params, [p1], [p2], [p3], ..., [p15].
  ///
  /// This is implemented with the `sprintf` package: https://pub.dev/packages/sprintf
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Hello %s and %s'.i18n.fill('John', 'Mary');
  ///
  /// // Also works
  /// print('Hello %s and %s'.i18n.fill(['John', 'Mary']);
  /// ```
  ///
  /// Possible format values:
  ///
  /// * `%s` - String
  /// * `%1$s` and `%2$s` - 1st String and 2nd String
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
  String fill(Object p1,
          [Object? p2,
          Object? p3,
          Object? p4,
          Object? p5,
          Object? p6,
          Object? p7,
          Object? p8,
          Object? p9,
          Object? p10,
          Object? p11,
          Object? p12,
          Object? p13,
          Object? p14,
          Object? p15]) =>
      localizeFill(
          this, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15);
}

extension I18nBuildContextExtension on BuildContext {
  //

  /// To change the current locale:
  ///
  ///     context.locale = Locale('es', 'ES');
  ///     OR
  ///     I18n.of(context).locale = Locale('es', 'ES');
  ///
  /// To return the current locale to the system locale default:
  ///
  ///     context.locale = null;
  ///     OR
  ///     I18n.of(context).locale = null;
  ///
  /// Please note, a Locale object can also be constructed with
  /// the [I18nStringExtension.asLocale] extension:
  ///
  /// ```dart
  /// context.locale = 'es-ES'.asLocale;
  /// ```
  ///
  set locale(Locale? locale) {
    I18n.of(this).locale = locale;
  }

  /// Ways to read the current locale:
  ///
  ///     Locale locale = context.locale;
  ///     OR
  ///     Locale locale = I18n.of(context).locale;
  ///     OR
  ///     Locale locale = I18n.locale; // Statically also works.
  ///
  /// Or, to get the locale as a BCP47 language tag:
  ///
  ///     // Example: "en-US".
  ///     String languageTag = I18n.languageTag;
  ///
  Locale get locale => I18n.of(this).locale;

  /// To reset the current locale back to the default system locale,
  /// which is set in the device settings:
  ///
  ///     context.resetLocale();
  ///     OR
  ///     I18n.of(context).resetLocale();
  ///
  void resetLocale() {
    I18n.of(this).resetLocale();
  }
}

extension I18nStringExtension on String {
  //

  /// Return the string normalized as a BCP47 language tag (which is compatible with the
  /// Unicode Locale Identifier (ULI) syntax), by adjusting the case of each component.
  ///
  /// This function takes a locale string and normalizes its subtags:
  /// - Removes spaces and converts underscores to hyphens.
  /// - The language subtag is converted to lowercase.
  /// - The script subtag (if present) is converted to title case
  ///   (first letter uppercase, rest lowercase).
  /// - The region subtag (if present) is converted to uppercase.
  /// - The separator becomes the hyphen (`-`).
  ///
  /// If the input string is null or empty, the string "und" (language code undefined)
  /// is returned.
  ///
  /// Example:
  /// ```dart
  /// 'eN-lAtN-us'.asLanguageTag; // Output: en-Latn-US
  /// ```
  ///
  String get asLanguageTag => core.DefaultLocale.normalizeLocale(this) ?? 'und';

  /// Use [asLocale] to convert a [String] containing a valid BCP47 language tag
  /// to a [Locale] object. For example:
  ///
  /// ```dart
  /// Locale locale = 'pt-BR'.asLocale;
  /// ```dart
  ///
  /// If the string is not a valid BCP47 language, [asLocale] will try to fix it.
  /// However, it will only fix the most common errors, by removing spaces,
  /// converting underscores to hyphens, and normalizing the case.
  /// If it can’t fix it, it will return an invalid [Locale], or maybe `Locale('und')`,
  /// meaning the locale is undefined.
  ///
  /// See also: [I18nLocaleExtension.format].
  ///
  Locale get asLocale {
    //
    String? locale = core.DefaultLocale.normalizeLocale(this);
    if (locale == null) return const Locale('und');

    final parts = locale.split('-').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return const Locale('und');

    // BCP47 language tags are generally in the form:
    // `language[-script][-region][-variants]`, e.g. "en-Latn-US".
    final languageCode = parts.first.toLowerCase();
    String? scriptCode;
    String? countryCode;

    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      // If scriptCode not found yet and part seems like a script code
      // (4 letters, first uppercase, rest lowercase).
      if (scriptCode == null &&
          part.length == 4 &&
          part[0].toUpperCase() == part[0] &&
          part.substring(1).toLowerCase() == part.substring(1)) {
        scriptCode = part;
      }
      // If countryCode not found yet and part is a two-letter uppercase region code.
      else if (countryCode == null && part.length == 2 && part.toUpperCase() == part) {
        countryCode = part;
      }
    }

    // Doesn’t happen in practice.
    if (languageCode.isEmpty) return const Locale('und');

    return Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }
}

extension I18nLocaleExtension on Locale {
  //

  /// Use [format] to return the string representation of the Locale as a valid
  /// BCP47 language tag (compatible with the Unicode Locale Identifier (ULI) syntax).
  /// If the locale is not valid, [format] may return an invalid tag, or may return
  /// string "und" (undefined).
  ///
  /// The language code, script code, and country code will be separated by a hyphen,
  /// and any lowercase/uppercase issues will be fixed.
  ///
  /// Using [format] is recommended over [toString] and [toLanguageTag] (natively
  /// provided by the `Locale` class). In detail:
  ///
  /// - [format] returns the string representation of the Locale as a valid BCP47
  /// language tag, fixing any lowercase/uppercase issues and separating components with
  /// a hyphen. Allows specifying a different separator. For example,
  /// `Locale('en', 'us').format()` returns `en-US`, and
  /// `Locale('en', 'US').format(separator: '|')` returns `en|US`.
  ///
  /// - [toString] returns the language, script and country codes separated by an
  /// underscore. For example, `Locale('en', 'us').toString()` returns `en_us`
  /// and `Locale('en', 'US').toString()` returns `en_US`.
  ///
  /// - [toLanguageTag] returns the language code and the country code separated by a
  /// hyphen, but does not fix case. For example, `Locale('en', 'us').toLanguageTag()`
  /// returns `en-us`, and `Locale('en', 'US').toLanguageTag()` returns `en-US`.
  ///
  /// See also: [I18nStringExtension.asLocale].
  ///
  String format({String? separator}) {
    String? languageTag = core.DefaultLocale.normalizeLocale(toLanguageTag());

    if ((languageTag != null) && (separator != null)) {
      languageTag = languageTag.replaceAll('-', separator);
    }

    if (languageTag == null || languageTag.isEmpty) return 'und';

    return languageTag;
  }
}
