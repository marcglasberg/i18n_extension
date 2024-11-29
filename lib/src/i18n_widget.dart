// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

/// You must have a single [I18n] widget in your widget tree, above
/// your [MaterialApp] or [CupertinoApp] widgets:
///
/// ```dart
/// import 'package:i18n_extension/i18n_extension.dart';
///
/// Widget build(BuildContext context) {
///   return I18n(
///       child: MaterialApp(...)
///   );
/// }
/// ```
///
/// If you want, you may also provide an [initialLocale].
/// Otherwise, the system locale will be used:
///
/// ```dart
/// Widget build(BuildContext context) {
///   return I18n(
///       initialLocale: locale('pt', 'BR'),
///       child: ...
///   );
/// }
/// ```
///
class I18n extends StatefulWidget {
  //
  static final _i18nKey = GlobalKey<_I18nState>();

  final Widget child;
  final Locale? initialLocale;

  /// You must have a single [I18n] widget in your widget tree, above
  /// your [MaterialApp] or [CupertinoApp] widgets:
  ///
  /// ```dart
  /// import 'package:i18n_extension/i18n_extension.dart';
  ///
  /// Widget build(BuildContext context) {
  ///   return I18n(
  ///       child: MaterialApp(...)
  ///   );
  /// }
  /// ```
  ///
  /// If you want, you may also provide an [initialLocale].
  /// Otherwise, the system locale will be used:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return I18n(
  ///       initialLocale: locale('pt', 'BR'),
  ///       child: ...
  ///   );
  /// }
  /// ```
  ///
  I18n({
    required this.child,
    this.initialLocale,
  }) : super(key: _i18nKey);

  /// Returns the forced-locale, if it is not null.
  /// Otherwise, returns the system-locale.
  /// Note: If the system-locale is not defined for some reason,
  /// the locale will be `Locale("en", "US")`.
  static Locale get locale => _forcedLocale ?? _systemLocale;

  /// The locale, as a lowercase string. For example: "en_us" or "pt_br".
  static String get localeStr => normalizeLocale(locale);

  /// The locale read from the system.
  static Locale get systemLocale => _systemLocale;

  /// Locale to override the system locale.
  static Locale? get forcedLocale => _forcedLocale;

  /// The language of the current locale, as a lowercase string.
  /// For example: "en" or "pt".
  static String get language => getLanguageFromLocale(locale);

  /// When the app starts, the [systemLocale] is read from the system as soon as possible.
  /// The system locale might be unavailable for a brief period. Usually, this is not an
  /// issue and won't be noticeable, but in rare cases, this locale will be used until
  /// the actual system locale is determined. You can change this to your preferred
  /// locale if needed. Otherwise, leave it as is.
  static Locale preInitializationLocale = const Locale("en", "US");

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

  /// Return the string representation of the locale, normalized
  /// (trims spaces and underscore).
  static String normalizeLocale(Locale locale) {
    String str = locale.toString().toLowerCase();
    RegExp pattern = RegExp('^[_ ]+|[_ ]+\$');
    return str.replaceAll(pattern, '');
  }

  /// Given a locale, return the decimal separator.
  /// For example, for en_US it's "." but for pt_BR it's ",".
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
  /// I18n.of(context).locale = Locale("en", "US");
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
  ///     I18n.define(Locale("pt", "BR"));
  ///
  /// To return the current locale to the system default:
  ///
  ///     I18n.define(null);
  ///
  /// IMPORTANT: This will change the current locale only for the i18n_extension,
  /// and not for Flutter as a whole. In other words, the widgets will not rebuild.
  /// This static method should be used in tests ONLY. The real app, you should
  /// instead do: `I18n.of(context).locale = Locale("en", "US");`
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

class _I18nState extends State<I18n> {
  //
  Locale? _locale;

  /// To read the current locale:
  ///
  ///     Locale locale = I18n.of(context).locale;
  ///     Locale locale = I18n.locale; // Also works.
  ///
  /// Or, to get the locale as a lowercase string:
  ///
  ///     // Example: "en_us".
  ///     String localeStr = I18n.localeStr;
  ///
  /// Or, to get the language of the locale, lowercase:
  ///
  ///     // Example: "en".
  ///     String language = I18n.language;
  ///
  Locale get locale => _locale ?? I18n._getSystemOrPreInitializationLocale();

  /// To change the current locale:
  ///
  ///     I18n.of(context).locale = Locale("pt", "BR");
  ///
  /// To return the current locale to the system default:
  ///
  ///     I18n.of(context).locale = null;
  ///
  /// Note: This will change the current locale only for the i18n_extension,
  /// and not for Flutter as a whole.
  ///
  set locale(Locale? locale) {
    if (_locale != locale)
      setState(() {
        _locale = locale;
        _forceAndObserveLocale();
      });
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _forceAndObserveLocale();
  }

  void _forceAndObserveLocale() {
    Locale oldLocale = I18n.locale;
    I18n._forcedLocale = _locale;
    Locale newLocale = I18n.locale;

    I18n._checkLanguageCode(newLocale);

    if (oldLocale != newLocale)
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
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
    Locale locale = PlatformDispatcher.instance.locale;
    Locale? fromLocalizations = Localizations.maybeLocaleOf(context);
    Locale? fromView = View.of(context).platformDispatcher.locale;

    Locale newSystemLocale = fromLocalizations ?? fromView;

    // TODO: MARCELO
    print('\n------------------------------------------------------------');
    print('fromLocalizations = ${fromLocalizations}');
    print('fromView = ${fromView}');

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
  bool updateShouldNotify(_InheritedI18n old) => true;
}
