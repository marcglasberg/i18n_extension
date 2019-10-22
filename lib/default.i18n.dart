// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

/// When you create a widget that has translatable strings,
/// add this default import to the widget's file:
///
/// ```dart
/// import 'package:i18n_extension/default.i18n.dart';
/// ```
///
/// This will allow you to add `.i18n` and `.number()` to your strings, but won't translate anything.
///
extension Localization on String {
  //
  String get i18n => this;

  String number(int value) => this.replaceAll("%d", value.toString());

  String version(Object modifier) => this.replaceAll("%d", modifier.toString());
}
