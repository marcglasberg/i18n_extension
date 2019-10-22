import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

/// Wrap your widget tree with the `I18n` widget.
/// This will translate your strings to the **current system locale**:
///
/// ```dart
/// import 'package:i18n_extension/i18n_widget.dart';
///
/// @override
/// Widget build(BuildContext context) {
///   return I18n(
///       child: Scaffold( ... )
///   );
/// }
/// ```
///
/// You can override it with any locale, like this:
///
/// ```dart
/// return I18n(
/// locale: Locale("pt_br"),
/// child: Scaffold( ... )
/// ```
///
class I18n extends StatefulWidget {
  //
  /// Returns the forced-locale, if it is not null.
  /// Otherwise, returns  the system-locale.
  static Locale get locale => _forcedLocale ?? _systemLocale;

  /// The locale read from the system.
  static Locale _systemLocale;

  static Locale get systemLocale => _systemLocale;

  /// Locale to override the system locale.
  static Locale _forcedLocale;

  static Locale get forcedLocale => _forcedLocale;

  /// The locale, as a lowercase string. For example: "en_us" or "pt_br".
  static String get localeStr => locale.toString().toLowerCase();

  /// The language of the locale, as a lowercase string. For example: "en" or "pt".
  static String get language => locale.languageCode.toLowerCase();

  final Widget child;
  final Locale initialLocale;

  I18n({
    @required this.child,
    this.initialLocale,
  });

  /// Getter:
  /// print(I18n.of(context).locale);
  ///
  /// Setter:
  /// I18n.of(context).locale = Locale("en_US");
  ///
  static _I18nState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedI18n) as _InheritedI18n).data;
  }

  /// This should be used useful for tests ONLY.
  /// To change the locale in the real app, use: I18n.of(context).locale = Locale("en_US");
  @visibleForTesting
  static define(Locale locale) => I18n._forcedLocale = locale;

  @override
  _I18nState createState() => new _I18nState();
}

class _I18nState extends State<I18n> {
  //
  Locale _locale;

  Locale get locale => _locale;

  set locale(Locale locale) {
    if (this._locale != locale)
      setState(() {
        this._locale = locale;
        I18n._forcedLocale = _locale;
      });
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    I18n._forcedLocale = _locale;
  }

  @override
  Widget build(BuildContext context) {
    //
    _processSystemLocale();

    return _InheritedI18n(
      data: this,
      child: widget.child,
    );
  }

  void _processSystemLocale() {
    var newSystemLocale = Localizations.localeOf(context, nullOk: true);
    if (newSystemLocale != I18n._systemLocale) {
      I18n._systemLocale = newSystemLocale;
      if (I18n._forcedLocale == null)
        SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    }
  }
}

class _InheritedI18n extends InheritedWidget {
  //
  final _I18nState data;

  _InheritedI18n({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedI18n old) => true;
}
