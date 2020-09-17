import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'i18n_extension.dart';

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
///     initialLocale: Locale("pt", "BR"),
///     child: Scaffold( ... )
/// ```
///
class I18n extends StatefulWidget {
  //
  /// Returns the forced-locale, if it is not null.
  /// Otherwise, returns the system-locale.
  static Locale get locale => _forcedLocale ?? _systemLocale;

  /// The locale read from the system.
  static Locale _systemLocale;

  static Locale get systemLocale => _systemLocale;

  /// Locale to override the system locale.
  static Locale _forcedLocale;

  static Locale get forcedLocale => _forcedLocale;

  /// The locale, as a lowercase string. For example: "en_us" or "pt_br".
  static String get localeStr => normalizeLocale(locale);

  /// The language of the current locale, as a lowercase string. For example: "en" or "pt".
  static String get language => getLanguageFromLocale(locale);

  /// Return the lowercase language-code of the given locale. Or null if the locale is null.
  static String getLanguageFromLocale(Locale locale) {
    _checkLanguageCode(locale);
    String str = locale?.languageCode?.toLowerCase();
    return (str == null) ? null : str.trim();
  }

  /// Return the string representation of the locale, normalized (trims spaces and underscore).
  static String normalizeLocale(Locale locale) {
    if (locale == null) return null;
    String str = locale.toString().toLowerCase();
    RegExp pattern = RegExp('^[_ ]+|[_ ]+\$');
    return str.replaceAll(pattern, '');
  }

  /// This global callback is called whenever the locale changes.
  /// Notes:
  /// • To obtain the language, you can do: String language = I18n.getLanguage(newLocale);
  /// • To obtain the normalized locale as a string, you can do: String localeStr = I18n.trim(newLocale);
  static void Function({Locale oldLocale, Locale newLocale}) observeLocale;

  final Widget child;
  final Locale initialLocale;

  I18n({
    Key key,
    String id,
    @required this.child,
    this.initialLocale,
  }) : super(key: key ?? (id != null && id.isNotEmpty) ? GlobalObjectKey<_I18nState>(id) : null);

  /// Getter:
  /// print(I18n.of(context).locale);
  ///
  /// Setter:
  /// I18n.of(context).locale = Locale("en", "US");
  ///
  static _I18nState of(BuildContext context) {
    if (context == null)
      throw TranslationsException("Context was passed as null "
          "when calling `I18n.of(context)`.");

    var inherited = context.dependOnInheritedWidgetOfExactType<_InheritedI18n>();

    if (inherited == null)
      throw TranslationsException("Couldn't find the `I18n` widget up in the "
          "tree. Please make sure to wrap some ancestor widget with `I18n`.");

    return inherited.data;
  }

  /// If you have multiple I18n widgets you can call this method to force
  /// specific I18n widgets to rebuild. First, give it an id (and not a key),
  /// for example: `I18n(id:"myWidget", child: ...)`.
  ///
  /// Then, whenever you need to rebuild it: `I18n.forceRebuild("myWidget")`.
  /// Note this is a hack. It is not recommended that you have multiple
  /// I18n widgets in your widget tree.
  ///
  static void forceRebuild(String id) {
    var key = GlobalObjectKey<_I18nState>(id);
    var state = key.currentState;
    state._rebuildAllChildren();

    // ignore: invalid_use_of_protected_member
    state.setState(() {});
  }

  /// This should be used useful for tests ONLY.
  /// To change the locale in the real app, use: I18n.of(context).locale = Locale("en", "US");
  @visibleForTesting
  static define(Locale locale) {
    Locale oldLocale = I18n.locale;
    _forcedLocale = locale;
    Locale newLocale = I18n.locale;
    _checkLanguageCode(newLocale);
    if (I18n.observeLocale != null && oldLocale != newLocale)
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
  }

  static void _checkLanguageCode(Locale locale) {
    if (locale != null && locale.languageCode.contains("_"))
      throw TranslationsException("Language code '${locale.languageCode}' is invalid: "
          "Contains an underscore character.");
  }

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
        Locale oldLocale = I18n.locale;
        I18n._forcedLocale = _locale;
        Locale newLocale = I18n.locale;
        I18n._checkLanguageCode(newLocale);
        if (I18n.observeLocale != null && oldLocale != newLocale)
          I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
      });
  }

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;

    Locale oldLocale = I18n.locale;
    I18n._forcedLocale = _locale;
    Locale newLocale = I18n.locale;
    I18n._checkLanguageCode(newLocale);
    if (I18n.observeLocale != null && oldLocale != newLocale)
      I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);
  }

  @override
  Widget build(BuildContext context) {
    //
    _processSystemLocale();
    _rebuildAllChildren();

    return _InheritedI18n(
      data: this,
      child: widget.child,
    );
  }

  void _rebuildAllChildren() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void _processSystemLocale() {
    var newSystemLocale = Localizations.localeOf(context, nullOk: true);
    if (newSystemLocale != I18n._systemLocale) {
      Locale oldLocale = I18n.locale;
      I18n._systemLocale = newSystemLocale;
      Locale newLocale = I18n.locale;
      I18n._checkLanguageCode(newLocale);
      if (I18n.observeLocale != null && oldLocale != newLocale)
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
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedI18n old) => true;
}
