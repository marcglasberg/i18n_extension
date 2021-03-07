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
  /// During app initialization, the system locale may be `null` for a few
  /// moments, so this default locale will be used instead. You can change
  /// this to reflect your preferred locale.
  static Locale defaultLocale = const Locale("en", "US");

  /// Returns the forced-locale, if it is not null.
  /// Otherwise, returns the system-locale.
  /// Note: If the system-locale is not defined by some reason,
  /// the locale will be `Locale("en", "US")`.
  static Locale get locale => _forcedLocale ?? _systemLocale;

  /// The locale read from the system.
  static Locale _systemLocale = defaultLocale;

  static Locale get systemLocale => _systemLocale;

  /// Locale to override the system locale.
  static Locale? _forcedLocale;

  static Locale? get forcedLocale => _forcedLocale;

  /// The locale, as a lowercase string. For example: "en_us" or "pt_br".
  static String get localeStr => normalizeLocale(locale);

  /// The language of the current locale, as a lowercase string.
  /// For example: "en" or "pt".
  static String get language => getLanguageFromLocale(locale);

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

  final Widget child;
  final Locale? initialLocale;

  /// The [I18n] widget should wrap the [child] which contains the tree of
  /// widgets you want to translate. If you want, you may provide an
  /// [initialLocale]. You may also provide a [key], or, for advanced uses,
  /// an [id] which you can use with the [forceRebuild] function.
  ///
  I18n({
    Key? key,
    String? id,
    required this.child,
    this.initialLocale,
  }) : super(
            key: key ??
                ((id != null && id.isNotEmpty)
                    ? GlobalObjectKey<_I18nState>(id)
                    : null));

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
      throw TranslationsException(
          "Can't find the `I18n` widget up in the tree. "
          "Please make sure to wrap some ancestor widget with `I18n`.");

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
  /// Note: The id must be a literal, const String, because [GlobalObjectKey]
  /// creates the key from the the id identity.
  ///
  static void forceRebuild(String id) {
    var key = GlobalObjectKey<_I18nState>(id);
    var state = key.currentState;

    if (state == null)
      throw TranslationsException("Can't find a `I18n` widget "
          "with id=`$id` up in the tree.");

    state._rebuildAllChildren();

    // ignore: invalid_use_of_protected_member
    state.setState(() {});
  }

  /// To change the current locale:
  ///
  ///     I18n.define(Locale("pt", "BR"));
  ///
  /// To return the current locale to the system default:
  ///
  ///     I18n.define(null);
  ///
  /// Note: This will change the current locale only for the i18n_extension,
  /// and not for Flutter as a whole.
  ///
  /// IMPORTANT: This should be used in tests ONLY. The real app, you should
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
      throw TranslationsException(
          "Language code '${locale.languageCode}' is invalid: "
          "Contains an underscore character.");
  }

  @override
  _I18nState createState() => _I18nState();
}

// /////////////////////////////////////////////////////////////////////////////

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
  Locale get locale => _locale ?? I18n.defaultLocale;

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
    Locale newSystemLocale =
        Localizations.maybeLocaleOf(context) ?? I18n.defaultLocale;

    if (newSystemLocale != I18n._systemLocale) {
      //
      Locale oldLocale = I18n.locale;
      I18n._systemLocale = newSystemLocale;
      Locale newLocale = I18n.locale;

      I18n._checkLanguageCode(newLocale);

      if (oldLocale != newLocale)
        I18n.observeLocale(oldLocale: oldLocale, newLocale: newLocale);

      if (I18n._forcedLocale == null)
        WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
    }
  }
}

// /////////////////////////////////////////////////////////////////////////////

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

// /////////////////////////////////////////////////////////////////////////////
