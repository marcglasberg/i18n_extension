import 'package:flutter/widgets.dart';

class I18n extends StatelessWidget {
  //
  static Locale _systemLocale;
  static Locale _forcedLocale;

  static Locale _locale;
  static String _localeStr;

  static Locale get locale => _locale;

  static String get localeStr => _localeStr;

  static void _refresh() {
    _locale = _forcedLocale ?? _systemLocale;
    _localeStr = locale.toString().toLowerCase();
  }

  final Widget child;

  I18n({
    @required this.child,
    Locale locale,
  }) {
    _forcedLocale = locale;
    _refresh();
  }

  I18n.define(Locale locale) : this(child: null, locale: locale);

  @override
  Widget build(BuildContext context) {
    _systemLocale = Localizations.localeOf(context, nullOk: true);
    _refresh();
    return child;
  }
}
