Sponsored by [MyText.ai](https://mytext.ai)

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

## 15.0.4

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
  tags to the BCP47 standard (which is compatible with the Unicode Locale Identifier
  (ULI) syntax). It fixes casing (uppercase and lowercase), removes spaces, and turns
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
  'Hello {name}, let’s meet up with {} and {other} to explore {1} and {2}.'.i18n.args('Charlie', {'name': 'Alice', 'other': 'Bob'}, {1: 'Paris', 2: 'London'});
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

  This will automatically save changes to the locale in the device's storage
  (shared preferences), and restore it when the app restarts.
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

* Added fill() method to default.i18n.dart.

## 1.3.4

* Don’t record unnecessary missing translations with the Translation.byLocale constructor.

## 1.3.3

* Commented unnecessary tests.

## 1.3.2

* Added localizationsDelegates and supportedLocales to the docs.

## 1.3.0

* I18n.observeLocale() can be used to observe locale changes.

* Breaking change: Accepts Locale('en", 'US'), but not Locale('en_US') anymore, which was
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
