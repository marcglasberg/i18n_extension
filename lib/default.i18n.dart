// Developed by Marcelo Glasberg (2019) https://glasberg.dev and https://github.com/marcglasberg
// For more info, see: https://pub.dartlang.org/packages/i18n_extension

import 'i18n_extension.dart';

/// When you create a widget that has translatable strings,
/// add this default import to the widget's file:
///
/// ```dart
/// import 'package:i18n_extension/default.i18n.dart';
/// ```
///
/// This will allow you to add `.i18n` and `.plural()` to your strings,
/// but won't translate anything.
///
extension Localization on String {
  //
  String get i18n => recordMissingKey(this);

  String plural(value) {
    recordMissingKey(this);
    return replaceAll("%d", value.toString());
  }

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
}
