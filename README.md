[![Pub Version](https://img.shields.io/pub/v/i18n_extension?style=flat-square&logo=dart)](https://pub.dev/packages/i18n_extension)
[![Code Check](https://github.com/marcglasberg/i18n_extension/actions/workflows/code_check.yaml/badge.svg)](https://github.com/marcglasberg/i18n_extension/actions/workflows/code_check.yaml)
[![GitHub stars](https://img.shields.io/github/stars/marcglasberg/i18n_extension?style=social)](https://github.com/marcglasberg/i18n_extension)
![Code Climate issues](https://img.shields.io/github/issues/marcglasberg/i18n_extension?style=flat-square)
![GitHub closed issues](https://img.shields.io/github/issues-closed/marcglasberg/i18n_extension?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/marcglasberg/i18n_extension?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/marcglasberg/i18n_extension?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/marcglasberg/i18n_extension?style=flat-square)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)
[![Developed by Marcelo Glasberg](https://img.shields.io/badge/Developed%20by%20Marcelo%20Glasberg-blue.svg)](https://glasberg.dev/)
[![Glasberg.dev on pub.dev](https://img.shields.io/pub/publisher/async_redux.svg)](https://pub.dev/publishers/glasberg.dev/packages)
[![Platforms](https://badgen.net/pub/flutter-platform/i18n_extension)](https://pub.dev/packages/i18n_extension)

#### Contributors

<a href="https://github.com/marcglasberg/i18n_extension/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=marcglasberg/i18n_extension" alt="contributors"/>
</a>

#### Sponsor

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

# Translate your app!

> **_"Thank you for making the i18n_extension plugin._**
> **_It has helped me a lot in my latest project and I will surely use it again_**
> **_in my next Flutter project. It is so easy to set up and use and the code_**
> **_boilerplate is indeed very minimal."_**
>
> **_— Tomáš Jeřábek, Consultant/Developer_**

> This is a Flutter package. For a Dart-only package,
> see [i18n_extension_core](https://pub.dev/packages/i18n_extension_core)

> This package was mentioned by Google during
> the [Dart 2.7 announcement](https://medium.com/dartlang/dart-2-7-a3710ec54e97)
>
> Read the
> [Medium article](https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9)

&nbsp;<br>

## Option 1: Strings are translation keys

Start with a simple widget displaying some text:

```dart
Text('How are you?');
```

To make it translatable, just add `.i18n` to the string:

```dart
Text('How are you?'.i18n);
``` 

The text will be translated based on the current locale.
For example, if your app supports `en-US`, `pt-BR`, and `es` (American English, Brazilian
Portuguese, and Spanish):

- When the locale is `en-US`, it shows `'How are you?'`
- When the locale is `pt-BR`, it shows `'Como vai?'`
- When the locale is `es`, it shows `'¿Cómo estás?'`
- And so on for any other locales you want to support

The original English string `'How are you?'` doubles as the **"translation key"** to
find the appropriate translation. One advantage of this approach is that you don’t need
to come up with _unique identifiers_ for each string.

Another advantage is that you can see actual text in your code,
which is generally simpler and easier to understand than seeing identifiers.

## Option 2: Identifiers are translation keys

While the `i18n_extension` package is unique in supporting strings as translation
keys, it also supports the more traditional approach of using **identifiers** as
translation keys. Just create an object, and append `.i18n` to it. For example:

```dart
const greetings = Object();

// Shows 'How are you?' in en-US
// Shows 'Como vai?' in pt-BR 
// Shows '¿Cómo estás?' in es 
Text(greetings.i18n);  
```

Or, if you want to namespace your identifiers:

```dart
class Salutes {  
  static const hi = Object();  
  static const welcome = Object();
  static const goodbye = Object();
} 

Text(Salutes.welcome.i18n);
```

You can always mix and match strings and identifiers as translation keys.
For example, you might use string keys for short texts,
while using identifiers for long texts, as shown here:

```dart
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {          
          // Using identifier as key here!
          return AlertDialog(content: Text(termsOfUse.i18n));           
        });
    },
    // Using string as key here!
    child: Text('Terms of Use'.i18n), 
  );
}
```

## Other features

_Other `i18n_extension` features that will be later discussed in more detail include:_

Providing different translations depending on modifiers, such as `plural` quantities:

```dart
'There is 1 item'.plural(0); // There are no items
'There is 1 item'.plural(1); // There is 1 item
'There is 1 item'.plural(2); // There are 2 items
```

Inventing your own modifiers according to any conditions. For example, for
languages with genders, you can create `gender` versions for `Gender` modifiers:

```dart
'There is a person'.gender(Gender.male); // There is a man
'There is a person'.gender(Gender.female); // There is a woman
'There is a person'.gender(Gender.they); // There is a person
```

Interpolating by replacing placeholders with values, with the `args` function:

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

Interpolating by
using [sprintf](https://www.tutorialspoint.com/c_standard_library/c_function_sprintf.htm),
with the `fill` function:

```dart
// Hello John and Mary
'Hello %s and %s'.fill('John', 'Mary');
```

Getting the current locale:

```dart
context.locale; // Current locale, from context

I18n.of(context).locale; // Current locale, from context 

I18n.locale; // Current locale, statically 

I18n.languageTag; // Current language tag, like "en-US"

I18n.languageOnly; // Language without region, Like "en"

I18n.systemLocale; // Current system locale, read from the device 

Localizations.maybeLocaleOf(context); // The Flutter native way also works  
```

Setting the current locale:

```dart
context.locale = Locale('en', 'US'); // Set the current locale

context.locale = 'es-ES'.asLocale; // Use language tag to set the current locale  

context.resetLocale(); // Reset back to the system locale 
```

Auto saving the current locale:

```dart
I18n(
  autoSaveLocale: true,
  child: ...
```

Defining translations directly in code:

```dart
Translations.byText('en-US') + {
  'en-US': 'Hello, how are you?',      
  'es': '¿Hola! Cómo estás?',
};
```

Importing translations from a file:

```dart
Translations.byFile('en-US', dir: 'assets/translations');
```

Importing translations from the web:

```dart
Translations.byUrl('en-US', dir: 'https://example.com/translations.json');
```

## See it working

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/1_translation_example/main.dart">
translation example</a>.

![](./example/lib/1_translation_example/i18nScreen.jpg)

# Setup

Follow these 4 easy steps to set up the `i18n_extension` package in your app:

1. Wrap your widget tree with a single `I18n` widget, above your `MaterialApp`
   (or `CupertinoApp`) widget. Remember you should **not** have more than one single
   `I18n` widget in your widget tree.

   Since the `I18n` widget is **above** the `MaterialApp`, it will be able
   to provide translations to all your routes and dialogs.


2. Make sure the `I18n` widget is NOT declared in the same widget as the
   `MaterialApp`. It must be in a **parent** widget. For example, this is wrong:

    ```dart
    Widget build(BuildContext context) {
      return I18n(
        child: MaterialApp(
          home: MyScreen(),           
    ```


3. Make sure to provide `supportedLocales` and `localizationsDelegates` to
   the `I18n` widget:

   ```
   return I18n(       
      supportedLocales: [
        'en-US'.asLocale,
        'es-ES'.asLocale,
        'pt-BR'.asLocale,
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: AppCore(),
   );
   ```


4. Add `locale: I18n.locale`,
   and `localizationsDelegates: I18n.localizationsDelegates`,
   and `supportedLocales: I18n.supportedLocales`,
   to your `MaterialApp` widget:

   ```
   MaterialApp(
      locale: I18n.locale,
      localizationsDelegates: I18n.localizationsDelegates,
      supportedLocales: I18n.supportedLocales,
      ...      
   ```

This is how your `main.dart` file could look like:

```dart    
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
       
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return I18n(
      supportedLocales: [
        'en-US'.asLocale,
        'es-ES'.asLocale,
        'pt-BR'.asLocale,
      ],       
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: AppCore(),
    );
  }
}

class AppCore extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: I18n.locale,
      locale: I18n.locale,
      localizationsDelegates: I18n.localizationsDelegates,
      supportedLocales: I18n.supportedLocales,
      home: ...
    ),
```  

Another alternative is declaring the `I18n` widget in the `runApp()` of `main` function:

```dart    
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
       
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(I18n(
    supportedLocales: [
      'en-US'.asLocale,
      'es-ES'.asLocale,
      'pt-BR'.asLocale,
    ],       
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    child: AppCore(),
  ));
}

class AppCore extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: I18n.locale,
      locale: I18n.locale,
      localizationsDelegates: I18n.localizationsDelegates,
      supportedLocales: I18n.supportedLocales,
      home: ...
    ),
```  

&nbsp;<br>

**Note:** To be able to import `flutter_localizations.dart` you must add it as
a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter

  i18n_extension: ...
```

&nbsp;<br>

As you probably know, the `MaterialApp` widget contains a `Localizations` 
widget inside it, 
which is used by Flutter to provide translations to native Flutter widgets.
The `I18n` widget will automatically keep in sync with the `Localizations` 
widget, so that when you change the locale in `I18n`, it will also change in 
the `Localizations`.
This means that `Localizations.of(context).locale` is always equal
to `I18n.of(context).locale`, to `context.locale`, and to `I18n.locale`.

## Initial locale

The `I18n` widget will translate your strings to the current **system locale**,
which is the locale the user has set in the device settings, outside your app.

However, you can override it with your own initial locale, like this:

```dart
I18n(
  initialLocale: 'pt-BR'.asLocale,
  child: ...
```

Note you can always later change the locale dynamically, as will be explained below.

In most applications, you should **not** set the initial locale, and instead let the
system locale be used. This way, your app will automatically be in the
language the user has set in the device settings. Or, if that language is not
supported by your app, it will fall back to one of the supported languages,
automatically.

## Auto saving the locale

Some apps may allow the user to change the locale of the app from inside the
app itself. You can allow that by creating some widget that presents a list of available
locales, and then set it with:

```dart
context.locale = 'es-ES'.asLocale;
```

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
this flicker, you can explicitly preload the locale yourself with
`initialLocale: await I18n.loadLocale()` when the app starts:

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

> Note, this is usually not required, but you can manually load, save, or delete the 
> locale from the shared preferences at any time by using these static functions:
> `var locale = await I18n.loadLocale()`, `I18n.saveLocale(locale)`
> and `I18n.deleteLocale()`.

# Translating a widget

When you want to create a widget that contains translatable texts, 
start by temporarily adding this _default import_ to the widget's file:

```dart
import 'package:i18n_extension/default.i18n.dart';
```

This will allow you to add `.i18n` and `.plural()` to your strings, but won’t translate
anything.

When you are ready to create your translations, you must create a dart file to hold them.
This file can have any name, but I suggest you give it the same name as your widget and
change the termination to `.i18n.dart`.

For example, if your widget is in file `my_widget.dart`, the translations could be in
file `my_widget.i18n.dart`

You must then remove the previous default import, and instead import your own translation
file:

```dart
import 'my_widget.i18n.dart';
```

Your translation file itself may be something like this:

```dart
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations.byText('en-US') +
    {
      'en-US': 'Hello, how are you?',
      'pt-BR': 'Olá, como vai você?',
      'es': '¿Hola! Cómo estás?',
      'fr': 'Salut, comment ca va?',
      'de': 'Hallo, wie geht es dir?',
    };

  String get i18n => localize(this, _t);
}
```

The locale you pass in the `Translations` factory is called the **default locale**.
For example, in `Translations.byText('en-US')` the default locale is `en-US`.
The string inside your `Text` widget should be in the language of that locale.

The above example shows a single translatable string, translated to American English,
Brazilian Portuguese, general Spanish, French and German.

You can, however, translate as many strings as you want, by simply adding more
**translation maps**:

```dart
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

    static var _t = Translations.byText('en-US') +
        {
          'en-US': 'Hello, how are you?',
          'pt-BR': 'Olá, como vai você?',
        } +
        {
          'en-US': 'Hi',
          'pt-BR': 'Olá',
        } +
        {
          'en-US': 'Goodbye',
          'pt-BR': 'Adeus',
        };

  String get i18n => localize(this, _t);
}
```

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/translation_example/main.dart">
example using strings as translation keys</a>.

## Or use identifiers

Instead of:

```dart
'Hello there'.i18n
```

You can also do:

```dart
greetings.i18n
```

To that end, you can use the `Translations.byId()` factory:

```dart
import 'package:flutter/foundation.dart';

final appbarTitle = Object();
final greetings = Object();

extension Localization on Object {
    
  static final _t = Translations.byId('en-US', {
    appbarTitle: {
      'en-US': 'i18n Demo',
      'pt-BR': 'Demonstração i18n',
    },
    greetings: {
      'en-US': 'Helo there',
      'pt-BR': 'Olá como vai',
    },    
  });

  String get i18n => localize(this, _t);    
}
```

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/example2/main.dart">
example using identifiers as translation keys</a>.

<br>

Note: The native way of doing translation in Flutter forces you to define "identifier
keys" for each translation, and use those. For example, an identifier key could be
`helloHowAreYou` or simply `greetings`. And then you can access the translation like
this: `MyLocalizations.of(context).greetings`.

With `i18n_extension`, you can use ANY object type as translation keys.
Just use `Translations.byId<T>()` and provide the type `T` of your identifier. Your `T`
can be anything, including `String`, `int`, `double`, `DateTime`, or even your own custom
object types, as long as they implement `==` and `hashCode`.

Don’t forget that your extensions need to be _on your type_.
For example, if you use `int` as your key type, you need to
declare `extension Localization on int { ... }`.

If your `T` is `Object` or `Object?` or `dynamic`, then anything can be translated, and
you need to write: `extension Localization on Object? { ... }`

```dart
// Objects  
const greetings = Object();
greetings.i18n // Turns into 'How are you?' in en, 'Como vai?' in pt  

// Final variables  
final faq = 'faq';
faq.i18n // 'FAQ' in en, 'Perguntas frequentes' in pt

// Enums  
enum MyColors { red, blue }
MyColors.red.i18n // 'Red' in en, 'Vermelho' in pt
MyColors.blue.i18n // 'Blue' in en, 'Azul' in pt

// Numbers, booleans, Dates  
12.i18n // 'Twelve' in en, 'Doze' in pt
true.i18n // 'Yes' in en, 'Sim' in pt
false.i18n // 'No' in en, 'Não'
DateTime(2021, 1, 1).i18n // 'New Year' in en, 'Ano Novo' in pt

// Your own object types  
class User { ... }
User('John').i18n // 'Mr. John' in en, 'Sr. John' in pt
```

Even though you can use any object type as a translation key, it is recommended to use
`Object()` values, as they are simple and work fine.

## Recommended way

We believe having to define identifiers is a boring task, and makes it difficult for you
to remember the exact text of the translations without having to look at the translation
file.

For this reason we recommend you to simply type the text you want as a `String` inside
your `Text()` widgets, and add `.i18n` to them.

The exception is when you have very large texts that you need to translate, like for
example privacy policies, terms of use, long explanations etc. In those cases, you may
want to use identifiers, while keeping the rest as string keys.

In the example below, `privacyPolicy` and `termsOfUse` are used as identifiers,
while `My Settings`, `Ok` and `Back` are used as string keys:

```
import 'package:flutter/foundation.dart';

final privacyPolicy = Object();
final termsOfUse = Object();

extension Localization on Object {
    
  static final _t = Translations.byId('en-US', {
    privacyPolicy: { 'en-US': 'Very Looong text', 'pt-BR': 'Very Looong text' },
    termsOfUse: { 'en-US': 'Very Looong text', 'pt-BR': 'Very Looong text' },
    'My Settings': { 'en-US': 'My Settings', 'pt-BR': 'Meus ajustes' },    
    'Ok': { 'en-US': 'Ok', 'pt-BR': 'Salvar ajustes' },
    'Back': { 'en-US': 'Back', 'pt-BR': 'Voltar' },
  });

  String get i18n => localize(this, _t);    
}
```

You use them like this, respectively:

```dart
Text(privacyPolicy.i18n);
Text(termsOfUse.i18n);
Text('My Settings'.i18n);
Text('Ok'.i18n);
Text('Back'.i18n);
```

## Load translations from files

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

Note, you can also have files in subdirectories, like:

```
assets
└── translations
    ├── en-US.json    
    ├── zh-Hans-CN.json
    ├── pt.json  
    └── more_translations
        └── es-ES.json  
```

In this case, your `pubspec.yaml` you must **separately** declare all 
directories and subdirectories that contain assets. 
In other words, Flutter automatically finds all files in the directory, 
but it does NOT enter subdirectories,
unless you declare them explicitly in `pubspec.yaml`. For example:

```yaml
 flutter:
   assets:
     - assets/translations/
     - assets/translations/more_translations/
 ```

Once you have your files in place, 
you can load the translations using `Translations.byFile()`:

```dart
extension MyTranslations on String {
  static final _t = Translations.byFile('en-US', dir: 'assets/translations');     
  String get i18n => localize(this, _t);  
}
```

The above code will asynchronously load all the translations from the `.json` and `.po`
files present in the `assets/translations` directory, and then rebuild your widgets with
those new translations.

Note: Since rebuilding widgets when the translations finish loading can cause a visible
flicker, you can optionally avoid that by preloading the translations before running your
app. To that end, first create a `load()` method in your `MyTranslations` extension:

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

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/6_load_by_file_example/main.dart">
load by file example</a>.

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

Note: The load process has a default timeout of 0.5 seconds. If the timeout is
reached, the future returned by `load` will complete, but the load process still
continues in the background, and the widgets will rebuild automatically when the
translations finally finish loading. Optionally, you can provide a different `timeout`
duration.

**Note:** The code to load translations from files is adapted from original code
created by <a href="https://github.com/bauerj">Johann Bauer</a>.

## Load translations from the web

You can use `Translations.byHttp()` to load translations from `.json` or `.po` files on
the web, using **https**. Use it like this:

```
extension MyTranslations on String {
  
  static final _t = Translations.byHttp('en-US', 
    url: 'https://example.com/translations', 
    resources: ['en-US.json', 'es.json', 'pt-BR.po', 'fr.po']);
  );
       
  String get i18n => localize(this, _t);  
}       
```

The above code will asynchronously load all the resources listed above:

```
https://example.com/translations/en-US.json
https://example.com/translations/es.json
https://example.com/translations/pt-BR.po
https://example.com/translations/fr.po
```

It will then rebuild your widgets with those new translations.

Note: Since rebuilding widgets when the translations finish loading can cause a visible
flicker, you can optionally avoid that by preloading the translations before running your
app. To that end, first create a `load()` method in your `MyTranslations` extension:

```dart
extension MyTranslations on String {
  static final _t = Translations.byHttp('en-US', url: ..., resources: ...);  
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

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/7_load_by_http_example/main.dart">
load by http example</a>.

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

Note: The load by http process has a default timeout of 1 second. If the timeout is
reached, the future returned by `load` will complete, but the load process still
continues in the background, and the widgets will rebuild automatically when the
translations finally finish loading. Optionally, you can provide a different `timeout`
duration.

## Finding missing translations

If some string is already translated, and you later change it in the widget file, this
will break the link between the key and the translation map. However, `i18n_extension` is
smart enough to let you know when that happens, so it's easy to fix. You can even add this
check to tests, as to make sure all translations are linked and complete.

When you run your app or tests, each key not found will be recorded to the static
set `Translations.missingKeys`. And if the key is found but there is no translation to
the current locale, it will be recorded to `Translations.missingTranslations`.

You can manually inspect those sets to see if they're empty, or create tests to do that
automatically, for example:

```dart
expect(Translations.missingKeys, isEmpty);
expect(Translations.missingTranslations, isEmpty);
```

Note: You can disable the recording of missing keys and translations by doing:

```dart
Translations.recordMissingKeys = false;
Translations.recordMissingTranslations = false;
```

Another thing you may do, if you want, is to set up callbacks that the `i18n_extension`
package will call whenever it detects a missing translation. You can then program these
callbacks to throw errors if any translations are missing, or log the problem, or send
emails to the person responsible for the translations.

To do that, simply inject your callbacks into `Translations.missingKeyCallback` and
`Translations.missingTranslationCallback`.

For example:

```dart
Translations.missingTranslationCallback =
  ({
    required Object? key,
    required StringLocale locale,
    required Translations translations,
    required Iterable<String> supportedLocales,
  }) {
    if (locale != translations.defaultLocaleStr &&
        (supportedLocales.isEmpty || supportedLocales.contains(locale))) {
      print('➜ There are no translations in "$locale" for "$key".');
      return true;
    } else {
      return false;
    }
  }
```

## Defining translations by locale instead of by key

As explained, by using the `Translations.byText()` constructor you define each key and
then provide all its translations at the same time.
This is the easiest way when you are doing translations manually, for example,
when you speak English and Spanish and are creating yourself the translations to your app.

However, in other situations, such as when you are hiring professional translation
services or crowdsourcing translations, it may be easier if you can provide the
translations by locale/language, instead of by key. You can do that by using
the `Translations.byLocale()` constructor.

```dart
static var _t = Translations.byLocale('en-US') +
    {
      'en-US': {
        'Hi.': 'Hi.',
        'Goodbye.': 'Goodbye.',
      },
      'es-ES': {
        'Hi.': 'Hola.',
        'Goodbye.': 'Adiós.',
      }
    };
```

You can also add maps using the `+` operator:

```dart
static var _t = Translations.byLocale('en-US') +
    {
      'en-US': {
        'Hi.': 'Hi.',
        'Goodbye.': 'Goodbye.',
      },
    } +
    {
      'es-ES': {
        'Hi.': 'Hola.',
        'Goodbye.': 'Adiós.',
      }
    };
```

Note above, since `en-US` is the default locale, you could omit the translations for it.

## Combining translations

To combine translations you can use the `*` operator. For example:

```dart
var t1 = Translations.byText('en-US') +
    {
      'en-US': 'Hi.',
      'pt-BR': 'Olá.',
    };

var t2 = Translations.byText('en-US') +
    {
      'en-US': 'Goodbye.',
      'pt-BR': 'Adeus.',
    };

var translations = t1 * t2;

print(localize('Hi.', translations, locale: 'pt-BR');
print(localize('Goodbye.', translations, locale: 'pt-BR');
```

## Interpolation with named placeholders

Suppose your translations file contains:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'Hello {student} and {teacher}',
    'pt-BR': 'Olá {student} e {teacher}',
  };

String get i18n => localize(this, _t);
```

You can then use the `args` extension like this:

```dart
'Hello {student} and {teacher}'.i18n.args({'student': 'John', 'teacher': 'Mary'});

// These also work, but they are not recommended:
'Hello {student} and {teacher}'.i18n.args('John', 'Mary');
'Hello {student} and {teacher}'.i18n.args(['John', 'Mary']);
```

The above code will print `Hello John and Mary` if the locale is English,
or `Olá John e Mary` if it's Portuguese.

## Interpolation with numbered placeholders

Suppose your translations file contains:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'Hello {1} and {2}',
    'pt-BR': 'Olá {1}, aqui é {2}',
  };

String get i18n => localize(this, _t);
```

You can then use the `args` extension like this:

```dart
'Hello {1} and {2}'.i18n.args({1: 'John', 2: 'Mary'});

// These also work, but they are not recommended:
'Hello {1} and {2}'.i18n.args('John', 'Mary');
'Hello {1} and {2}'.i18n.args(['John', 'Mary']);
```

The above code will print `Hello John and Mary` if the locale is English,
or `Olá John e Mary` if it's Portuguese.

This interpolation method allows for the
translated string to change the order of the parameters. For example:

```dart
// Returns `Hello John and Mary`
'Hello {1} and {2}'.i18n.args({'1': 'John', '2': 'Mary'});

// Returns `Hello Mary and John`
'Hello {2} and {1}'.i18n.args({'1': 'John', '2': 'Mary'});
```

## Interpolation with unnamed placeholders

Suppose your translations file contains:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'Hello {} and {}',
    'pt-BR': 'Olá {}, aqui é {}',
  };

String get i18n => localize(this, _t);
```

You can then use the `args` extension like this:

```dart
'Hello {} and {}'.i18n.args('John', 'Mary');

// Or like this
'Hello {} and {}'.i18n.args(['John', 'Mary']);
```

The above code will replace the `{}` in order,
and print `Hello John and Mary` if the locale is English,
or `Olá John e Mary` if it's Portuguese.

The problem of using this interpolation method is that it doesn’t allow for the
translated string to change the order of the parameters.

## Interpolation with sprintf

Suppose your translations file contains:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'Hello %s and %s',
    'pt-BR': 'Olá %s, aqui é %s',
  };

String get i18n => localize(this, _t);
```

You can then use the `fill` extension like this:

```dart
'Hello %s and %s'.i18n.fill('John', 'Mary');

// Or like this:
'Hello %s and %s'.i18n.fill(['John', 'Mary']);
```

The above code will print `Hello John and Mary` if the locale is English,
or `Olá John e Mary` if it's Portuguese.

It uses the [sprintf](https://pub.dev/packages/sprintf) package internally.
Here is
the [sprintf specification](https://www.tutorialspoint.com/c_standard_library/c_function_sprintf.htm).

## Translation modifiers

Sometimes your translations depend on a **number quantity**.

For example, if someone is buying books, you may want to highlight the singular versus
plural difference book/books: `'You are buying 1 book'` (singular) versus
`'You are buying 2 books'` (plural).

To allow for plurals, instead of `.i18n` you can use `.plural()` and pass it a number. For
example:

```dart
int numOfBooks = 2;
return Text('You are buying 1 book'.plural(numOfBooks));
```

Then, your translations file should contain something like this:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'You are buying 1 book'                       
      .two('You are buying 2 books'),        
    'pt-BR': 'Você está comprando 1 livro'               
      .two('Você está comprando 2 livros'),
  };
  
String plural(value) => localizePlural(value, this, _t);
```

The above example only has translations for 1 and 2 books.
If you can have any number of books, the translated string can contain the appropriate
placeholder, and it will be replaced by the exact number:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'You are buying 1 book'                       
      .many('You are buying {} books'),        
    'pt-BR': 'Você está comprando 1 livro'               
      .many('Você está comprando {} livros'),
  };
  
String plural(value) => localizePlural(value, this, _t);
```

The placeholder can be:

* An unnamed placeholder, like: `{}`

  ```dart
  return Text('You are buying {} books'.plural(42));
  ```

* A named placeholder, like: `{numOfBooks}` etc

  ```dart
  return Text('You are buying {numOfBooks} books'.plural({'numOfBooks': 42}));
  ```

* Or `%d` if you like the sprintf syntax

  ```dart
  return Text('You are buying %d books'.plural(42));
  ```

The plural modifiers you can use are `zero`, `one`, `two`, `three`, `four`, `five`, `six`,
`ten`, `times` (for any number of elements, except 0, 1 and 2), `many` (for any number of
elements, except 1, including 0), `zeroOne` (for 0 or 1 elements), and `oneOrMore`
(for 1 and more elements).

Also, according to a <a href="https://github.com/marcglasberg/i18n_extension/issues/42">
Czech speaker</a>, there must be a special modifier for 2, 3 and 4. To that end you can
use the `twoThreeFour` modifier.

Note: It will use the most specific plural modifier. For example, `.two` is more specific
than `.many`. If no applicable modifier can be found, it will default to the unversioned
string. For example, this: `'a'.zero('b').four('c')` will default to `"a"` for 1, 2, 3, or
more than 5 elements.

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'You clicked the button {} times'
        .zero('You haven’t clicked the button')
        .one('You clicked it once')
        .two('You clicked a couple times')
        .many('You clicked {} times')
        .times(12, 'You clicked a dozen times'),
    'pt-BR': 'Você clicou o botão {} vezes'
        .zero('Você não clicou no botão')
        .one('Você clicou uma única vez')
        .two('Você clicou um par de vezes')
        .many('Você clicou {} vezes')
        .times(12, 'Você clicou uma dúzia de vezes'),
  };

String plural(value) => localizePlural(value, this, _t);
```

Or, if you want to define your translations by locale:

```dart
static var _t = Translations.byLocale('en-US') +
    {
      'en-US': {
        'You clicked the button {} times': 
          'You clicked the button {} times'
            .zero('You haven’t clicked the button')
            .one('You clicked it once')
            .two('You clicked a couple times')
            .many('You clicked {} times')
            .times(12, 'You clicked a dozen times'),
      },
      'pt-BR': {
        'You clicked the button {} times': 
          'Você clicou o botão {} vezes'
            .zero('Você não clicou no botão')
            .one('Você clicou uma única vez')
            .two('Você clicou um par de vezes')
            .many('Você clicou {} vezes')
            .times(12, 'Você clicou uma dúzia de vezes'),
      }
    };
```

> Note: `.plural()` actually accepts any `Object?`, not only an integer number.
> In case it's not an integer, it will be converted into an integer. The rules are:
> 1. If the modifier is an `int`, its absolute value will be used (meaning a negative
     value will become positive).
> 2. If the modifier is a `double`, its absolute value will be used, like so: `1.0` will
     be `1`;
     Values below `1.0` will become `0`; Values larger than `1.0` will be rounded up.
> 3. Strings will be converted to `int`, or if that fails to `double`. Conversion is done
     like so:
     First, it will discard other
     chars than numbers, dot and the minus sign, by converting them to spaces; Then it
     will convert using `int.tryParse`; Then it will convert using `double.tryParse`; If
     all fails, it will be zero.
> 4. Other objects will be converted to a string (using the `toString` method), and then
     the above rules will apply.

## Custom modifiers

You can actually create any modifiers you want. For example, some languages have different
translations for different genders. So you could create `.gender()` that accepts `Gender`
modifiers:

```dart
enum Gender {they, female, male}

int gnd = Gender.female;
return Text('There is a person'.gender(gnd));
```

Then, your translations file should use `.modifier()` and `localizeVersion()` like this:

```dart
static var _t = Translations.byText('en-US') +
  {
    'en-US': 'There is a person'
        .modifier(Gender.male, 'There is a man')
        .modifier(Gender.female, 'There is a woman')
        .modifier(Gender.they, 'There is a person'),
    'pt-BR': 'Há uma pessoa'
        .modifier(Gender.male, 'Há um homem')
        .modifier(Gender.female, 'Há uma mulher')
        .modifier(Gender.they, 'Há uma pessoa'),
  };

String gender(Gender gnd) => localizeVersion(gnd, this, _t);
```

## Direct use of translation objects

If you have a translation object you can use the `localize` function directly to perform
translations:

```dart
var translations = Translations.byText('en-US') +
    {
      'en-US': 'Hi',
      'pt-BR': 'Olá',
    };

// Prints 'Hi'
print(localize('Hi', translations, locale: 'en-US');

// Prints 'Olá'
print(localize('Hi', translations, locale: 'pt-BR');

// Prints 'Hi'
print(localize('Hi', translations, locale: 'not valid');
```

## Changing the current locale

To change the current locale, do this:

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

*Note: Any of the above will change the current locale for your widgets using
the `i18n_extension`, and also for native Flutter widgets.*

## Fallback rules

What happens when you don’t provide the translations for the current locale?
For example, suppose your current locale is Spanish, but you have only provided
translations for English and French.

Don’t worry — fallback behavior is usually intuitive and aligns with common sense.
In most cases, it will do exactly what you’d expect.
However, if you want all the details, here’s a complete breakdown of how it works:

1. **Exact Match:**  
   If a translation for the exact locale is found, it will be returned.
    - Example: For `zh-Hans-CN`, it will first look for `zh-Hans-CN`.
    - Example: For `pt-BR`, it will first look for `pt-BR`.

2. **Less Specific Locale:**  
   If an exact match is not found, it will search for translations to less specific
   locales, progressively broadening the scope until it reaches the general language.
    - Example: For `zh-Hans-CN`, it will next try `zh-Hans`, then `zh`.
    - Example: For `pt-BR`, it will next try `pt`.

3. **Alternate Locale Variants:**  
   If no direct or general match is found, it will look for translations in any other
   locale with the same language.
    - Example: For `zh-Hans-CN`, it might try `zh-Hant-CN`.
    - Example: For `pt-BR`, it might try `pt-PT` or `pt-MO`.

4. **Default Key:**  
   If no suitable translation is found, the key itself is returned. This could represent
   the default locale translation.
    - Example 1: If your code is `Text('Hello there'.i18n)` and no suitable translation
      is found, it will print `Hello there`.

## Reading the current locale

You can get the current locale by using the `context`:

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

Note: Using `I18n.localeStr` is deprecated. It returns a lowercase string with
underscores, like `en_us`.

## Observing locale changes

You can use a global static callback to observe locale changes:

```dart
I18n.observeLocale = 
  ({required Locale oldLocale, required Locale newLocale}) 
      => print('Changed from $oldLocale to $newLocale.');
```

## Const Translations

The `ConstTranslations` class allows you to define the translations as a const object,
all at once. This not only is a little bit more efficient,
but it's also better for "hot reload", since a const variable will respond to hot reloads,
while `final` variables will not.

Here you provide all locale translations of the first translatable string,
then all locale translations of the second one, and so on:

```dart
static const _t = ConstTranslations('en-US',
   {
     'i18n Demo': {
       'en-US': 'i18n Demo',
       'pt-BR': 'Demonstração i18n',
     },
     'Some text': {
       'en-US': 'Some text',
       'pt-BR': 'Algum texto',
     }
   },
);
```

IMPORTANT: _Make sure the locales you provide are correct (no spaces, lowercase etc).
Since this constructor is `const`, the package can’t normalize the locales for you.
If you are not sure, call `ConstTranslations.normalizeLocale(locale)` on the locale before
using it._

Unfortunately, the `ConstTranslations` class is not as flexible as the `Translations`
class, as you can’t define modifiers like `plural()` etc with it. This limits its
usefulness.

## A quick recap of Flutter locales

Flutter comes with a `Locale` class used throughout the Flutter framework to handle
internationalization.

The most common way to create a `Locale` is to call its default constructor and provide a
language code (usually 2 or 3 lowercase letters) and a country code (usually 2 uppercase
letters), as two **separate** strings.

For example:

```dart
var locale = Locale('en', 'US');

print(locale); // Prints `en_US`.
print(locale.languageCode); // Prints `en`.
print(locale.countryCode); // Prints `US`.
print(locale.scriptCode); // Prints `null`.
```

You may omit the country code:

```dart
var locale = Locale('en');

print(locale); // Prints `en`.
print(locale.languageCode); // Prints `en`.
print(locale.countryCode); // Prints `null`.
print(locale.scriptCode); // Prints `null`.
```

Unfortunately, `Locale` does not enforce case rules, while accepting invalid locales
and being case-sensitive, a bad combination that can lead to bugs.
For example, `Locale('en', 'US')` is not equal to `Locale('en', 'us')`,
and the second one is created with no errors, even though it's invalid.

You also have to remember **not** to provide the language and country codes as a
single String. For example, this is **wrong**:

```dart
// This will create a language called en_US and no country code.
var locale = Locale('en_US');

print(locale); // Prints `en_US`.
print(locale.languageCode); // Also prints `en_US`.
print(locale.countryCode); // Prints `null`.
print(locale.scriptCode); // Prints `null`.
```

Also, unfortunately, the language and country codes alone are not enough to specify all
possible locales. For example, in Chinese there are two "scripts", Simplified and
Traditional, which are specified by the script codes `Hans` and `Hant`, respectively.
Since the default `Locale` constructor does not accept a script code, you must use
the `Locale.fromSubtags` constructor, like this:

```dart
// Prnts 'zh_Hans_CN'
print(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'));
```

Finally, there is a problem regarding `Locale.toString()` use of underscores when
printing the language code.

Both the Unicode Locale Identifier (ULI) and the IETF BCP47 language tags accept
hyphens (`-`) as separators, but only ULI accepts underscores (`_`).

That's why `en-US` works for both ULI and BCP47, while `en_US` does not.
The likely reason why Flutter's `Locale` uses underscores in its `toString()`
method is because libraries like ICU (International Components for Unicode) and Java
historically use underscores to separate the language and region codes in locale
identifiers.

This convention stems from the early days of programming, where underscores
were commonly used as a delimiter in code and file names because they were simple,
unambiguous, and compatible across systems that might not handle special characters
like hyphens well.

However, most language translation services, like [MyTextAI](https://mytext.ai),
prefer the BCP47 convention: hyphens instead of underscores.

The `i18n_extension` package expected underscores in the translation definitions,
up to version `2.0.6`. However, starting from version `3.0.0` it expects hyphens.
This means that if you are using `i18n_extension` version `3.0.0` or later, you should use
hyphens in your locale. To help with the transition, `i18n_extension` version `3.0.0`
will throw descriptive errors if it finds underscores in your translation definitions.

This is an example of a valid translation definition:

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

## Using `Locale.asLocale` extension

If you don’t want to deal with the quirks of `Locale` objects,
you can create them from string language tags with `asLocale` extension
provided by the `i18n_extension` package. For example:

```dart
var locale = 'en-US'.asLocale;
```

Ideally, the string should be a
valid [IETF BCP47 Locale Identifier](https://www.ietf.org/rfc/bcp/bcp47.html)
(which is compatible with
the [Unicode Locale Identifier (ULI) syntax](https://www.unicode.org/reports/tr35/)).
such as 'en', 'en-US', 'pt-BR', 'es-419', 'hi-Deva-IN' or 'zh-Hans-CN'.

However, the `asLocale` extension will automatically fix lowercase/uppercase issues,
and will accept all these separators: `-` `_` ` ` `|` `.` `,` `;`,
and convert them to hyphens.

For example, the following lines are all equivalent:

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
```

## Using `Locale.format()` extension

As discussed, `Locale.toString()` returns the language code and the country code
separated by an underscore. For example, `Locale('en', 'US').toString()`
returns `en_US`. However, `Locale` does come with a `toLanguageTag()` method that
returns the language code and the country code separated by a hyphen.
For example, `Locale('en', 'US').toLanguageTag()` returns `en-US`.

The `i18n_extension` package provides a `format()` extension that also returns the
language code and the country code separated by a hyphen, but fixes any  
case issues with the locale representation.
For example, `Locale('en', 'us').format()` correctly returns `en-US`,
even though `Locale('en', 'us').toLanguageTag()` returns `en-us`.

Note the `format` extension also allows you to specify a different separator.
For example, `Locale('en', 'us').format(separator: '|')` returns `en|US`.

To sum up, the recommendation is to use the provided `asLocale` extension
to create `Locale` objects from string language tags; and the `format()` extension
to convert `Locale` objects back to string language tags, if needed.

## Dart-only package

This `i18n_extension` Flutter package depends on the Dart-only
package [i18n_extension_core](https://pub.dev/packages/i18n_extension_core).

If you are creating code for a Dart server (backend),
or developing some Dart-only package yourself that does not depend on Flutter,
then you can use the `i18n_extension_core` package directly:

```dart
import 'package:i18n_extension_core/i18n_extension_core.dart';

extension Localization on String {
   static var t = Translations.byText('en-US') + {'en-US':'Hello', 'pt-BR':'Olá'};
   String get i18n => localize(this, t);
}

DefaultLocale.set('es-ES');
expect('Hello'.i18n, 'Hola');
```

The main difference is that you must use `DefaultLocale.set(...)` instead of 
`I18n.of(context).locale = ...` to set the locale. You also will not have access to, 
or need, the `I18n` widget.

## Translation formats

The following formats may be used with translations:

* PO: https://poedit.net

* JSON: Can be used, however it lacks specific features for translation, like plurals and
  gender.

* ARB: This is based on JSON, and is the default format for Flutter localizations.
  https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification

* ICU: https://format-message.github.io/icu-message-format-for-translators/

* XLIFF: This is based in XML. https://en.wikipedia.org/wiki/XLIFF

* CSV: You can open this with Excel, save it in .XLSX and edit it there. However, beware
  not to export it back to CSV with the wrong settings
  (using something else than UTF-8 as encoding).
  https://en.wikipedia.org/wiki/Comma-separated_values

* YAML: Can be used, however it lacks specific features for translation, like plurals and
  gender.

Currently, only `.PO` and `.JSON` loaders are supported out-of-the-box, but if you need
to load from any other custom format, remember loading translations is easy to do because
the Translation constructors use maps as input. If you can generate a map from your file
format, you can then use the `Translation.byLocale()` constructor to create the
translation objects.

If you want to create custom loaders that are used automatically when you call
`Translations.byFile()`, you can do that by extending the `I18nLoader` class, and then
adding your custom loader to the static `I18n.loaders` list.

To see an example on how to create a loader, this is how `I18nJsonLoader` is implemented
to load `.json` files:

```dart
class I18nJsonLoader extends I18nLoader {

  @override
  String get extension => '.json';

  @override
  Map<String, dynamic> decode(String source) => json.decode(source);
}
```

## Exporting

As previously discussed, `i18n_extension` will automatically list all keys into a map if
you use some unknown locale, run the app, and manually or automatically go through all the
screens. For example, create a Greek locale if your app doesn’t have Greek translations,
and it will list all keys into `Translations.missingTranslationCallback`.

Then you can read from this map and create your exported file. There is
also [this package](https://pub.dev/packages/flutter_storyboard) that goes through all
screens automatically.

Another alternative is to use the `i18n_extension_importer` package,
at https://pub.dev/packages/i18n_extension_importer, where you can find the `GetStrings`
exporting utility, created by [Johann Bauer](https://github.com/bauerj).
It's a useful script designed to automate the export of all translatable strings from your
project. Simply run `flutter pub run i18n_extension_importer:getstrings` in your project
root directory, and you will get a list of strings to translate in `strings.json`.

# FAQ

**Q: Do I need to maintain the translation files as Dart files?**

**A:** _Not really. You do have a Dart file that creates a `Translation` object, yes, and
this object is optimized for easily creating translations by hand. But it creates them
from maps. So if you can create maps from some file you can use that file. For example, a
simple code generator that reads `.json` und outputs Dart maps would do the job:
`var _t = Translations.byText('en-US') + readFromJson('myfile.json')`._

<br>

**Q: If the app is using the system locale, and the user goes into the device settings
and changes the locale, would the app pick up the new locale automatically or would you
have to restart the app?**

**A:** _It picks up changes to the locale automatically._

<br>

**Q: What's the point of importing 'default.i18n.dart'?**

**A:** _This is the default file to import from your widgets. It lets the developer
add `.i18n` to any strings they want to mark as being a "translatable string". Later,
someone will have to remove this default file and add another one with the translations.
You basically just change the import later. The point of importing `default.i18n.dart`
before you create the translations for that widget is that it will record them as missing
translations, so that you don’t forget to add those translations later._

<br>

**Q: Can I translate strings in regular code, outside of widgets?**

**A:** _Yes, since you don’t need access to `context`. You can even get the current
locale from `I18n.locale`, which is static, and everything works with pure Dart code.
This means you can translate anything you want, from any code. You can also define a
locale on the fly if you want to do translations to a locale that is different from the
current one._

<br>

**Q: By using identifier keys like `howAreYou`, I know there’s a localization key
named `howAreYou`, because otherwise my code wouldn't compile. If I instead decide to use
strings as keys, is there a way to know at compile time that `'How are you?'.i18n` is
a valid localization key?**

**A:** _i18n_extension lets you decide if you want to use identifier keys like `howAreYou`
or not. Not having to use identifiers was one of the main things I was trying to achieve,
as I hate having to come up with them. I think the developer should be able to simply
type the text they want and be done with it. In `i18n_extension`, if you just type the
text itself, in your default language, that is always a valid key.
Your code will always compile when you type a String, and that exact
string will be used as your default language. It will never break._

<br>

**Q: What happens if a developer tries to call `i18n` on a key without translations?**

**A:** _With i18n_extension you can generate a report with all missing translations, and
you can even add those checks to tests._

<br>

**Q: Do I actually need one `.i18n.dart` (a translations file) per widget?**

**A:** _No you don’t. It's suggested that you create a translation file per widget if you
are doing translations by hand, but that's not a requirement. The reason I think separate
files is a good idea is that sometimes internationalization is not only translations. You
may need to format dates in specific ways, or make complex functions to create specific
strings that depend on variables etc. So in these cases you will probably need somewhere
to put this code. In any case, to make translations work all you need a Translation object
which you can create in many ways, by adding maps to it using the `+` operator, or by
adding other translation objects together using the `*` operator.
You can create this Translation objects anywhere you want, in a single file per widget,
in a single file for many widgets, or in a single file for the whole app. Also, if you are
not doing translations by hand but importing strings from translation files, then you
don’t even need a separate file. You can just add
`extension Localization on String { String get i18n => localize(this, Translations.byText('en-US') + load('file.json')); } `
to your own widget file._

<br>

**Q: Won’t having multiple files with `extension Localization` lead to people importing
the wrong file and have translations missing?**

**A:** _The package records all your missing translations, and you can also easily log or
throw an exception if they are missing. So you will know if you import the wrong file. You
can also add this reports to your unit tests. It will let you know even if you import the
right file and translations are missing in some language, and it will let you know even if
you import from `.arb` files and translations are missing in some language._

<br>

**Q: Are there importers for X?**

**A:** _Currently, only `.PO` and `.JSON` importers are supported out-of-the-box.
However, since the `Translations` object use maps as input/output, you can use whatever
file you want if you convert them to a map yourself._

<br>

**Q: How does it report missing translations?**

**A:** _At the moment you should just print `Translations.missingKeys`
and `Translations.missingTranslations`. We'll later create a `Translations.printReport()`
function that correlates these two pieces of information and outputs a more readable
report.

<br>

********

## By Marcelo Glasberg

<a href="https://glasberg.dev">_glasberg.dev_</a>
<br>
<a href="https://github.com/marcglasberg">_github.com/marcglasberg_</a>
<br>
<a href="https://www.linkedin.com/in/marcglasberg/">_linkedin.com/in/marcglasberg/_</a>
<br>
<a href="https://twitter.com/glasbergmarcelo">_twitter.com/glasbergmarcelo_</a>
<br>
<a href="https://stackoverflow.com/users/3411681/marcg">
_stackoverflow.com/users/3411681/marcg_</a>
<br>
<a href="https://medium.com/@marcglasberg">_medium.com/@marcglasberg_</a>
<br>

*My article in the official Flutter documentation*:

* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding
  constraints</a>

*The Flutter packages I've authored:*

* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/image_pixels">image_pixels</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a>
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a>
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>
* <a href="https://pub.dev/packages/themed">themed</a>
* <a href="https://pub.dev/packages/bdd_framework">bdd_framework</a>
* <a href="https://pub.dev/packages/tiktoken_tokenizer_gpt4o_o1">
  tiktoken_tokenizer_gpt4o_o1</a>

*My Medium Articles:*

* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">
  Async Redux: Flutter’s non-boilerplate version of Redux</a> 
  (versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">
  Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">
  i18n_extension</a> 
  (versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">
  Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">
  Flutter: The Advanced Layout Rule Even Beginners Must Know</a> 
  (versions: <a href="https://habr.com/ru/post/500210/">русский</a>)
* <a href="https://medium.com/flutter-community/the-new-way-to-create-themes-in-your-flutter-app-7fdfc4f3df5f">
  The New Way to create Themes in your Flutter App</a> 

[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)
