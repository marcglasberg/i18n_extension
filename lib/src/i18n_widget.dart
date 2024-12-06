// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
///       child: MyMaterialApp(),
///     );
///   }
/// }
///
/// class MyMaterialApp extends StatelessWidget {
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       locale: I18n.locale,
///       ...
///     ),
/// ```
///
/// Note that the [I18n] widget is above the [MaterialApp] widget, but declared storeTester.dispatch(InitBasicoQuandoJaTemUmUsuarioLogado_Action());
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
///   child: MyMaterialApp(),
/// ```
///
/// The [saveLocale] parameter is optional. If [saveLocale] is true, the locale
/// will be saved and recovered between app restarts. This is useful if you want
/// to remember the user's language preference.
///
/// ```dart
/// return I18n(
///   saveLocale: true,
///   child: MyMaterialApp(),
/// ```
///
/// Note, if your app only ever uses the current system locale, or if you save the
/// locale in another way, you can set [saveLocale] to false. The default is false.
///
class I18n extends StatefulWidget {
  //
  static final _i18nKey = GlobalKey<_I18nState>();

  final Widget child;

  /// If you want to force a specific locale, you can set it here.
  /// If you don't set it, the current system-locale will be used.
  final Locale? initialLocale;

  /// If [saveLocale] is true, the locale will be saved and recovered between
  /// app restarts. This is useful if you want to remember the user's language
  /// preference. If your app only ever uses the current system locale, or if you
  /// save the locale in another way, you can set [saveLocale] to false.
  /// The default is false.
  final bool saveLocale;

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
  ///       child: MyMaterialApp(),
  ///     );
  ///   }
  /// }
  ///
  /// class MyMaterialApp extends StatelessWidget {
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       locale: I18n.locale,
  ///       ...
  ///     ),
  /// ```
  ///
  /// Note that the [I18n] widget is above the [MaterialApp] widget, but declared storeTester.dispatch(InitBasicoQuandoJaTemUmUsuarioLogado_Action());
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
  ///   child: MyMaterialApp(),
  /// ```
  ///
  /// The [saveLocale] parameter is optional. If [saveLocale] is true, the locale
  /// will be saved and recovered between app restarts. This is useful if you want
  /// to remember the user's language preference.
  ///
  /// ```dart
  /// return I18n(
  ///   saveLocale: true,
  ///   child: MyMaterialApp(),
  /// ```
  ///
  /// Note, if your app only ever uses the current system locale, or if you save the
  /// locale in another way, you can set [saveLocale] to false. The default is false.
  ///
  I18n({
    required this.child,
    this.initialLocale,
    this.saveLocale = false,
  }) : super(key: _i18nKey);

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
      'and returns language tags like en-US instead of en_us.')
  static String get localeStr => localeStringAsLowercaseAndUnderscore(locale);

  /// Returns the current [locale] as a syntactically valid IETF BCP47 language tag
  /// (compatible with the Unicode Locale Identifier (ULI) syntax).
  ///
  /// Some examples of such identifiers: "en", "en-US", "es-419", "hi-Deva-IN" and
  /// "zh-Hans-CN". See http://www.unicode.org/reports/tr35/ for technical details.
  ///
  static String get languageTag => locale.toLanguageTag();

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

  /// The language of the current locale, as a lowercase string.
  /// For example: "en" or "pt".
  static String get language => getLanguageFromLocale(locale);

  /// When the app starts, the [systemLocale] is read from the system as soon as possible.
  /// The system locale might be unavailable for a brief period. Usually, this is not an
  /// issue and won't be noticeable, but in rare cases, this locale will be used until
  /// the actual system locale is determined. You can change this to your preferred
  /// locale if needed. Otherwise, leave it as is.
  static Locale preInitializationLocale = const Locale('es', 'US');

  /// Even before we can use `View.of()` it's possible we have access to the device
  /// locale via the `PlatformDispatcher`. If that's `undefined` (`und`) return the
  /// `preInitializationLocale` instead.
  static Locale _getSystemOrPreInitializationLocale() {
    Locale systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'und') return preInitializationLocale;
    return systemLocale;
  }

  /// Return the lowercase language-code of the given locale.
  static String getLanguageFromLocale(Locale locale) {
    _checkLanguageCode(locale);
    return locale.languageCode.toLowerCase().trim();
  }

  /// Return the string representation of the locale, normalized like so:
  /// 1. trims spaces; 2. lowercases; 3. underscore as separators.
  /// For example, "en-US" becomes "en-US".
  static String localeStringAsLowercaseAndUnderscore(Locale locale) {
    String str = locale.toString().toLowerCase();
    RegExp pattern = RegExp('^[_ ]+|[_ ]+\$');
    return str.replaceAll(pattern, '');
  }

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
  }) observeLocale = ({required Locale oldLocale, required Locale newLocale}) {};

  /// Getter:
  /// print(I18n.of(context).locale);
  ///
  /// Setter:
  /// I18n.of(context).locale = Locale('es', 'US');
  ///
  static _I18nState of(BuildContext context) {
    _InheritedI18n? inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedI18n>();

    if (inherited == null)
      throw TranslationsException("Can't find the `I18n` widget up in the tree. "
          "Please make sure to wrap some ancestor widget with `I18n`.");

    return inherited.data;
  }

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
  /// instead do: `I18n.of(context).locale = Locale('es', 'ES');`
  ///
  @visibleForTesting
  static void define(Locale? locale) {
    Locale oldLocale = I18n.locale;
    _forcedLocale = locale;
    Locale newLocale = I18n.locale;
    _checkLanguageCode(newLocale);
    if (oldLocale != newLocale)
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
  }

  static void _checkLanguageCode(Locale locale) {
    if (locale.languageCode.contains("_"))
      throw TranslationsException("Language code '${locale.languageCode}' is invalid: "
          "Contains an underscore character.");
  }

  /// The locale read from the system.
  static Locale _systemLocale = _getSystemOrPreInitializationLocale();

  /// Locale to override the system locale.
  static Locale? _forcedLocale;

  @override
  _I18nState createState() => _I18nState();
}

class _I18nState extends State<I18n> with WidgetsBindingObserver {
  //
  Locale? _locale;

  Locale _viewLocale = PlatformDispatcher.instance.locale;

  /// To read the current locale:
  ///
  ///     Locale locale = I18n.of(context).locale;
  ///     Locale locale = I18n.locale; // Also works.
  ///
  /// Or, to get the locale as a lowercase string:
  ///
  ///     // Example: "en-US".
  ///     String localeStr = I18n.localeStr;
  ///
  /// Or, to get the language of the locale, lowercase:
  ///
  ///     // Example: "en".
  ///     String language = I18n.language;
  ///
  Locale get locale {
    return _locale ?? I18n._getSystemOrPreInitializationLocale();
  }

  /// To change the current locale:
  ///
  ///     I18n.of(context).locale = Locale('es', 'ES');
  ///
  /// To return the current locale to the system locale default:
  ///
  ///     I18n.of(context).locale = null;
  ///
  /// Note: This will change the current locale only for the i18n_extension,
  /// and not for Flutter as a whole.
  ///
  set locale(Locale? locale) {
    _maybeSaveLocale(locale);

    setState(() {
      _locale = locale;
      _forceAndObserveLocale();
    });
  }

  void _maybeSaveLocale(Locale? locale) {
    if (saveLocale && _locale != locale) {
      if (locale == null)
        SharedPreferencesAsync().remove('locale');
      else
        SharedPreferencesAsync().setString('locale', locale.toString());
    }
  }

  // void _maybeLoadLocale() {
  //   if (saveLocale) {
  //     var localeStr = SharedPreferencesAsync().getString('locale');
  //     Locale locale = localeStr != null ? Locale(localeStr) : null;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _forceAndObserveLocale();

    // Add this widget as an observer to listen for system changes
    WidgetsBinding.instance.addObserver(this);
  }

  /// If [saveLocale] is true, the locale will be saved and recovered between
  /// app restarts. This is useful if you want to remember the user's language
  /// preference. If your app only ever uses the current system locale, or if you
  /// save the locale in another way, you can set [saveLocale] to false.
  /// The default is false.
  bool get saveLocale => widget.saveLocale;

  void _forceAndObserveLocale() {
    //
    Locale oldLocale = I18n.locale;
    I18n._forcedLocale = _locale;
    Locale newLocale = I18n.locale;

    I18n._checkLanguageCode(newLocale);

    if (oldLocale != newLocale)
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
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
    _processSystemLocale();
    _rebuildAllChildren();

    return _InheritedI18n(
      data: this,
      child: widget.child,
    );
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

      I18n._checkLanguageCode(newLocale);

      if (oldLocale != newLocale)
        I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);

      if (I18n._forcedLocale == null)
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
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
