## [4.0.3] - 2021/04/14

* Plural support for the `.PO` importer.

## [4.0.2] - 2021/04/07

* Downgraded args: 1.6.0 to be compatible with flutter_driver.
* Better NNBD.

## [4.0.0] - 2021/03/07

* Now allows both string-keys (like `"Hello there".i18n` as shown in the `example1` dir) and identifier-keys (
  like `greetings.i18n` as shown in the `example2` dir).
* Breaking change: If some translation did not exist in some language, it would show the translation key itself as the
  missing translation. This worked well with string-keys, but not with identifier-keys. Now, if some translation is
  missing, it first tries to show the untranslated string, and only if that is missing too it shows the key as the
  translation. This change is unlikely to be noticed by anyone, but still a breaking change.

## [3.0.3] - 2021/03/06

* Nullsafety.
* Breaking change: During app initialization, the system locale may be `null` for a few moments. During this time, in
  prior version _2.0.0_ it would use the `Translations` default locale. Now, in version _3.0.0_, it will use the global
  locale defined in `I18n.defaultLocale`, which by default is `Locale("en", "US")`. You can change this default in your
  app's main method.
* New `Translations.from()` constructor, which responds better to hot reload.
* Fixed the PO importer to ignore empty keys.
* The docs now explain better how to add plurals with translations by locale.

## [2.0.0] - 2021/30/21

* Plural modifiers: `zeroOne` (for 0 or 1 elements), and `oneOrMore` (for 1 and more elements).
* Fix for when no applicable plural modifier is found. It now correctly defaults to the unversioned string.

## [1.5.1] - 2021/01/21

* `.PO` and `.JSON` importers contributed by <a href="https://github.com/bauerj">Johann Bauer</a>.

## [1.4.6] - 2020/01/07

* Sprintf version bump to 5.0.0.

## [1.4.5] - 2020/10/17

* Added `key` and `id` to `I18n` widget constructor.

## [1.4.4] - 2020/09/14

* Docs improvement.

## [1.4.3] - 2020/09/11

* Better error message for `I18n.of`.

## [1.4.2] - 2020/06/26

* Bumped `sprintf` to version `4.1.0`, which adds compatibility for future Dart features that require a Dart SDK
  constraint with a lower bound that is `>=2.0.0`.

## [1.4.1] - 2020/06/22

* Allow multi-line statements in getstrings utility.

## [1.4.0] - 2020/06/05

* More plural modifiers: `three`, `four`, `five`, `six`, and `ten`.
* For Czech language: `twoThreeFour` plural modifier.

## [1.3.9] - 2020/06/02

* GetStrings exporting utility.

## [1.3.8] - 2020/05/28

* Docs improvement (no code changes).

## [1.3.7] - 2020/05/19

* Docs improvement (no code changes).

## [1.3.6] - 2020/05/01

* Docs improvement (no code changes).

## [1.3.5] - 2020/04/10

* Added fill() method to default.i18n.dart.

## [1.3.4] - 2020/02/26

* Don't record unnecessary missing translations with the Translation.byLocale constructor.

## [1.3.3] - 2020/02/26

* Commented unnecessary tests.

## [1.3.2] - 2019/01/29

* Added localizationsDelegates and supportedLocales to the docs.

## [1.3.1] - 2019/01/21

* Docs improvement.

## [1.3.0] - 2019/01/20

* I18n.observeLocale() can be used to observe locale changes.

* Breaking change: Accepts Locale("en", "US"), but not Locale("en_US") anymore, which was wrong. See "A quick recap of
  Dart locales" in the docs, for more details.

## [1.2.0] - 2019/12/19

* Fill fix. Docs improvement.

## [1.1.3] - 2019/12/19

* Interpolation.

## [1.1.1] - 2019/12/11

* Docs improvement.

## [1.1.0] - 2019/11/07

* Better fallback.

## [1.0.9] - 2019/10/23

* Added FAQ to docs.
* Default import records keys.

## [1.0.3] - 2019/10/22

* First working version.

## [0.0.1] - 2019/10/19

* Initial commit.

