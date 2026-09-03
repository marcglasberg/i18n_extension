Sponsored by [MyText.ai](https://mytext.ai)

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

## 16.0.0

* When defining your translations, you can now use the modifiers `.male()`, `.female()`
  and `.neutral()`, and then declare a `gender` function that calls the provided
  `localizeGender()`. For example:

  ```dart
  extension Localization on String {
    static final _t = Translations.byText('en-US') +
      {
        'en-US': 'There is a person'
            .male('There is a man')
            .female('There is a woman'),
        'pt-BR': 'Há uma pessoa'
            .male('Há um homem')
            .female('Há uma mulher'),
      };

    String gender(Gender gender) => localizeGender(gender, this, _t);
  }
  ```                

  Then, the UI code can translate it like this:

  ```dart
  'There is a person'.gender(Gender.male); // There is a man
  'There is a person'.gender(Gender.female); // There is a woman
  'There is a person'.gender(Gender.neutral); // There is a person
  ```    

  A gender without a version falls back to the unversioned text, as `Gender.neutral`
  does above. This means `.neutral()` is only needed when the neutral text is not the
  unversioned text. See [Gender modifiers](README.md#gender-modifiers) in the README.

* The default import `default.i18n.dart` now also provides `.gender()`, which returns
  the string unchanged, as `.plural()` does.

* Gender and plural can be combined. To declare all the combinations, nest the plural
  modifiers inside the gender modifiers, and pass the gender to `.plural()`, since
  `localizePlural()` now accepts an optional `gender` parameter:

  ```dart
  extension Localization on String {
    static final _t = Translations.byText('en-US') +
      {
        'en-US': 'There is a person'
            .zero('There is nobody')
            .many('There are %d people')
            .male('There is a man'
                .zero('There are no men')
                .many('There are %d men'))
            .female('There is a woman'
                .zero('There are no women')
                .many('There are %d women')),
        'pt-BR': 'Há uma pessoa'
            .zero('Não há ninguém')
            .many('Há %d pessoas')
            .male('Há um homem'
                .zero('Não há homens')
                .many('Há %d homens'))
            .female('Há uma mulher'
                .zero('Não há mulheres')
                .many('Há %d mulheres')),
      };

    String plural(value, [Gender? gender]) => localizePlural(value, this, _t, gender: gender);
  }
  ```

  Use it like this:

  ```dart
  'There is a person'.plural(3, Gender.female); // There are 3 women
  'There is a person'.plural(1, Gender.male); // There is a man
  'There is a person'.plural(0, Gender.neutral); // There is nobody
  ```

  The plural versions of the given gender are tried first, then the gender version
  itself (which is the singular, for 1 element), then the plural versions that don't
  depend on the gender, and finally the unversioned text. So only the combinations that
  actually differ need to be declared. See
  [Combining gender and plural](README.md#combining-gender-and-plural) in the README, and
  the example in `example/lib/11_gender_plural_example/main_gender_plural.dart`.

  The file importers support it too. In `.json` and `.yaml` files, a gender version may
  itself be a map of plural versions, with its own `other`:

  ```json
  "There is a person": {
    "other": "Hay una persona",
    "zero": "No hay nadie",
    "many": "Hay %d personas",
    "male": { "other": "Hay un hombre", "zero": "No hay hombres", "many": "Hay %d hombres" },
    "female": { "other": "Hay una mujer", "zero": "No hay mujeres", "many": "Hay %d mujeres" }
  }
  ```    

  And:

  ```yaml
  "There is a person":
    other: "Hay una persona"
    zero: "No hay nadie"
    many: "Hay %d personas"
    male:
      other: "Hay un hombre"
      zero: "No hay hombres"
      many: "Hay %d hombres"
    female:
      other: "Hay una mujer"
      zero: "No hay mujeres"
      many: "Hay %d mujeres"
  ```

  In `.arb` files, a select and a plural may now be nested, one inside the other, which
  is the ICU way of combining gender and number:

  ```json
  "people": "{gender, select, male{{count, plural, =0{No hay hombres} one{Hay un hombre} other{Hay # hombres}}} female{{count, plural, =0{No hay mujeres} one{Hay una mujer} other{Hay # mujeres}}} other{{count, plural, =0{No hay nadie} one{Hay una persona} other{Hay # personas}}}}"
  ```

  The `one` (or `=1`) case of a gender becomes the gender version itself (its singular),
  and the `other` case of a gender becomes its `many` version (unless there's a `many`
  case) and also its singular, when there's no `one` case. A plural inside a plural, a
  select inside a select, and deeper nesting are still not supported.

* In `.json` and `.yaml` files, the versions named `male`, `female` and `neutral` are
  now the gender versions, the same as `.male()`, `.female()` and `.neutral()` in Dart,
  for `.gender()`. Likewise, in `.arb` files, the `male`, `female` and `neutral` cases
  of an ICU select are now the gender versions:

  ```json
  "pronoun": "{gender, select, male{él} female{ella} other{ellos}}"
  ```

  ```dart
  'pronoun'.gender(Gender.male); // él
  'pronoun'.gender(Gender.neutral); // ellos (the `other` case)
  ```

  The files themselves don't change. What changes is how you read those versions in
  Dart: before, you'd use `.version('male')`, and now you use `.gender(Gender.male)`.
  Versions and select cases with any other name still work with `.version()`, as before.

* In `.po` files, the entries with the contexts `male`, `female` and `neutral` (like
  `msgctxt "male"`) are now the gender versions of the entry with the same `msgid`, for
  `.gender()`, and a gender entry may have `msgid_plural`, to combine gender and plural,
  for `.plural(count, gender)`. Before, the contexts were ignored. Entries with any other
  context are still read as if they had no context. See
  [Plurals and genders in PO files](README.md#plurals-and-genders-in-po-files).

* Fixed: `.times(10, text)` is now the same as `.ten(text)`. Before, `.plural(10)` didn't
  find it, since it looks for the `ten` version.

* Note: This is a major version because the new names are likely to clash with client
  code that implemented its own gender modifiers.

## 15.3.2

* Translations can now also be loaded from YAML files, with `Translations.byFile()` and
  `Translations.byHttp()`. Files ending with `.yaml` or `.yml` are loaded in the same way
  as `.json` and `.po` files, with the language tag taken from the file name. Each file
  must contain a map of translation keys to translations, where each translation is
  text, or a map of its versions, like plurals and genders (see the next item):

  ```yaml
  Welcome to this demo.: Bienvenido a esta demostración.
  "i18n Demo": Demostración i18n
  "You clicked the button %d times:":
    other: "Hiciste clic en el botón %d veces:"
    zero: "No hiciste clic en el botón:"
    one: "Hiciste clic en el botón una vez:"
    12: "Hiciste clic en el botón una docena de veces:"
  ```

  Comments, quoted and unquoted text, anchors, and the multiline styles (`|` and `>`) are
  supported. Note that in YAML an unquoted `123`, `true` or empty value is read as a
  number, a boolean or null, not as text, so quote those (except the integer versions,
  like the `12` above, which may be unquoted). Lists are not allowed. A file that breaks
  these rules fails with a clear error, or is skipped when `failOnInvalidResource` is
  `false`.

  The new loaders are `I18nYamlLoader()` (for `.yaml`) and `I18nYamlLoader.yml()`
  (for `.yml`), and both are included in `I18n.loaders` by default.

* In `.json` and `.yaml` files, a translation may now be a map of versions, for plurals
  and genders. This is the same as using the string modifiers `.zero()`, `.one()`,
  `.times()`, `.many()`, `.modifier()` etc. in Dart. The `other` version is required, and
  is the text used when no other version applies (in Dart, the string the modifiers are
  called on). For example:

  ```json
  {
    "You clicked the button %d times:": {
      "other": "Hiciste clic en el botón %d veces:",
      "zero": "No hiciste clic en el botón:",
      "one": "Hiciste clic en el botón una vez:",
      "12": "Hiciste clic en el botón una docena de veces:"
    },
    "There is a person": {
      "other": "Hay una persona",
      "male": "Hay un hombre",
      "female": "Hay una mujer"
    }
  }
  ```

  The plural versions are `zero`, `one`, `two`, `three`, `four`, `five`, `six`, `ten`,
  `twoThreeFour`, `oneOrMore`, `zeroOne` and `many`, plus any integer, like `12`, which is
  the same as `.times(12)`. Any other name, like `male`, is a version for `.version()`.
  Each version must be text (versions can't be nested), and a map without `other`, or
  with two versions that mean the same, like `one` and `1`, fails with a clear error.
  In YAML, the versions are nested keys, as in the YAML example above.

  The encoding is done by the base `I18nLoader`, when the decoded translations are
  checked, so custom loaders whose `decode()` returns maps of versions get it too.

* Translations can now also be loaded from ARB files (`.arb`), the format used by
  Flutter's own `gen-l10n` tool and by most translation services, with
  `Translations.byFile()` and `Translations.byHttp()`. The new loader is
  `I18nArbLoader()`, included in `I18n.loaders` by default.

  The locale comes from the `@@locale` attribute, or else from the file name, which may
  be the locale itself (`es-ES.arb`, `es_ES.arb`) or end with it after an underscore,
  as Flutter names them (`app_es.arb`, `intl_messages_pt_BR.arb`, `app_zh_Hans_CN.arb`).
  The `@@` attributes and the `@key` metadata are ignored, as they are for translators
  and tools. The ICU messages are converted to the format of this package:

  ```json
  {
    "@@locale": "es",
    "welcome": "Bienvenido, {name}",
    "itemCount": "{count, plural, =0{Sin artículos} one{Un artículo} other{# artículos}}",
    "pronoun": "{gender, select, male{él} female{ella} other{ellos}}"
  }
  ```

    * Placeholders like `{name}` or `{0}` are kept, to be filled with `.args()`.
      Formatted placeholders, like `{price, number, currency}` or `{date, date, ::yMd}`,
      become simple placeholders, like `{price}`, since the loader doesn't format values:
      pass them already formatted to `.args()`.

    * A plural becomes a translation with plural versions, for `.plural(count)`. Both `#`
      and the plural variable become the number. The cases `=0`/`zero`, `=1`/`one`,
      `=2`/`two`, `few`, `many`, `=N` and `other` become the versions `.zero()`, `.one()`,
      `.two()`, `.twoThreeFour()`, `.many()`, `.times(N)` and the default text. The plural
      may be part of a longer message, in which case each version contains the whole
      message.

    * A select (like a gender) becomes a translation with versions, for `.version(case)`,
      with `other` as the default text.

    * A message may contain a single plural or select, and not one inside the other, since
      `.plural()` and `.version()` select a translation by a single value. Such messages,
      and the plural `offset`, fail to load with an error that explains the problem.

    * By default there's no escaping, as in `gen-l10n`: an apostrophe is just an
      apostrophe.
      For files written with `use-escaping: true`, where `''` is an apostrophe and text
      between single quotes is literal, use `I18nArbLoader(useEscaping: true)`:

      ```dart
      I18n.loaders.removeWhere((loader) => loader() is I18nArbLoader);
      I18n.loaders.add(() => I18nArbLoader(useEscaping: true));
      ```

* `Translations.byFile()` and `Translations.byHttp()` have two flags that control what
  happens when a single file or resource fails to load. Both default to `true`, which
  fails the whole load, so that no translations are loaded at all:

    * `failOnMissingResource` applies to a file or resource that cannot be read: a 404 or
      network error, or an asset that fails to load (which on the web is a download).

    * `failOnInvalidResource` applies to a file or resource that was read, but cannot be
      decoded (invalid JSON, YAML, ARB or ICU message), or has invalid content, like a
      value that is not a String.

  When a flag is `false`, that kind of failure is reported to
  `I18n.failedResourceCallback`
  and skipped, while the other files or resources still load. The error is a
  `MissingTranslationsResourceException` or an `InvalidTranslationsResourceException`
  (both are `TranslationsException`s), which carry the `resource` that failed and the
  underlying `error`, so the callback can tell them apart and log the problem file
  without parsing the message. The `I18nLoader.fromAssetDir()` and `fromUrl()` methods
  have the same two flags.

  This requires `i18n_extension_core` 5.2.0.

* The loader classes `I18nLoader`, `I18nJsonLoader`, `I18nPoLoader`, `I18nYamlLoader`
  and `I18nArbLoader` are now exported by the package, so that you can configure them
  or extend `I18nLoader` without importing the `src` files.

* Loaders may now override `I18nLoader.decodeFile()`, which receives the file name and
  its content, and returns both the translations and the language tag. The default
  implementation calls `decode()` and takes the language tag from the file name, so
  custom loaders that only override `decode()` keep working.

## 15.3.1

* `Translations.byFile()` now also works on the web. Previously, it did nothing there,
  so the app showed the default-locale strings, and the only way to load translation
  files on the web was `Translations.byHttp()`, listing each file by name.

  There was no technical reason for that restriction. `Translations.byFile()` doesn't
  read the user's file system, but the assets bundled with the app, and on the web
  Flutter downloads those from the web server that hosts the app, like it does with
  images and fonts. The list of files also comes from the asset manifest, which Flutter
  provides on the web too. So the same code now works on all platforms, including
  scanning the directory and its subdirectories for `.json` and `.po` files.

  On the web, the default timeout of `load()` for `Translations.byFile()` is 1 second,
  the same as for `Translations.byHttp()`, instead of 0.5 seconds, since the files are
  downloaded. As before, if the timeout is reached, the load continues in the
  background, and the widgets rebuild when it finishes.

## 15.3.0

* Fixed the way the `I18n` widget picks the app locale from the list of locales set in
  the device settings, when the user's preferred language is supported only in a
  different regional variant.

  The device provides its locales in order of user preference, for example
  `[pt-PT, en-US]`. Since version 15.1.1, the widget would pick the first device locale
  that _exactly_ matched one of the `supportedLocales`, so with
  `supportedLocales: [pt-BR, en-US]` the app would show English, even though the user
  prefers Portuguese. The same happened with device locales `[zh-Hans-GB, en]` and
  `supportedLocales: [zh, en]`, which resolved to `en` instead of `zh`.

  Now, the widget prefers a different variant of the user's preferred language, over
  the user's second language, so the examples above resolve to `pt-BR` and `zh`. For
  each device locale, in order, it looks for a supported locale that matches it exactly,
  then by language and script, then by language and country, and then by language only.
  This uses Flutter's `basicLocaleListResolution`, the same algorithm `MaterialApp` uses
  by default, and the one versions 13.x relied on. Also, if no device language is
  supported at all, the app locale is now the first supported locale (previously, the
  unsupported first device locale was used), so list your default locale first.

* The locale resolution is now configurable, through the new `localeResolver` parameter
  of the `I18n` widget. The default is `I18n.languageMatchResolver`, described above.
  The previous behavior is available as `I18n.exactMatchResolver`:

  ```dart
  I18n(
    supportedLocales: ['pt-BR'.asLocale, 'en-US'.asLocale],
    localeResolver: I18n.exactMatchResolver, // Restores the previous behavior.
    child: AppCore(),
  );
  ```

  You may also provide your own resolver function, which receives the device locales
  and the supported locales, and returns the locale the app should use. See the
  "Locale resolution" section of the README for details.

## 15.2.0

* `Translations.byFile()` and `Translations.byHttp()` now accept an optional
  `failOnMissingResource` parameter. It defaults to `true`, which keeps the previous
  behavior: if a single file or resource fails to load, the whole load fails, and no
  translations are loaded at all.

  When you set it to `false`, the file or resource that failed is logged and skipped,
  and the ones that loaded correctly are kept. This is useful when a language file is
  temporarily unavailable or broken, and you'd rather show the other languages than
  none. If all of them fail, no error is thrown either, and your app simply shows the
  default-locale strings:

  ```dart
  static final _t = Translations.byHttp('en-US',
    url: 'https://example.com/translations',
    resources: ['en-US.json', 'es.json', 'pt-BR.po', 'fr.po'],
    failOnMissingResource: false, // Keep the resources that loaded correctly.
  );
  ```

  For `Translations.byFile()`, the files are listed from the asset manifest, so they
  can't really be missing. In that case, what's skipped are files that can't be read
  from the asset bundle, files that can't be decoded (for example, invalid JSON), and
  files containing values that are not Strings. A file is either fully loaded or fully
  skipped.

  By default, a skipped file or resource is printed to the console, together with the
  error. You may customize this by setting `I18n.failedResourceCallback`, which receives
  the specific asset path or url that failed, plus the error:

  ```dart
  I18n.failedResourceCallback = (resource, error) {
    myCrashReporting.log('Could not load $resource: $error');
  };
  ```

* `Translations.byFile()` now only loads the files inside the given `dir` (and its
  subdirectories). Previously, `dir: 'assets/translations'` would also load files
  from sibling directories that merely start with the same text, like
  `assets/translations_old/`. To that end, a trailing slash is now automatically added
  to `dir`, if it's missing.

* See examples
  [9_load_by_file_skip_errors_example](https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/9_load_by_file_skip_errors_example/main.dart)
  and
  [10_load_by_http_skip_errors_example](https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/10_load_by_http_skip_errors_example/main.dart).

* Fixed `I18n.preInitializationLocale` to `Locale('en', 'US')`. This is only used for the
  brief period when the app starts.

## 15.1.1

* Fixed multi-locale fallback to properly handle device language preferences.
  The system now correctly checks all device locales (not just the first)
  against all supported locales. When a device has multiple language
  preferences (e.g., French primary, German secondary), and the primary
  language is not supported but a secondary language is, the app will now
  correctly use the first supported language from the device's preference list.

## 15.0.8

* README.md and example improvements.

## 15.0.5

* Optionally, you can now set the `supportedLocales` of your app in the `I18n` widget.
  For example, if your app supports American English and Standard Spanish, you'd use:
  `supportedLocales: [Locale('en', 'US'), Locale('es')]`,
  or `supportedLocales: ['en-US'.asLocale, 'es'.asLocale]`.

  If you do set `I18n.supportedLocales`, you must add the line
  `supportedLocales: I18n.supportedLocales` to your `MaterialApp` (or `CupertinoApp`)
  widget, like this:

  ```dart
  void main() {
    WidgetsFlutterBinding.ensureInitialized();
  
    runApp(I18n(
        initialLocale: ...,
        supportedLocales: ['en-US'.asLocale, 'es'.asLocale], // Here!
        localizationsDelegates: [ ... ],
        child: AppCore(),
      ));
    }
  }
  
  class AppCore extends StatelessWidget {
    Widget build(BuildContext context) {
      return MaterialApp(
        locale: I18n.locale,
        supportedLocales: I18n.supportedLocales, // Here!
        localizationsDelegates: I18n.localizationsDelegates,
        ...
      ),
  ```

  By providing `I18n.supportedLocales`, only those supported locales will be considered
  when recording **missing translations**. In other words, unsupported locales will not be
  recorded as missing translations.


* **Breaking Change**: The `Translations.missingTranslationCallback` signature has
  changed. This will only affect you if you've defined your own callback, which is
  unlikely. If your code does break, just update it to the new signature, which is an easy
  fix. Also, note that it now returns a boolean. Only if it returns `true`, the missing
  translation be recorded to the `Translations.missingTranslations` map.

## 14.1.0

Version 14 brings important improvements, like new interpolation methods, useful
extensions, improved standardization, and loading translations from files and from the
web, with the cost of a few breaking changes that are easy to fix. Please, follow the
instructions below to upgrade your code.

* **Breaking Change**: Now, you must have a single (no more than one) `I18n` widget in
  your entire widget tree, and it must always be put ABOVE the `MaterialApp`
  (or `CupertinoApp`) widget, in the tree. There, it will be able to provide translations
  to all your routes and dialogs.


* **Breaking Change**: You must now add the line `locale: I18n.locale` to your
  `MaterialApp` (or `CupertinoApp`) widget, like this:

  ```
  MaterialApp(
     locale: I18n.locale,
     ...      
  ``` 


* **Breaking Change**: Because of the way Flutter works, you have to make sure your `I18n`
  widget is NOT declared in the same widget as the `MaterialApp`, but in a **parent**
  widget. For example, this is WRONG:

  ```dart
  Widget build(BuildContext context) {
    return I18n( // Wrong!
      child: MaterialApp(
        home: MyScreen(),
  ```        

  Instead, this is how your `main.dart` file could look like:

  ```dart    
  import 'package:i18n_extension/i18n_extension.dart';
  import 'package:flutter_localizations/flutter_localizations.dart';
         
  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
  }
  
  class MyApp extends StatelessWidget {
    Widget build(BuildContext context) {
      return I18n( // I18n in a parent widget!
        child: AppCore(),
      );
    }
  }
  
  class AppCore extends StatelessWidget {
    Widget build(BuildContext context) {
      return MaterialApp( // MaterialApp is here!
        locale: I18n.locale, // Locale declaration is here!
        localizationsDelegates: [ ... ],
        supportedLocales: [ ... ],
        home: ...
      ),
  ```  

  Another good alternative is declaring the `I18n` widget directly inside the `runApp`
  call, in your `main` function:

  ```dart    
  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(I18n(child: AppCore())); // I18n in a parent widget!
  }
  
  class AppCore extends StatelessWidget {
    Widget build(BuildContext context) {
      return MaterialApp( // MaterialApp is here!
        locale: I18n.locale, // Locale declaration is here!
        localizationsDelegates: ...
      ),
  ```  


* **Breaking Change**: The `MaterialApp` (or `CupertinoApp`) widget contains, internally,
  a `Localizations` widget, which is used by Flutter to provide translations to all native
  Flutter widgets.
  The `I18n` widget will now automatically keep in sync with this `Localizations` widget,
  so that when you change the locale in `I18n` (with `context.locale = 'en-US'.asLocale`,
  for example), it will also change automatically in the `Localizations` widget. This
  means that `Localizations.of(context).locale` will always return the same result as
  `I18n.of(context).locale`, as `context.locale`, and as `I18n.locale`.

  If you previously had your own logic to change the native `Localizations` locale by
  changing the `locale` parameter of the `MaterialApp` widget, you can now remove it,
  as this is not necessary anymore.


* **Breaking Change**: Language codes must now respect the BCP47 standard, when you
  define your translations.  
  For example, you should now use `en-US` instead of the old `en_us` format.
  Other valid code examples are: `en`, `es-419`, `hi-Deva-IN` and `zh-Hans-CN`.

  This is an example of a WRONG translation definition:

  ```dart     
  // Will throw: Locale "en_us" should be "en-US" 
  Translations.byText('en_us') + // Wrong!
     {
        'en_us': 'Hello, how are you?',  // Wrong!
        'pt_br': 'Olá, como vai você?',  // Wrong!
        'es': '¿Hola! Cómo estás?',
        'fr': 'Salut, comment ca va?',
        'de': 'Hallo, wie geht es dir?',
     };
  ```                                                                          

  To help you upgrade, a `TranslationsException` error will be thrown when you use the
  old code format. The error message will be something like:
  `Locale "en_us" should be "en-US"`

  This is an example of a VALID and correct translation definition:

  ```dart
  Translations.byText('en-US') +
     {
        'en-US': 'Hello, how are you?',
        'pt-BR': 'Olá, como vai você?',
        'es': '¿Hola! Cómo estás?',
        'fr': 'Salut, comment ca va?',
        'de': 'Hallo, wie geht es dir?',
     };
  ```

  Note: If your translations are defined manually in the code, you can quickly fix this
  by doing a few _Search and Replace_ commands in your IDE to fix the language codes, one
  for each of your supported languages, for example, replacing `'en_us'` with `'en-US'`
  etc.


* New extension `Locale.format` can be used to return the string representation of the
  Locale as a valid BCP47 language tag (compatible with the Unicode Locale Identifier
  (ULI) syntax). If the locale is not valid, `format` may return an invalid tag, or may
  return string "und" (undefined).  
  The language code, script code, and country code will be separated by a hyphen,
  and any lowercase/uppercase issues will be fixed. For example:

  ```dart
  var locale = Locale('en', 'us');
  print(locale.format()); // en-US, which is a valid BCP47 language tag
  print(locale.toString()); // en_US
  print(locale.toLanguageTag()); // en-us
  ```

  Using `format` is recommended over `toString` and `toLanguageTag` (both natively
  provided by the `Locale` class). In more detail:

    - `Locale.format()` returns the string representation of the Locale as a valid BCP47
      language tag, fixing any lowercase/uppercase issues and separating components with
      a hyphen. Allows specifying a different separator. For example,
      `Locale('en', 'us').format()` returns `en-US`, and
      `Locale('en', 'US').format(separator: '|')` returns `en|US`.

    - `Locale.toString()` returns the language, script and country codes separated by an
      underscore. For example, `Locale('en', 'us').toString()` returns `en_us`
      and `Locale('en', 'US').toString()` returns `en_US`.

    - `Locale.toLanguageTag()` returns the language code and the country code separated by
      a hyphen, but does not fix case. For example, `Locale('en', 'us').toLanguageTag()`
      returns `en-us`, and `Locale('en', 'US').toLanguageTag()` returns `en-US`.


* New extension `String.asLocale` can be used to convert a `String` containing a BCP47
  language tag to a `Locale` object. For example: `Locale locale = 'pt-BR'.asLocale;`.
  If the string is not a valid BCP47 language, `asLocale` will try to fix it.
  For example, the following lines are all **equivalent** and result in the same locale:

  ```dart
  var locale = Locale('en', 'US'); 
  var locale = 'en-US'.asLocale; 
  var locale = 'en_US'.asLocale; 
  var locale = 'en-us'.asLocale; 
  var locale = 'EN-US'.asLocale; 
  var locale = 'en US'.asLocale; 
  var locale = 'en|US'.asLocale; 
  var locale = 'en.uS'.asLocale; 
  var locale = 'eN,US'.asLocale; 
  var locale = 'en;US'.asLocale; 
  var locale = 'en, US'.asLocale; 
  ```

  However, it will only fix the most common errors, by fixing lowercase/uppercase issues,
  removing spaces, and converting all these separators: `-` `_` ` ` `|` `.` `,` `;` to
  hyphens. If it can’t fix it, it will return an invalid `Locale`, or maybe
  `Locale('und')`, meaning the locale is undefined.

  Note that `String.asLocale` can be used whenever you previously used Locale
  constructors. For example, instead of:

  ```dart
  supportedLocales: [
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ],
  ```

  You can now write:

  ```dart
  supportedLocales: [
    'en-US'.asLocale,
    'es-ES'.asLocale,    
  ],
  ```


* New extension `String.asLanguageTag` can be used to try and normalize String language
  tags to the BCP47 standard (which is compatible with the Unicode Locale Identifier (ULI)
  syntax). It fixes casing (uppercase and lowercase), removes spaces, and turns
  underscores into hyphens. As such, it can be used to convert the old format language
  tags to the new ones. For example: `'en_us'.asLanguageTag` returns `'en-US'`.


* **Interpolations.** You can now do string interpolations by replacing placeholders with
  values, with the `args` function:

  ```dart
  // Hello John and Mary
  'Hello {} and {}'.i18n.args('John', 'Mary');
  
  // Also works with iterables
  'Hello {} and {}'.i18n.args(['John', 'Mary']);
  
  // Named placeholders
  'Hello {name} and {other}'.i18n.args({'name': 'John', 'other': 'Mary'});
  
  // Numbered placeholders
  'Hello {1} and {2}'.i18n.args({1: 'John', 2: 'Mary'});
  
  // And you can mix placeholder types
  'Hello {name}, meet with {} and {other} to explore {1} and {2}.'.i18n.args('Charlie', {'name': 'Alice', 'other': 'Bob'}, {1: 'Paris', 2: 'London'});
  ```   

  For all the details, check the README.md file.


* **Breaking Change**: Previously, you could also do string interpolation by using
  **sprintf** specifiers, like `%s`, `%1$s`, `%d` etc., and providing a list of values to
  fill them. This is still supported:

  ```                   
  // Hello John and Mary
  'Hello %s and %s'.i18n.fill(['John', 'Mary']);
  
  // Hello John and Mary
  'Hello %1$s and %2$s'.i18n.fill(['John', 'Mary']);  
  
  // Hello Mary and John  
  'Hello %2$s and %1$s'.i18n.fill(['John', 'Mary']);  
  ```

  However, you can now also provide the values directly, without having to wrap them
  in a list:

  ```
  'Hello %s and %s'.i18n.fill('John', 'Mary');
  'Hello %1$s and %2$s'.i18n.fill('John', 'Mary');
  'Hello %2$s and %1$s'.i18n.fill('John', 'Mary');
  ```

  The breaking change part of it is that, previously, if you wanted to use the `fill`
  extension you needed to declare it yourself in your translations files. Now, that's not
  necessary anymore, as this extension is provided out of the box. For this reason, if you
  declared the `fill` extension yourself, you now need to remove it. Otherwise, the
  compiler will complain that the extension is declared twice. If you still want to keep
  your old declaration, change its name.


* **Auto saving the locale.** Some apps may allow the user to change the language/locale
  of the app, from inside the app. You'd usually create some widget that presents the list
  of available locales, and then set it with `context.locale = 'es-ES'.asLocale;` or
  similar.

  If you want that user choice to be saved between app restarts,
  simply set the `autoSaveLocale` parameter to `true`:

  ```dart
  I18n(
    autoSaveLocale: true,
    child: AppCore(),
    ...
  ```

  This will automatically save changes to the locale in the device's storage (shared
  preferences), and restore it when the app restarts.
  Note the locale is read asynchronously, which may result in a one frame flicker
  of the default system locale, before the saved locale is restored. If you want to avoid
  this flicker, you can explicitly preload the locale yourself by doing
  `initialLocale: await I18n.loadLocale()` when the app starts.

  ```dart    
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
   
    runApp(
      I18n(
        initialLocale: await I18n.loadLocale(),
        autoSaveLocale: true, 
        child: AppCore(),    
        ...
  ```

  > Note: While usually not needed, you can also manually load, save and delete the
  > locale from the shared preferences, at any later time,
  > by using the provided static functions:
  > `var locale = await I18n.loadLocale()`, `I18n.saveLocale(locale)`
  > and `I18n.deleteLocale()`.


* You can get the current locale by using the `context`:

  ```dart
  Locale locale = context.locale;
  Locale locale = I18n.of(context).locale;
  ```

  However, you can also get the locale **statically**,
  allowing you to use it in non-widget code:

  ```dart
  // Get a `Locale` object, like Locale('en', 'US') 
  Locale locale = I18n.locale;
  
  // Or get a BCP47 language tag string, like 'en-US'
  String languageTag = I18n.languageTag;
  String languageTag = I18n.locale.format();
  
  // Or get a locale string with a specific separator, like 'en|US'
  String languageTag = I18n.locale.format(separator: '|');
  
  // Or get only the lowercase language code part of the locale, like 'en'.
  String language = I18n.language;
  ```

  Note, using `I18n.localeStr` is deprecated. It returns a lowercase string with
  underscores, like `en_us`.


* To change the current locale, do this:

  ```dart
  context.locale = Locale('pt', 'BR');
  
  // Or
  context.locale = 'pt-BR'.asLocale;
  
  // Or
  I18n.of(context).locale = 'pt-BR'.asLocale;
  ```

  To reset the current locale back to the default **system locale**, do this:

  ```dart
  context.locale = null;
  
  // Or
  context.resetLocale();
  
  // Or
  I18n.of(context).locale = null;
  
  // Or
  I18n.of(context).resetLocale();
  ```

  Note, any of the above will change the current locale for your widgets using
  the `i18n_extension`, and also for native Flutter widgets.


* **Breaking Change**: The fallback rules changed a little bit.
  What happens when you don’t provide the translations for the current locale?
  For example, suppose your current locale is Spanish, but you have only provided
  translations for English and French.
  Fallback behavior is now more intuitive and aligned with common sense.
  In most cases, it will do exactly what you’d expect.
  However, if you want all the details, check the README.md file.

* **Load translations from files or the web**.

  If you want to load translations from `.json` files in your assets directory,
  create a folder and add some translation files like this:

  ```
  assets
  └── translations
      ├── en-US.json
      ├── es-ES.json
      ├── zh-Hans-CN.json
      └── pt.json  
  ```

  You can also use `.po` files:

  ```
  assets
  └── translations
      ├── en-US.po
      ├── es-ES.po
      ├── zh-Hans-CN.po
      └── pt.po  
  ```

  Don't forget to declare your assets directory in your `pubspec.yaml`:

  ```yaml
  flutter:
    assets:
      - assets/translations/
  ```

  Then, you can load the translations using `Translations.byFile()`:

  ```dart
  extension MyTranslations on String {
    static final _t = Translations.byFile('en-US', dir: 'assets/translations');     
    String get i18n => localize(this, _t);  
  }
  ```

  The above code will asynchronously load all the translations from the `.json` and `.po`
  files present in the `assets/translations` directory, and then rebuild your widgets with
  those new translations.

  Similarly, `Translations.byHttp()` allows you to load translations from `.json` or `.po`
  files in the web. Use it like this:

  ```
  extension MyTranslations on String {
  
    static final _t = Translations.byHttp('en-US', 
      url: 'https://example.com/translations', 
      resources: ['en-US.json', 'es.json', 'pt-BR.po', 'fr.po']);
    );
       
    String get i18n => localize(this, _t);  
  }       
  ```

  IMPORTANT: Since rebuilding widgets when the translations finish loading can cause a
  visible flicker, you can optionally avoid that by preloading the translations before
  running your app. To that end, first create a `load()` method in your `MyTranslations`
  extension:

  ```dart
  extension MyTranslations on String {
    static final _t = Translations.byFile('en-US', dir: 'assets/translations');  
    String get i18n => localize(this, _t);  
    
    static Future<void> load() => _t.load(); // Here!  
  }
  ```

  And then, in your `main()` method, call `MyTranslations.load()` before running the app:

  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await MyTranslations.load(); // Here!
    
    runApp(
      I18n(
        initialLocale: await I18n.loadLocale(),
        autoSaveLocale: true,
        child: AppCore(),
      ),
    );
  }
  ```

  Another alternative is using a `FutureBuilder`:

  ```dart
  return FutureBuilder(
    future: MyTranslations.load(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
      return MyWidget(...);
    } else {
      return const Center(child: CircularProgressIndicator());
    } ...
  ```       

  Try running
  the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/6_load_by_file_example/main.dart">
  load by file example</a>, and  
  the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/7_load_by_http_example/main.dart">
  load by http example</a>, and the

## 12.0.1

* Compatible with Flutter 3.22.0 and Dart 3.4.0

## 11.0.13

* BREAKING CHANGE: Replace the previous `Translations()` constructor with
  `Translations.byText()`.
  Like before, it supports `String` as translation keys, organized per key.


* The previous `Translations.byLocale()` works just as before. Like before, it supports
  `String` as
  translation keys, organized per locale.


* Translation subtype `TranslationsByLocale` still exist, but it's not visible anymore.
  If you were writing `TranslationsByLocale t = new TranslationsByLocale(...` you should
  now write
  `var t = Translations.byLocale(...`, or `Translations t = Translations.byLocale(...`


* Now you can use ANY object type as translation keys. Before, it was only possible to use
  strings as translation keys. You can now use `Translations.byId()` and provide the
  type `T` of your identifier. Your `T` can be anything, including `String`, `int`,
  `double`, `DateTime`, or even your own custom object types, as long as they implement
  `==` and `hashCode`. If you use `Object` or `Object?`/`dynamic` then anything can be
  translated. Don’t forget that your extensions, like `.i18n`, will need to be on your
  type. For example, if you use `int` as your key type, then you will need to declare
  `extension Localization on int { ... }`.


* If you want to provide translations as a const map, and `String` as translation keys,
  use the `const ConstTranslations()` constructor.

  > To sum up:
  > * `Translations.byText()` supports `String` as translation keys, organized per key.
  > * `Translations.byLocale()` supports `String` as translation keys, organized per
      locale.
  > * `Translations.byId<T>()` supports any object of type `T` as translation keys.
  > * `const ConstTranslations()` supports defining translations with a `const` Map,
      and `String` as translation keys.

* Now the core features of the i18n_extension package are available as a standalone
  Dart-only package: https://pub.dev/packages/i18n_extension_core. You may use that core
  package when you are developing a Dart server (backend), or when developing your
  own Dart-only package that does not depend on Flutter.

  > **For Flutter applications nothing changes.**
  > You don’t need to import the core package directly.
  > You should continue to use this i18n_extension package, which already exports
  > the core code plus the `I18n` widget that you use to wrap your widget tree.

## 10.0.3

* The importer library developed by Johann Bauer is now independently available as a
  standalone package. You can find it at https://pub.dev/packages/i18n_extension_importer.
  This new package offers capabilities for importing translations in both `.PO` and
  `.JSON` formats. It also includes the `GetStrings` exporting utility, which is a useful
  script designed to automate the export of all translatable strings from your project.

* Removed unused packages that were previously used by the removed importer.

## 9.0.2

* Flutter 3.10 e Dart 3.0.0

* Removed the importer library developed by Johann Bauer, so that users of i18n_extension
  don’t need to import the analyzer and other unnecessary dependencies. See
  version [10.0.2] above.

## 8.0.0

* Breaking change: Removed dependency on analyzer and gettext_parser. The getStrings
  doesn’t work in this version.

## 6.0.0

* Analyzer and sprintf version bump.

## 5.0.1

* Analyzer version bump.

## 5.0.0

* Flutter 3.0

## 4.2.1

* The `localizePlural` method now accepts any object (not only an integer anymore). It
  will convert that object into an integer, and use that result. Se the method
  documentation for more information. To make use of it, you may declare your `plural()`
  methods as `String plural(value) => localizePlural(value, this, _t);` from now on.
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

* Now allows both string-keys (like `'Hello there'.i18n` as shown in the `example1` dir)
  and identifier-keys (like `greetings.i18n` as shown in the `example2` dir).

* Breaking change: If some translation did not exist in some language, it would show the
  translation key itself as the missing translation. This worked well with string-keys,
  but not with identifier-keys. Now, if some translation is missing, it first tries to
  show the untranslated string, and only if that is missing too it shows the key as the
  translation. This change is unlikely to be noticed by anyone, but still a breaking
  change.

## 3.0.3

* Nullsafety.

* Breaking change: During app initialization, the system locale may be `null` for a few
  moments. During this time, in prior version _2.0.0_ it would use the `Translations`
  default locale. Now, in version _3.0.0_, it will use the global locale defined in
  `I18n.defaultLocale`, which by default is `Locale('en', 'US')`. You can change this
  default in your app's main method.

* New `Translations.from()` constructor, which responds better to hot reload.

* Fixed the PO importer to ignore empty keys.

* The docs now explain better how to add plurals with translations by locale.

## 2.0.0

* Plural modifiers: `zeroOne` (for 0 or 1 elements), and `oneOrMore` (for 1 and more
  elements).

* Fix for when no applicable plural modifier is found. It now correctly defaults to the
  unversioned string.

## 1.5.1

* `.PO` and `.JSON` importers contributed by <a href="https://github.com/bauerj">Johann
  Bauer</a>.

## 1.4.6

* Sprintf version bump to 5.0.0.

## 1.4.5

* Added `key` and `id` to `I18n` widget constructor.

## 1.4.3

* Better error message for `I18n.of`.

## 1.4.2

* Bumped `sprintf` to version `4.1.0`, which adds compatibility for future Dart features
  that require a Dart SDK constraint with a lower bound that is `>=2.0.0`.

## 1.4.1

* Allow multi-line statements in getstrings utility.

## 1.4.0

* More plural modifiers: `three`, `four`, `five`, `six`, and `ten`.
* For Czech language: `twoThreeFour` plural modifier.

## 1.3.9

* GetStrings exporting utility.

## 1.3.5

* Added fill () method to default.i18n.dart.

## 1.3.4

* Don’t record unnecessary missing translations with the Translation.byLocale constructor.

## 1.3.3

* Commented unnecessary tests.

## 1.3.2

* Added localizationsDelegates and supportedLocales to the docs.

## 1.3.0

* I18n.observeLocale () can be used to observe locale changes.

* Breaking change: Accepts Locale ('en", 'US'), but not Locale ('en_US') anymore, which
  was
  wrong. See "A quick recap of Dart locales" in the docs, for more details.

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
