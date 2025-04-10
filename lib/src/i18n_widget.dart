// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/src/i18n_json_loader.dart';
import 'package:i18n_extension/src/i18n_po_loader.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n_loader.dart';

/// # Setup
///
/// 1. Add a single [I18n] widget in your widget tree, above your [MaterialApp]
/// (or [CupertinoApp]) widget.
///
/// 3. Make sure the [I18n] widget is NOT declared in the same widget as the
/// [MaterialApp] (or [CupertinoApp]) widget. It must be in a parent widget.
///
/// 3. Add `locale: I18n.locale` to your [MaterialApp] (or [CupertinoApp]) widget.
///
/// ## Example
///
/// ```dart
/// import 'package:i18n_extension/i18n_extension.dart';
///
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   Widget build(BuildContext context) {
///     return I18n(
///       child: AppCore(),
///     );
///   }
/// }
///
/// class AppCore extends StatelessWidget {
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       locale: I18n.locale,
///       ...
///     ),
/// ```
///
/// Note that the [I18n] widget is above the [MaterialApp] widget, but declared
/// in a parent widget. If you declare it in the same widget as the [MaterialApp]
/// widget, it will not work. This is WRONG:
///
/// ```dart
/// Widget build(BuildContext context) {
///   return I18n(
///     child: MaterialApp( // Wrong!
///       locale: I18n.locale,
///     ),
/// ```
///
/// ## Configuration
///
/// When your app opens, it will use the current system-locale (set in the device
/// settings). If you want to force a specific locale, you can do so by setting
/// the [initialLocale] parameter in the [I18n] widget:
///
/// ```dart
/// return I18n(
///   initialLocale: locale('es', 'ES'),
///   child: AppCore(),
/// ```
///
/// The [autoSaveLocale] parameter is an optional boolean, and the default is false.
/// If you set [autoSaveLocale] to true, the locale will be saved and recovered between app
/// restarts. This is useful if you want to remember the user's language preference.
///
/// ```dart
/// return I18n(
///   autoSaveLocale: true,
///   child: AppCore(),
/// ```
///
/// Note, if your app only ever uses the current system locale, or if you save the
/// locale in another way, you can keep [autoSaveLocale] as false.
///
class I18n extends StatefulWidget {
  //
  static final _i18nKey = GlobalKey<_I18nState>();

  final Widget child;

  /// Optionally, you can set [initialLocale] to force a specific locale when the app
  /// opens. If you don’t set it, the current system-locale, read from the device
  /// settings, will be used.
  ///
  /// If you set the [initialLocale], you must add the line `locale: I18n.locale` to
  /// your [MaterialApp] (or [CupertinoApp]) widget:
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   runApp(I18n(
  ///     initialLocale: Locale('en', 'US'), // Here!
  ///     supportedLocales: [ ... ],
  ///     child: AppCore(),
  ///     ));
  ///   }
  /// }
  ///
  /// class AppCore extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       locale: I18n.locale, // Here!
  ///       supportedLocales: I18n.supportedLocales,
  ///       ...
  ///     ),
  /// ```
  ///
  final Locale? initialLocale;

  /// Optionally, you can set the [supportedLocales] of your app.
  /// For example, if your app supports American English and Standard Spanish, use:
  /// `supportedLocales: [Locale('en', 'US'), Locale('es')]`,
  /// or `supportedLocales: ['en-US'.asLocale, 'es'.asLocale]`.
  ///
  /// If you set the [supportedLocales], you must add the line
  /// `supportedLocales: I18n.supportedLocales` to your [MaterialApp]
  /// (or [CupertinoApp]) widget:
  ///
  /// ```dart
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   runApp(I18n(
  ///       initialLocale: ...,
  ///       supportedLocales: [Locale('en', 'US'), Locale('es')], // Here!
  ///       child: AppCore(),
  ///     ));
  ///   }
  /// }
  ///
  /// class AppCore extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       locale: I18n.locale,
  ///       supportedLocales: I18n.supportedLocales, // Here!
  ///       ...
  ///     ),
  /// ```
  final Iterable<Locale> _supportedLocales;

  /// Optionally, you can set the [localizationsDelegates] of your app.
  ///
  /// If you do that, you must add the line
  /// `localizationsDelegates: I18n.localizationsDelegates` to your [MaterialApp]
  /// (or [CupertinoApp]) widget:
  ///
  /// ```dart
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   runApp(I18n(
  ///       localizationsDelegates: [ // Here!
  ///           GlobalMaterialLocalizations.delegate,
  ///           GlobalWidgetsLocalizations.delegate,
  ///           GlobalCupertinoLocalizations.delegate,
  ///         ],
  ///       child: AppCore(),
  ///     ));
  ///   }
  /// }
  ///
  /// class AppCore extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       localizationsDelegates: I18n.localizationsDelegates, // Here!
  ///       ...
  ///     ),
  /// ```
  final Iterable<LocalizationsDelegate<dynamic>> _localizationsDelegates;

  /// If [autoSaveLocale] is true, the locale will be saved and recovered between
  /// app restarts. This is useful if you want to remember the user's language
  /// preference. If your app only ever uses the current system locale, or if you
  /// save the locale in another way, keep [autoSaveLocale] as false:
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   runApp(I18n(
  ///     initialLocale: await I18n.loadLocale(),
  ///     supportedLocales: ['en-US'.asLocale, 'es'.asLocale],
  ///     autoSaveLocale: true, // Here!
  ///     child: AppCore(),
  ///   ));
  /// }
  ///
  /// class AppCore extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       locale: I18n.locale,
  ///       supportedLocales: I18n.supportedLocales,
  ///       ...
  ///     ),
  /// ```
  final bool autoSaveLocale;

  /// # Setup
  ///
  /// 1. Add a single [I18n] widget in your widget tree, above your [MaterialApp]
  /// (or [CupertinoApp]) widget.
  ///
  /// 2. Make sure the [I18n] widget is NOT declared in the same widget as the
  /// [MaterialApp] (or [CupertinoApp]) widget. It must be in a parent widget.
  ///
  /// 3. Add `locale: I18n.locale` to your [MaterialApp] (or [CupertinoApp]) widget.
  ///
  /// ## Example
  ///
  /// ```dart
  /// import 'package:i18n_extension/i18n_extension.dart';
  ///
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   runApp(MyApp());
  /// }
  ///
  /// class MyApp extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return I18n(
  ///       child: AppCore(),
  ///     );
  ///   }
  /// }
  ///
  /// class AppCore extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       locale: I18n.locale,
  ///       ...
  ///     ),
  /// ```
  ///
  /// Note that the [I18n] widget is above the [MaterialApp] widget, but declared
  /// in a parent widget. If you declare it in the same widget as the [MaterialApp]
  /// widget, it will not work. This is WRONG:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return I18n(
  ///     child: MaterialApp( // Wrong!
  ///       locale: I18n.locale,
  ///     ),
  /// ```
  ///
  /// ## Configuration
  ///
  /// When your app opens, it will use the current system-locale (set in the device
  /// settings). If you want to force a specific locale, you can do so by setting
  /// the [initialLocale] parameter in the [I18n] widget:
  ///
  /// ```dart
  /// return I18n(
  ///   initialLocale: locale('es', 'ES'),
  ///   child: AppCore(),
  /// ```
  ///
  /// The [autoSaveLocale] parameter is an optional boolean, and the default is false.
  /// If you set [autoSaveLocale] to true, the locale will be saved and recovered between app
  /// restarts. This is useful if you want to remember the user's language preference.
  ///
  /// ```dart
  /// return I18n(
  ///   autoSaveLocale: true,
  ///   child: AppCore(),
  /// ```
  ///
  /// Note, if your app only ever uses the current system locale, or if you save the
  /// locale in another way, you can keep [autoSaveLocale] as false.
  ///
  I18n({
    required this.child,
    this.initialLocale,
    Iterable<Locale> supportedLocales = const [],
    Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = const [],
    this.autoSaveLocale = false,
  })  : _supportedLocales = supportedLocales,
        _localizationsDelegates = localizationsDelegates,
        super(key: _i18nKey) {
    Translations.supportedLocales =
        supportedLocales.map((e) => e.format()).toList();
  }

  /// Return the current locale of the app.
  ///
  /// In more detail:
  ///
  /// - If no locale was explicitly set, [locale] returns the system-locale,
  ///   which is set in the device settings. When the app opens, the system-locale is
  ///   read as soon as possible, but it might be unavailable for a brief period in
  ///   which [preInitializationLocale] is used instead, which by default
  ///   is `Locale('es', 'US')`.
  ///
  /// - If a locale was explicitly set by you, we say that the locale is "forced".
  ///   In this case, [locale] is equal to [forcedLocale].
  ///
  static Locale get locale => _forcedLocale ?? _systemLocale;

  /// The [locale], as a lowercase string with underscore as separators, like "en_us".
  ///
  /// See also: [languageTag], which is more standard and returns tags like "en-US"
  /// instead of "en_us".
  ///
  @Deprecated('Use `languageTag` instead, which is more standard '
      'and returns language tags like en-US instead of en_us. '
      'If you still need en_us you can use I18n.locale.format(separator: "_").toLowerCase()')
  static String get localeStr => localeStringAsLowercaseAndUnderscore(locale);

  /// Returns the current [locale] as a syntactically valid IETF BCP47 language tag
  /// (compatible with the Unicode Locale Identifier (ULI) syntax).
  ///
  /// Some examples of such identifiers: "en", "en-US", "es-419", "hi-Deva-IN" and
  /// "zh-Hans-CN". See http://www.unicode.org/reports/tr35/ for technical details.
  ///
  static String get languageTag => locale.format();

  /// The the system-locale, as set in the device settings.
  /// The only way to change this is opening the device settings and changing the
  /// language there. The app will change the locale when the system locale changes, but
  /// only if no locale was explicitly set (in other words, if [forcedLocale] is null).
  static Locale get systemLocale => _systemLocale;

  /// If a locale was explicitly set in the app (forced), this method returns it.
  /// In other words, the [forcedLocale] overrides the system-locale. There are 3 ways
  /// to force a locale:
  ///
  /// 1. By setting the [initialLocale] parameter, in the [I18n] widget:
  ///
  /// ```dart
  /// I18n(
  ///   initialLocale: Locale('es', 'ES'),
  ///   child: ...
  /// );
  /// ```
  ///
  /// 2. By calling `I18n.of(context).locale = Locale('es', 'ES');`
  /// 3. By calling `I18n.define(Locale('es', 'ES'));` (for tests only)
  ///
  /// If no locale was set, [forcedLocale] is `null`.
  ///
  /// To remove the forced locale at any moment, set it to `null`. This will
  /// make the app use the system locale again. For example:
  ///
  /// 1. `I18n.of(context).locale = null;`
  /// 2. `I18n.define(null);` (for tests only)
  ///
  static Locale? get forcedLocale => _forcedLocale;

  /// Returns `true` if the system locale is being used.
  /// In this case, the app will change the locale when the system locale changes.
  ///
  /// Return `false` if you set a locale directly. In this case, the locale you set is
  /// the one being used, which means the app is ignoring the system locale, meaning
  /// the app will NOT change the locale when the system locale changes.
  ///
  /// Note: When you set the locale directly, we say that the locale is being "forced",
  /// because it's being forced to be a specific locale, and not the system locale.
  /// You can get the forced locale with [forcedLocale]. It will be null if
  /// no locale is being forced.
  static bool get isUsingSystemLocale => _forcedLocale == null;

  /// The language code of the current locale, as a lowercase string.
  /// Note this is just the language itself, without region/country, script etc.
  /// For example, if the language tag is `en-US`, then it returns 'en'.
  static String get languageOnly => getLanguageOnlyFromLocale(locale);

  /// When the app starts, the [systemLocale] is read from the system as soon as possible.
  /// The system locale might be unavailable for a brief period. Usually, this is not an
  /// issue and won’t be noticeable, but in rare cases, this locale will be used until
  /// the actual system locale is determined. You can change this to your preferred
  /// locale if needed. Otherwise, leave it as is.
  static Locale preInitializationLocale = const Locale('es', 'US');

  /// Returns the supported locales of the app, as set in the [I18n] widget.
  static Iterable<Locale> get supportedLocales {
    //
    var currentState = _i18nKey.currentState;

    if (currentState == null) {
      throw TranslationsException("Can't get I18n.supportedLocales. "
          "Make sure the I18n widget is in a separate parent widget, "
          "above MaterialApp/CupertinoApp in the widget tree.");
    }

    return currentState.widget._supportedLocales;
  }

  /// Returns the localization delegates of the app, as set in the [I18n] widget.
  static Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    //
    var currentState = _i18nKey.currentState;

    if (currentState == null) {
      throw TranslationsException("Can't get I18n.localizationsDelegates. "
          "Make sure the I18n widget is in a separate parent widget, "
          "above MaterialApp/CupertinoApp in the widget tree.");
    }

    return currentState.widget._localizationsDelegates;
  }

  /// Even before we can use `View.of()` it's possible we have access to the device
  /// locale via the `PlatformDispatcher`. If that's `undefined` (`und`) return the
  /// `preInitializationLocale` instead.
  static Locale _getSystemOrPreInitializationLocale() {
    Locale systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'und') return preInitializationLocale;
    return systemLocale;
  }

  /// Return the lowercase language-code of the given [locale].
  /// Note this is just the language itself, without region/country, script etc.
  /// For example, if the locale is Locale('en', 'US'), then it returns 'en'.
  static String getLanguageOnlyFromLocale(Locale locale) {
    _assertLanguageCode(locale);
    return locale.languageCode.toLowerCase().trim();
  }

  static void _assertLanguageCode(Locale locale) {
    if (locale.languageCode.contains("_")) {
      throw TranslationsException(
          "Language code '${locale.languageCode}' is invalid: "
          "Contains an underscore character.");
    }
  }

  /// Return the string representation of the locale, normalized like so:
  /// 1. Remove spaces
  /// 2. All lowercase
  /// 3. Underscore as separator
  ///
  /// For example: `localeStringAsLowercaseAndUnderscore(Locale('en', 'US'))`
  /// returns "en_us".
  ///
  /// Avoid using this method, as the returned string does not follow
  /// the IETF BCP47 Locale Identifier: (https://www.ietf.org/rfc/bcp/bcp47.html
  /// Instead, use the [I18nLocaleExtension.format] extension,
  /// which returns a standard language tag.
  ///
  static String localeStringAsLowercaseAndUnderscore(Locale locale) =>
      locale.format(separator: "_").toLowerCase();

  /// Given a locale, return the decimal separator used in that locale.
  /// For example, for en-US it's ".", but for pt-BR it's ","
  static String getDecimalSeparator(Locale locale) {
    String language = locale.languageCode;
    NumberSymbols? x = numberFormatSymbols[language];
    return x?.DECIMAL_SEP ?? ".";
  }

  /// This global callback is called whenever the locale changes. Notes:
  ///
  /// • To obtain the language, you can do:
  /// `String language = I18n.getLanguage(newLocale);`
  ///
  /// • To obtain the normalized locale as a string, you can do:
  /// `String localeStr = I18n.trim(newLocale);`
  ///
  static void Function({
    required Locale oldLocale,
    required Locale newLocale,
  }) observeLocale =
      ({required Locale oldLocale, required Locale newLocale}) {};

  /// Calling [I18n.reset] will remove the entire widget tree inside [I18n] for one frame,
  /// and then restore it, rebuilding everything. This can be helpful in rare
  /// circumstances, when some widgets are not responding to locale changes. This is a
  /// brute-force method, and it's probably not necessary in the vast majority of cases.
  /// A side effect is that the all stateful widgets below [I18n] will be recreated, and
  /// their state reset by calling their `initState()` method. This means you should only
  /// use this method if you don't mind loosing all this state, or if you have mechanisms
  /// to recover it, like for example having the state come from above the [I18n] widget.
  static void reset() {
    var homepageState = _i18nKey.currentState;
    homepageState?._reset();
  }

  /// Getter:
  /// print(I18n.of(context).locale);
  ///
  /// Setter:
  /// I18n.of(context).locale = Locale('es', 'US');
  ///
  static _I18nState of(BuildContext context) {
    _InheritedI18n? inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedI18n>();

    if (inherited == null) {
      throw TranslationsException(
          "Can’t find the `I18n` widget up in the tree. "
          "Please make sure to wrap some ancestor widget with `I18n`.");
    }

    return inherited.data;
  }

  /// Use this for tests only.
  ///
  /// To change the current locale, during tests:
  ///
  ///     I18n.define(Locale('es', 'ES'));
  ///
  /// To return the current locale to the system default:
  ///
  ///     I18n.define(null);
  ///
  /// IMPORTANT: This will change the current locale only for the i18n_extension,
  /// and not for Flutter as a whole. In other words, the widgets will not rebuild.
  /// This static method should be used in tests ONLY. The real app, you should
  /// instead do something like: `I18n.of(context).locale = Locale('es', 'ES');`
  ///
  @visibleForTesting
  static void define(Locale? locale) {
    Locale oldLocale = I18n.locale;

    // Tries fixing the Locale, a little bit.
    if (locale != null) locale = locale.toLanguageTag().asLocale;

    _forcedLocale = locale;
    Locale newLocale = I18n.locale;

    if (oldLocale != newLocale) {
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
    }
  }

  /// The system-locale read from the device.
  static Locale _systemLocale = _getSystemOrPreInitializationLocale();

  /// Locale to override the system-locale.
  /// If this is non-null, it means the locale is being forced.
  static Locale? _forcedLocale;

  /// Forces the rebuild of [I18n] and all its descendant widgets.
  static void rebuild() {
    var state = _i18nKey.currentState;
    if (state != null) {
      state._rebuildAllChildren();
    }
  }

  /// Saves the given [locale] to the shared preferences of the device.
  ///
  /// See also: [loadLocale], [deleteLocale].
  ///
  static Future<void> saveLocale(Locale? locale) {
    if (locale == null) {
      return SharedPreferencesAsync().remove('locale');
    } else {
      return SharedPreferencesAsync().setString('locale', locale.format());
    }
  }

  /// Load the locale previously saved with [saveLocale], from the shared
  /// preferences of the device. Note this only returns the saved locale,
  /// but it doesn’t set it.
  ///
  /// See also: [saveLocale], [deleteLocale].
  ///
  static Future<Locale?> loadLocale() async {
    _initLoadProcess();

    String? localeStr = await SharedPreferencesAsync().getString('locale');
    return (localeStr == null) ? null : localeStr.asLocale;
  }

  /// Returns a list of loaders to be used by the i18n_extension.
  /// By default, it loads from JSON (.json) and PO (.po) files.
  /// This list may be changed statically, to add or remove loaders,
  /// and you may create your own loaders by extending [I18nLoader].
  static final List<I18nLoader Function()> loaders = [
    () => I18nJsonLoader(),
    () => I18nPoLoader(),
  ];

  /// Initialize the load process, for translations created with [Translations.byFile]
  /// and [Translations.byHttp].
  ///
  static void _initLoadProcess() {
    I18nTranslationsExtension.initLoadProcess();
  }

  /// Deletes the locale previously saved with [saveLocale], from the shared
  /// preferences of the device.
  ///
  /// See also: [saveLocale], [loadLocale].
  ///
  static Future<void> deleteLocale() {
    return SharedPreferencesAsync().remove('locale');
  }

  @override
  _I18nState createState() => _I18nState();
}

class _I18nState extends State<I18n> with WidgetsBindingObserver {
  //
  Locale? _locale;

  Locale _viewLocale = PlatformDispatcher.instance.locale;

  bool _isResetting = false;

  void _reset() {
    if (mounted) {
      setState(() {
        _isResetting = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isResetting = false);
        });
      });
    }
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
  ///     // Examples: "en", "en-US", "es-419", "hi-Deva-IN", "zh-Hans-CN".
  ///     String languageTag = I18n.languageTag;
  ///
  Locale get locale {
    return _locale ?? I18n._getSystemOrPreInitializationLocale();
  }

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
    if (autoSaveLocale) I18n.saveLocale(locale);

    setState(() {
      _locale = locale;
      _forceAndObserveLocale();
    });
  }

  /// To reset the current locale back to the default system locale,
  /// which is set in the device settings:
  ///
  ///     context.resetLocale();
  ///     OR
  ///     I18n.of(context).resetLocale();
  ///
  void resetLocale() {
    locale = null;
  }

  /// Loads the locale previously saved with [I18n.saveLocale], from the shared
  /// preferences of the device, and then set it.
  ///
  /// IMPORTANT: This method may be safely called from initState. Note that the locale
  /// will be set asynchronously, so it may take a few milliseconds to be set.
  ///
  void _loadAndSetLocale(BuildContext context) {
    //
    SharedPreferencesAsync().getString('locale').then((String? localeStr) {
      if (localeStr != null) {
        Locale locale = localeStr.asLocale;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && (locale != I18n.locale)) {
            setState(() {
              _locale = locale;
              _forceAndObserveLocale();
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _forceAndObserveLocale();

    I18n._initLoadProcess();

    if (autoSaveLocale) _loadAndSetLocale(context);

    // Add this widget as an observer to listen for system changes.
    WidgetsBinding.instance.addObserver(this);
  }

  /// If [autoSaveLocale] is true, the locale will be saved and recovered between
  /// app restarts. This is useful if you want to remember the user's language
  /// preference. If your app only ever uses the current system locale, or if you
  /// save the locale in another way, you can set [autoSaveLocale] to false.
  /// The default is false.
  bool get autoSaveLocale => widget.autoSaveLocale;

  void _forceAndObserveLocale() {
    //
    Locale oldLocale = I18n.locale;
    I18n._forcedLocale = _locale;
    Locale newLocale = I18n.locale;

    I18n._assertLanguageCode(newLocale);

    if (oldLocale != newLocale) {
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
    }
  }

  /// Will be called when the system locale changes.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales != null && locales.isNotEmpty) {
      var newLocale = locales.first;
      if (newLocale != _viewLocale) {
        setState(() {
          _viewLocale = newLocale;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isResetting) {
      return const SizedBox();
    } else {
      _processSystemLocale();
      _rebuildAllChildren();

      return _InheritedI18n(
        data: this,
        child: widget.child,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _processSystemLocale();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// See: https://stackoverflow.com/a/58513635/3411681
  void _rebuildAllChildren() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void _processSystemLocale() {
    //
    Locale? newSystemLocale = View.of(context).platformDispatcher.locale;

    if (newSystemLocale != I18n._systemLocale) {
      //
      Locale oldLocale = I18n.locale;
      I18n._systemLocale = newSystemLocale;
      Locale newLocale = I18n.locale;

      I18n._assertLanguageCode(newLocale);

      if (oldLocale != newLocale) {
        I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
      }

      if (I18n._forcedLocale == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
      }
    }
  }
}

class _InheritedI18n extends InheritedWidget {
  //
  final _I18nState data;

  _InheritedI18n({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedI18n old) => data.locale != old.data.locale;
}
