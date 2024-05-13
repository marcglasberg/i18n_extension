## 12.0.0

* Compatible with Flutter 3.22.0 and Dart 3.4.0

## 11.0.13

* BREAKING CHANGE: Replace the previous `Translations()` constructor with `Translations.byText()`.
  Like before, it supports `String` as translation keys, organized per key.


* The previous `Translations.byLocale()` works just as before. Like before, it supports `String` as
  translation keys, organized per locale.


* Translation subtype `TranslationsByLocale` still exist, but it's not visible anymore.
  If you were writing `TranslationsByLocale t = new TranslationsByLocale(...` you should now write
  `var t = Translations.byLocale(...`, or `Translations t = Translations.byLocale(...`


* Now you can use ANY object type as translation keys. Before, it was only possible to use strings
  as translation keys. You can now use `Translations.byId<T>()` and provide the type `T` of your
  identifier. Your `T` can be anything, including `String`, `int`, `double`, `DateTime`, or even
  your own custom object types, as long as they implement `==` and `hashCode`. If you use `Object`
  or `Object?`/`dynamic` then anything can be translated. Don't forget that your extensions,
  like `.i18n`, will need to be on your type. For example, if you use `int` as your key type,
  then you will need to declare `extension Localization on int { ... }`.


* If you want to provide translations as a const map, and `String` as translation keys,
  use the `const ConstTranslations()` constructor.

  > To sum up:
  > * `Translations.byText()` supports `String` as translation keys, organized per key.
  > * `Translations.byLocale()` supports `String` as translation keys, organized per
      locale.
  > * `Translations.byId<T>()` supports any object of type `T` as translation keys.
  > * `const ConstTranslations()` supports defining translations with a `const` Map,
      and `String` as translation keys.

* Now the core features of the i18n_extension package are available as a standalone Dart-only
  package: https://pub.dev/packages/i18n_extension_core. You may use that core package when you
  are developing a Dart server (backend) with [Celest](https://celest.dev/), or when developing your
  own Dart-only package that does not depend on Flutter.

  > **For Flutter applications nothing changes.**
  > You don't need to import the core package directly.
  > You should continue to use this i18n_extension package, which already exports
  > the core code plus the `I18n` widget that you use to wrap your widget tree.

## 10.0.3

* The importer library developed by Johann Bauer is now independently available as a standalone
  package. You can find it at https://pub.dev/packages/i18n_extension_importer. This new package
  offers capabilities for importing translations in both `.PO` and `.JSON` formats.
  It also includes the `GetStrings` exporting utility, which is a useful script designed to
  automate the export of all translatable strings from your project.

* Removed unused packages that were previously used by the removed importer.

## 9.0.2

* Flutter 3.10 e Dart 3.0.0

* Removed the importer library developed by Johann Bauer, so that users of i18n_extension don't
  need to import the analyzer and other unnecessary dependencies. See version [10.0.2] above.

## 8.0.0

* Breaking change: Removed dependency on analyzer and gettext_parser. The getStrings doesn't work in
  this version.

## 6.0.0

* Analyzer and sprintf version bump.

## 5.0.1

* Analyzer version bump.

## 5.0.0

* Flutter 3.0

## 4.2.1

* The `localizePlural` method now accepts any object (not only an integer anymore). It will convert
  that object into an integer, and use that result. Se the method documentation for more
  information. To make use of it, you may declare your `plural()` methods as
  `String plural(value) => localizePlural(value, this, _t);` from now on.
  Example: `'This is one item'.plural(2)` is now the same as
  writing `'This is one item'.plural('2')`.

## 4.1.3

* Bump version. Docs improvement.

## 4.1.1

* `.po` importer fix.

## 4.1.0

* Removed useless `uses-material-design: true`.
* Bumped dependencies versions (in special args: ^2.0.0).

## 4.0.3

* Plural support for the `.PO` importer.

## 4.0.2

* Downgraded args: 1.6.0 to be compatible with flutter_driver.
* Better NNBD.

## 4.0.0

* Now allows both string-keys (like `'Hello there'.i18n` as shown in the `example1` dir) and
  identifier-keys (
  like `greetings.i18n` as shown in the `example2` dir).
* Breaking change: If some translation did not exist in some language, it would show the translation
  key itself as the missing translation. This worked well with string-keys, but not with
  identifier-keys. Now, if some translation is missing, it first tries to show the untranslated
  string, and only if that is missing too it shows the key as the translation. This change is
  unlikely to be noticed by anyone, but still a breaking change.

## 3.0.3

* Nullsafety.
* Breaking change: During app initialization, the system locale may be `null` for a few moments.
  During this time, in prior version _2.0.0_ it would use the `Translations` default locale. Now, in
  version _3.0.0_, it will use the global locale defined in `I18n.defaultLocale`, which by default
  is `Locale('en', 'US')`. You can change this default in your app's main method.
* New `Translations.from()` constructor, which responds better to hot reload.
* Fixed the PO importer to ignore empty keys.
* The docs now explain better how to add plurals with translations by locale.

## 2.0.0

* Plural modifiers: `zeroOne` (for 0 or 1 elements), and `oneOrMore` (for 1 and more elements).
* Fix for when no applicable plural modifier is found. It now correctly defaults to the unversioned
  string.

## 1.5.1

* `.PO` and `.JSON` importers contributed by <a href="https://github.com/bauerj">Johann Bauer</a>.

## 1.4.6

* Sprintf version bump to 5.0.0.

## 1.4.5

* Added `key` and `id` to `I18n` widget constructor.

## 1.4.3

* Better error message for `I18n.of`.

## 1.4.2

* Bumped `sprintf` to version `4.1.0`, which adds compatibility for future Dart features that
  require a Dart SDK constraint with a lower bound that is `>=2.0.0`.

## 1.4.1

* Allow multi-line statements in getstrings utility.

## 1.4.0

* More plural modifiers: `three`, `four`, `five`, `six`, and `ten`.
* For Czech language: `twoThreeFour` plural modifier.

## 1.3.9

* GetStrings exporting utility.

## 1.3.5

* Added fill() method to default.i18n.dart.

## 1.3.4

* Don't record unnecessary missing translations with the Translation.byLocale constructor.

## 1.3.3

* Commented unnecessary tests.

## 1.3.2

* Added localizationsDelegates and supportedLocales to the docs.

## 1.3.0

* I18n.observeLocale() can be used to observe locale changes.

* Breaking change: Accepts Locale('en", 'US'), but not Locale('en_US') anymore, which was wrong.
  See "A quick recap of Dart locales" in the docs, for more details.

## 1.2.0

* Fill fix. Docs improvement.

## 1.1.3

* Interpolation.

## 1.1.1

* Better fallback.

## 1.0.9

* Default import records keys.

## 1.0.3

* First working version.

## 0.0.1

* Initial commit on Oct 19, 2019.

