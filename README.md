[![](./example/SponsoredByMyTextAi.png)](https://mytext.ai)

[![pub package](https://img.shields.io/pub/v/i18n_extension.svg)](https://pub.dartlang.org/packages/i18n_extension)

# Translate your app!

> **_"Thank you for making the i18n_extension plugin._**
> **_It has helped me a lot in my latest project and I will surely use it again_**
> **_in my next Flutter project. It is so easy to set up and use and the code_**
> **_boilerplate is indeed very minimal."_**
>
> **_— Tomáš Jeřábek, Consultant/Developer_**

> This is a Flutter package. For a Dart-only package, see [i18n_extension_core](https://pub.dev/packages/i18n_extension_core)
 
> This package was mentioned by Google during
> the [Dart 2.7 announcement](https://medium.com/dartlang/dart-2-7-a3710ec54e97)

> Read
> the [Medium article](https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9)


&nbsp;<br>

Start with a widget containing some text:

```dart
Text('How are you?')
```

Translate it by simply adding `.i18n` to the string:

```dart
Text('How are you?'.i18n)
``` 

If the current locale is `'pt'` (the language code for Portuguese) or `pt_BR` (language code for
Brazilian Portuguese), then the text shown in the screen will be `'Como vai?'`, the Portuguese
translation to the above text. And so on for any other locales you want to support:

```dart
// Shows 'How are you?' when current locale is en_US.
// Shows '¿Cómo estás?' when current locale is es.
// Shows 'Comment ça va?' when current locale is fr.
Text('How are you?'.i18n)
```

As shown above, the original English text is itself the **"translation key"** that's used to look
up the translation.

But you can actually use objects of any type as translation keys. By adding `.i18n` they will
turn into translated strings in the current locale:

```dart
// Const values  
const greetings = UniqueKey();
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

You can also provide different translations depending on modifiers, such as `plural` quantities:

```dart
print('There is 1 item'.plural(0)); // Prints 'There are no items'
print('There is 1 item'.plural(1)); // Prints 'There is 1 item'
print('There is 1 item'.plural(2)); // Prints 'There are 2 items'
```

And you can invent your own modifiers according to any conditions. For example, some languages have
different translations for different genders. So you could create `gender` versions for `Gender`
modifiers:

```dart
print('There is a person'.gender(Gender.male)); // Prints 'There is a man'
print('There is a person'.gender(Gender.female)); // Prints 'There is a woman'
print('There is a person'.gender(Gender.they)); // Prints 'There is a person'
```

Also, interpolating strings is easy, with the `fill` method:

```dart
// Prints 'Hello John, this is Mary' in English.
// Prints 'Olá John, aqui é Mary' in Portuguese.
// Prints 'Olá John, aqui é Mary' in Portuguese.
print('Hello %s, this is %s'.i18n.fill(['John', 'Mary']));
```

## See it working

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/example1/main.dart">
example</a>.

![](./example/lib/example1/i18nScreen.jpg)

## Good for simple or complex apps

I'm always interested in creating packages to reduce boilerplate.
For example, [async_redux](https://pub.dev/packages/async_redux/) is about Redux without
boilerplate, [align_positioned](https://pub.dev/packages/align_positioned) is about creating layouts
using fewer widgets, and [themed](https://pub.dev/packages/themed) is about simplifying
the usage of colors and fonts.
Likewise, the current package is about reducing boilerplate for translations.
It does everything the plain old `Localizations.of(context)` does, but much easier.

It's meant for both the one-person app developer and the big company team. It
has you covered in all stages of your translation efforts:

1. When you create your widgets, it makes it easy for you to define which strings (or other objects
   serving as translation keys) should be translated by simply adding `.i18n` to them.
   These are called _"translatable strings"_ or _"translatable identifiers"_.

2. When you want to start your translation efforts, it can automatically list for you all strings
   that need translation. If you miss any of them, or if you later add more strings or modify some
   of them, it will let you know what changed and how to fix it.

3. You can then provide your translations manually in a very easy-to-use format.

4. Or you can easily integrate it with professional translation services, importing it from or
   exporting it to any format you want.

## Setup

Wrap your widget tree with the `I18n` widget, below the `MaterialApp`, together with
the `localizationsDelegates` and the `supportedLocales`:

```dart
import 'package:i18n_extension/i18n_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

...

@override
Widget build(BuildContext context) {
  return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('pt', 'BR'),
      ],
      home: I18n(child: ...)
  );
}
```

**Note:** To be able to import `flutter_localizations.dart` you must add this to
your `pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter

  i18n_extension: ...
```

The code `home: I18n(child: ...)` shown above will translate your strings to the **current system
locale**. Or you can override it with your own locale, like this:

```dart
I18n(
  initialLocale: Locale('pt', 'BR'),
  child: ...
```

**Note:** Don't ever put translatable strings in the same widget where you declared the `I18n`
widget, since they may not respond to future locale changes. For example, this is a mistake:

```dart
Widget build(BuildContext context) {
  return I18n(
    child: Scaffold(
      appBar: AppBar(title: Text('Hello there'.i18n)),
      body: MyScreen(),
  );
}
```

You may put translatable strings in any widgets down the tree.

## A quick recap of Dart locales

The correct way to create a `Locale` is to provide a language code (usually 2 or 3 lowercase
letters) and a country code (usually 2 uppercase letters), as two **separate** Strings.

For example:

```dart
var locale = Locale('en', 'US');

print(locale); // Prints `en_US`.
print(locale.languageCode); // Prints `en`.
```

You can, if you want, omit the country code:

```dart
var locale = Locale('en');

print(locale); // Prints `en`.
print(locale.languageCode); // Prints `en`.
```

But you **cannot** provide language code and country code as a single String. This is wrong:

```dart
// This will create a language called en_US and no country code.
var locale = Locale('en_US');

print(locale); // Prints `en_US`.
print(locale.languageCode); // Also prints `en_US`.
```

To help avoiding this mistake, the `i18n_extension` may throw an error if your language code
contains underscores.

## Translating a widget

When you create a widget that has translatable strings, add this default import to the widget's
file:

```dart
import 'package:i18n_extension/default.i18n.dart';
```

This will allow you to add `.i18n` and `.plural()` to your strings, but won't translate anything.

When you are ready to create your translations, you must create a dart file to hold them. This file
can have any name, but I suggest you give it the same name as your widget and change the termination
to `.i18n.dart`.

For example, if your widget is in file `my_widget.dart`, the translations could be in
file `my_widget.i18n.dart`

You must then remove the previous default import, and instead import your own translation file:

```dart
import 'my_widget.i18n.dart';
```

Your translation file itself will be something like this:

```dart
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var _t = Translations.byText('en_us') +
    {
      'en_us': 'Hello, how are you?',
      'pt_br': 'Olá, como vai você?',
      'es': '¿Hola! Cómo estás?',
      'fr': 'Salut, comment ca va?',
      'de': 'Hallo, wie geht es dir?',
    };

  String get i18n => localize(this, _t);
}
```

The above example shows a single translatable string, translated to American English, Brazilian
Portuguese, general Spanish, French and German.

You can, however, translate as many strings as you want, by simply adding more
**translation maps**:

```dart
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

    static var _t = Translations.byText('en_us') +
        {
          'en_us': 'Hello, how are you?',
          'pt_br': 'Olá, como vai você?',
        } +
        {
          'en_us': 'Hi',
          'pt_br': 'Olá',
        } +
        {
          'en_us': 'Goodbye',
          'pt_br': 'Adeus',
        };

  String get i18n => localize(this, _t);
}
```

## Strings themselves are the translation keys

The locale you pass in the `Translations` factory is called the **default locale**.
For example, in `Translations.byText('en_us')` the default locale is `en_us`.
The strings inside your `Text` widget should be in the language of that locale.

The strings themselves are used as **keys** when searching for translations to the other locales.
For example, in the `Text` below, `'Hello, how are you?'` is both the translation to English, and
the key to use when searching for its other translations:

```dart
Text('Hello, how are you?'.i18n)
```

If any translation key is missing from the translation maps, the key itself will be used, so the
text will still appear in the screen, untranslated.

If the translation key is found, it will choose the language according to the following rules:

1. It will use the translation to the exact current locale, for example `en_us`.

2. If this is absent, it will use the translation to the general language of the current locale, for
   example `en`.

3. If this is absent, it will use the translation to any other locale with the same language, for
   example `en_uk`.

4. If this is absent, it will use the value of the key in the default language.

5. If this is absent, it will use the key itself as the translation.

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/example1/main.dart">
example using strings as translation keys</a>.

## Or you can, instead, use identifiers as translation keys

Instead of:

```dart
'Hello there'.i18n
```

You can also do:

```dart
greetings.i18n
```

To that end, you can use the `Translations.byId<T>()` factory:

```dart
import 'package:flutter/foundation.dart';

final appbarTitle = UniqueKey();
final greetings = UniqueKey();

extension Localization on UniqueKey {
    
  static final _t = Translations.byId<UniqueKey>('en_us', {
    appbarTitle: {
      'en_us': 'i18n Demo',
      'pt_br': 'Demonstração i18n',
    },
    greetings: {
      'en_us': 'Helo there',
      'pt_br': 'Olá como vai',
    },    
  });

  String get i18n => localize(this, _t);    
}
```

Try running
the <a href="https://github.com/marcglasberg/i18n_extension/blob/master/example/lib/example2/main.dart">
example using identifiers as translation keys</a>.

<br>

Note: The native way of doing translation in Flutter forces you to define "identifier keys" for each
translation, and use those. For example, an identifier key could be `helloHowAreYou` or simply
`greetings`. And then you can access the translation like
this: `MyLocalizations.of(context).greetings`.

With `i18n_extension`, you can use ANY object type as translation keys.
Just use `Translations.byId<T>()` and provide the type `T` of your identifier. Your `T` can be
anything, including `String`, `int`, `double`, `DateTime`, or even your own custom object types, as
long as they implement `==` and `hashCode`.

Don't forget that your extensions need to be on your type.
For example, if you use `int` as your key type, you need to
declare `extension Localization on int { ... }`.

If your `T` is `Object` or `Object?` or `dynamic`, then anything can be translated, and
you need to write: `extension Localization on Objec? { ... }`

## Recommended way

We believe having to define identifiers is a boring task, and makes it difficult for you to remember
the exact text of the translations without having to look at the translation file.

For this reason we recommend you to simply type the text you want as a `String` inside your `Text()`
widgets, and add `.i18n` to them.

The exception is when you have very large texts that you need to translate, like for example
privacy policies, terms of use, long explanations etc. In those cases, you may want to use
identifiers, while keeping the rest as string keys.

In the example below, `privacyPolicy` and `termsOfUse` are used as identifiers, while `My Settings`,
`Ok` and `Back` are used as string keys:

```
import 'package:flutter/foundation.dart';

final privacyPolicy = UniqueKey();
final termsOfUse = UniqueKey();

extension Localization on Object {
    
  static final _t = Translations.byId<Object>('en_us', {
    privacyPolicy: { 'en_us': 'Very Looong text', 'pt_br': 'Very Looong text' },
    termsOfUse: { 'en_us': 'Very Looong text', 'pt_br': 'Very Looong text' },
    'My Settings': { 'en_us': 'My Settings', 'pt_br': 'Meus ajustes' },    
    'Ok': { 'en_us': 'Ok', 'pt_br': 'Salvar ajustes' },
    'Back': { 'en_us': 'Back', 'pt_br': 'Voltar' },
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

## Finding missing translations

If some string is already translated, and you later change it in the widget file, this will break
the link between the key and the translation map. However, `i18n_extension` is smart enough to let
you know when that happens, so it's easy to fix. You can even add this check to tests, as to make
sure all translations are linked and complete.

When you run your app or tests, each key not found will be recorded to the static
set `Translations.missingKeys`. And if the key is found but there is no translation to the current
locale, it will be recorded to `Translations.missingTranslations`.

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

Another thing you may do, if you want, is to set up callbacks that the `i18n_extension` package will
call whenever it detects a missing translation. You can then program these callbacks to throw errors
if any translations are missing, or log the problem, or send emails to the person responsible for
the translations.

To do that, simply inject your callbacks into `Translations.missingKeyCallback` and
`Translations.missingTranslationCallback`.

For example:

```dart
Translations.missingTranslationCallback =
  (key, locale) =>
    throw TranslationsException('There are no translations in $locale for key $key.');
```

## Defining translations by locale instead of by key

As explained, by using the `Translations.byText()` constructor you define each key and then provide
all its translations at the same time.
This is the easiest way when you are doing translations manually, for example,
when you speak English and Spanish and are creating yourself the translations to your app.

However, in other situations, such as when you are hiring professional translation services or
crowdsourcing translations, it may be easier if you can provide the translations by locale/language,
instead of by key. You can do that by using the `Translations.byLocale()` constructor.

```dart
static var _t = Translations.byLocale('en_us') +
    {
      'en_us': {
        'Hi.': 'Hi.',
        'Goodbye.': 'Goodbye.',
      },
      'es_es': {
        'Hi.': 'Hola.',
        'Goodbye.': 'Adiós.',
      }
    };
```

You can also add maps using the `+` operator:

```dart
static var _t = Translations.byLocale('en_us') +
    {
      'en_us': {
        'Hi.': 'Hi.',
        'Goodbye.': 'Goodbye.',
      },
    } +
    {
      'es_es': {
        'Hi.': 'Hola.',
        'Goodbye.': 'Adiós.',
      }
    };
```

Note above, since `en_us` is the default locale, you could omit the translations for it.

## Combining translations

To combine translations you can use the `*` operator. For example:

```dart
var t1 = Translations.byText('en_us') +
    {
      'en_us': 'Hi.',
      'pt_br': 'Olá.',
    };

var t2 = Translations.byText('en_us') +
    {
      'en_us': 'Goodbye.',
      'pt_br': 'Adeus.',
    };

var translations = t1 * t2;

print(localize('Hi.', translations, locale: 'pt_br');
print(localize('Goodbye.', translations, locale: 'pt_br');
```

## Translation modifiers

Sometimes you have different translations that depend on a number quantity. Instead of `.i18n` you
can use `.plural()` and pass it a number. For example:

```dart
int numOfItems = 3;
return Text('You clicked the button %d times'.plural(numOfItems));
```

This will be translated, and if the translated string contains `%d` it will be replaced by the
number.

Then, your translations file should contain something like this:

```dart
static var _t = Translations.byText('en_us') +
  {
    'en_us': 'You clicked the button %d times'
        .zero('You haven't clicked the button')
        .one('You clicked it once')
        .two('You clicked a couple times')
        .many('You clicked %d times')
        .times(12, 'You clicked a dozen times'),
    'pt_br': 'Você clicou o botão %d vezes'
        .zero('Você não clicou no botão')
        .one('Você clicou uma única vez')
        .two('Você clicou um par de vezes')
        .many('Você clicou %d vezes')
        .times(12, 'Você clicou uma dúzia de vezes'),
  };

String plural(value) => localizePlural(value, this, _t);
```

Or, if you want to define your translations by locale:

```dart
static var _t = Translations.byLocale('en_us') +
    {
      'en_us': {
        'You clicked the button %d times': 
          'You clicked the button %d times'
            .zero('You haven't clicked the button')
            .one('You clicked it once')
            .two('You clicked a couple times')
            .many('You clicked %d times')
            .times(12, 'You clicked a dozen times'),
      },
      'pt_br': {
        'You clicked the button %d times': 
          'Você clicou o botão %d vezes'
            .zero('Você não clicou no botão')
            .one('Você clicou uma única vez')
            .two('Você clicou um par de vezes')
            .many('Você clicou %d vezes')
            .times(12, 'Você clicou uma dúzia de vezes'),
      }
    };
```

The plural modifiers you can use are `zero`, `one`, `two`, `three`, `four`, `five`, `six`, `ten`,
`times` (for any number of elements, except 0, 1 and 2), `many` (for any number of elements, except
1, including 0), `zeroOne` (for 0 or 1 elements), and `oneOrMore` (for 1 and more elements).

Also, according to a <a href="https://github.com/marcglasberg/i18n_extension/issues/42">Czech
speaker</a>, there must be a special modifier for 2, 3 and 4. To that end you can use
the `twoThreeFour` modifier.

Note: It will use the most specific plural modifier. For example, `.two` is more specific
than `.many`. If no applicable modifier can be found, it will default to the unversioned string. For
example, this: `'a'.zero('b').four('c')` will default to `"a"`
for 1, 2, 3, or more than 5 elements.

> Note: The `.plural()` method actually accepts any `Object?`, not only an integer number. In case
> it's not an integer, it will be converted into an integer. The rules are:
> 1. If the modifier is an `int`, its absolute value will be used (meaning a negative value will
     become positive).
> 2. If the modifier is a `double`, its absolute value will be used, like so: `1.0` will be `1`;
     Values below `1.0` will become `0`; Values larger than `1.0` will be rounded up.
> 3. Strings will be converted to `int`, or if that fails to `double`. Conversion is done like so:
     First, it will discard other
     chars than numbers, dot and the minus sign, by converting them to spaces; Then it will convert
     using `int.tryParse`; Then it will convert using `double.tryParse`; If all fails, it will
     be zero.
> 4. Other objects will be converted to a string (using the `toString` method), and then the
     above rules will apply.

## Custom modifiers

You can actually create any modifiers you want. For example, some languages have different
translations for different genders. So you could create `.gender()` that accepts `Gender` modifiers:

```dart
enum Gender {they, female, male}

int gnd = Gender.female;
return Text('There is a person'.gender(gnd));
```

Then, your translations file should use `.modifier()` and `localizeVersion()` like this:

```dart
static var _t = Translations.byText('en_us') +
  {
    'en_us': 'There is a person'
        .modifier(Gender.male, 'There is a man')
        .modifier(Gender.female, 'There is a woman')
        .modifier(Gender.they, 'There is a person'),
    'pt_br': 'Há uma pessoa'
        .modifier(Gender.male, 'Há um homem')
        .modifier(Gender.female, 'Há uma mulher')
        .modifier(Gender.they, 'Há uma pessoa'),
  };

String gender(Gender gnd) => localizeVersion(gnd, this, _t);
```

## Interpolation

Your translations file may declare a `fill` method to do interpolations:

```dart
static var _t = Translations.byText('en_us') +
  {
    'en_us': 'Hello %s, this is %s',
    'pt_br': 'Olá %s, aqui é %s',
  };

String get i18n => localize(this, _t);

String fill(List<Object> params) => localizeFill(this, params);
```

Then you may use it like this:

```dart
print('Hello %s, this is %s'.i18n.fill(['John', 'Mary']));
```

The above code will print `Hello John, this is Mary` if the locale is English,
or `Olá John, aqui é Mary` if it's Portuguese.

It uses the <a href="https://pub.dev/packages/sprintf">sprintf</a> package internally. I don't know
how closely it follows the C sprintf specification,
but <a href="https://www.tutorialspoint.com/c_standard_library/c_function_sprintf.htm">here it
is</a>.

## Direct use of translation objects

If you have a translation object you can use the `localize` function directly to perform
translations:

```dart
var translations = Translations.byText('en_us') +
    {
      'en_us': 'Hi',
      'pt_br': 'Olá',
    };

// Prints 'Hi'.
print(localize('Hi', translations, locale: 'en_us');

// Prints 'Olá'.
print(localize('Hi', translations, locale: 'pt_br');

// Prints 'Hi'.
print(localize('Hi', translations, locale: 'not valid');
```

## Changing the current locale

To change the current locale, do this:

```dart
I18n.of(context).locale = Locale('pt', 'BR');
```

To return the current locale to the **system default**, do this:

```dart
I18n.of(context).locale = null;
```

*Note: The above will change the current locale only for the `i18n_extension`, and not for Flutter
as a whole.*

## Reading the current locale

To read the current locale, do this:

```dart
// Both ways work:
Locale locale = I18n.of(context).locale;
Locale locale = I18n.locale;

// Or get the locale as a lowercase string. Example: 'en_us'.
String localeStr = I18n.localeStr;

// Or get the language of the locale, lowercase. Example: 'en'.
String language = I18n.language;
```        

## Observing locale changes

There is a global static callback you can use to observe locale changes:

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
static const _t = ConstTranslations('en_us',
   {
     'i18n Demo': {
       'en_us': 'i18n Demo',
       'pt_br': 'Demonstração i18n',
     },
     'Some text': {
       'en_us': 'Some text',
       'pt_br': 'Algum texto',
     }
   },
);
```

IMPORTANT: _Make sure the locales you provide are correct (no spaces, lowercase etc).
Since this constructor is `const`, the package can't normalize the locales for you.
If you are not sure, call `ConstTranslations.normalizeLocale(locale)` on the locale before using
it._

Unfortunately, the `ConstTranslations` class is not as flexible as the `Translations` class,
as you can't define modifiers like `plural()` etc with it. This limits its usefulness.

## Dart-only package

This `i18n_extension` Flutter package depends on the Dart-only
package [i18n_extension_core](https://pub.dev/packages/i18n_extension_core).

If you are creating code for a Dart server (backend) like [Celest](https://celest.dev), or
developing some Dart-only package yourself that does not depend on Flutter, then you can use
the `i18n_extension_core` package directly:

```dart
import 'package:i18n_extension_core/i18n_extension_core.dart';

extension Localization on String {
   static var t = Translations.byText('en_us') + {'en_us':'Hello', 'pt_br':'Olá'};
   String get i18n => localize(this, t);
}

DefaultLocale.set('es_ES');
expect('Hello'.i18n, 'Hola');
```

The only important difference is that you must use `DefaultLocale.set()` instead
of `I18n.of(context).locale = ...` to set the locale. And you won't have access
and won't need to use the `i18n` widget, obviously.

## Importing and exporting

The `i18n_extension` package is optimized so that you can easily create and manage all of your
translations yourself, by hand.

However, for large projects with big teams you probably need to follow a more involved process:

* Export all your translatable strings to files in some external format your professional
  translator, or your crowdsourcing tool uses (see formats below).

* Continue developing your app while waiting for the translations.

* Import the translation files into the project and test the app in each language you added.

* Repeat the process as needed, translating just the changes between each app revision. As
  necessary, perform additional localization steps yourself.

### Formats

The following formats may be used with translations:

* PO: https://poedit.net

* JSON: Can be used, however it lacks specific features for translation, like plurals and gender.

* ARB: This is based on JSON, and is the default format for Flutter localizations.
  https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification

* ICU: https://format-message.github.io/icu-message-format-for-translators/

* XLIFF: This is based in XML. https://en.wikipedia.org/wiki/XLIFF

* CSV: You can open this with Excel, save it in .XLSX and edit it there. However, beware not to
  export it back to CSV with the wrong settings
  (using something else than UTF-8 as encoding).
  https://en.wikipedia.org/wiki/Comma-separated_values

* YAML: Can be used, however it lacks specific features for translation, like plurals and gender.

### Importing

Up to version `8.0.0`, the `i18n_extension` package contained the importer library.
It has now been separated and is now independently available as a standalone package.
You can find it at: https://pub.dev/packages/i18n_extension_importer.

**Note:** Those importers were contributed by <a href="https://github.com/bauerj">Johann Bauer</a>,
and were separated into their own package by <a href="https://github.com/c0dezli">Xiang Li</a>.

Currently, only `.PO` and `.JSON` importers are supported out-of-the-box.
If you want to help creating importers for any of the other formats above, please PR there.

It also includes the `GetStrings` exporting utility, which is a useful script designed to
automate the export of all translatable strings from your project.

Add your translation files as assets to your app in a directory structure like this:

```
app
 \_ assets
    \_ locales
       \_ de.po
       \_ fr.po
        ...
```

Then you can import them using `GettextImporter` or `JSONImporter`:

```dart
import 'package:i18n_extension_importer/io/import.dart';
import 'package:i18n_extension/i18n_extension.dart';

class MyI18n {
  static var translations = Translations.byLocale('en');

  static Future<void> loadTranslations() async {
    translations +=
        await GettextImporter().fromAssetDirectory('assets/locales');
  }
}

extension Localization on String {
  String get i18n => localize(this, MyI18n.translations);
  String plural(value) => localizePlural(value, this, MyI18n.translations);
  String fill(List<Object> params) => localizeFill(this, params);
}
```

For usage in main.dart,
see <a href="https://github.com/marcglasberg/i18n_extension/issues/63#issuecomment-770056237">
here</a>.

**Note**: When using .po files, make sure not to include the country code, because the locales are
generated from the filenames which don't contain the country code and if you'd include the country
codes, you'll get errors like this: `There are no translations in 'en_us' for 'Hello there'`.

**Note:** If you need to import any other custom format, remember importing is easy to do because
the Translation constructors use maps as input. If you can generate a map from your file format, you
can then use the `Translation()` or `Translation.byLocale()` constructors to create the translation
objects.

### The GetStrings exporting utility

A utility script to automatically export all translatable strings from your project was also
contributed by <a href="https://github.com/bauerj">Johann Bauer</a>.

Simply run `flutter pub run i18n_extension_importer:getstrings` in your project root directory, and
you will get a list of strings to translate in `strings.json`. This file can then be sent to your
translators or be imported in translation services like _Crowdin_, _Transifex_ or _Lokalise_. You
can use it as part of your CI pipeline in order to always have your translation templates up to
date.

Note the tool simply searches the source code for strings to which getters like `.i18n` are applied.
Since it is not very smart, you should not make it too hard:

```dart
print('Hello World!'.i18n); // This would work.

// But the tool would not be able to spot this 
// since it doesn't execute the code.
var x = 'Hello World';
print(x.i18n);
```

### Other ways to export

As previously discussed, i18n_extension will automatically list all keys into a map if you use some
unknown locale, run the app, and manually or automatically go through all the screens. For example,
create a Greek locale if your app doesn't have Greek translations, and it will list all keys
into `Translations.missingTranslationCallback`.

Then you can read from this map and create your exported file. There is
also <a href="https://pub.dev/packages/flutter_storyboard">this package</a>
that goes through all screens automatically.

# FAQ

**Q: Do I need to maintain the translation files as Dart files?**

**A:** _Not really. You do have a Dart file that creates a `Translation` object, yes, and this
object is optimized for easily creating translations by hand. But it creates them from maps. So if
you can create maps from some file you can use that file. For example, a simple code generator that
reads `.json` und outputs Dart maps would do the job:
`var _t = Translations.byText('en_us') + readFromJson('myfile.json')`._

<br>

**Q: How do you handle changing the locale? Does the I18n class pick up changes to the locale
automatically or would you have to restart the app?**

**A:** _It should pick changes to the locale automatically. Also, you can change the locale manually
at any time by doing `I18n.of(context).locale = Locale('pt', 'BR');`._

<br>

**Q: What's the point of importing 'default.i18n.dart'?**

**A:** _This is the default file to import from your widgets. It lets the developer add `.i18n` to
any strings they want to mark as being a "translatable string". Later, someone will have to remove
this default file and add another one with the translations. You basically just change the import
later. The point of importing 'default.i18n.dart' before you create the translations for that widget
is that it will record them as missing translations, so that you don't forget to add those
translations later._

<br>

**Q: Can I do translations outside of widgets?**

**A:** _Yes, since you don't need access to `context`. It actually reads the current locale
from `I18n.locale`, which is static, and all the rest is done with pure Dart code. So you can
translate anything you want, from any code you want. You can also define a locale on the fly if you
want to do translations to a locale different from the current one._

<br>

**Q: By using identifier keys like `howAreYou`, I know that there's a localization key
named `howAreYou` because otherwise my code wouldn't compile. There is no way to statically verify
that `'How are you?'.i18n` will do what I want it to do.**

**A:** _i18n_extension lets you decide if you want to use identifier keys like `howAreYou` or not.
Not having to use those was one thing I was trying to achieve. I hate having to come up with these
keys. I found that the developer should just type the text they want and be done with it. In other
words, in i18n_extension you don't need to type a key; you may type the text itself (in your default
language). So there is no need to statically verify anything. Your code will always compile when you
type a String, and that exact string will be used for your default language. It will never break._

<br>

**Q: But how can I statically verify that a string has translations? Just showing the translatable
string as defined in the source code will not hide that some translations are missing?**

**A:** _You can statically verify that a string should have translations because it has `.i18n`
attached to it. What you can't do is statically verify that those translations were actually
provided for all supported languages. But this is also the case when you use older methods. With the
older methods you also just know it should have translations, because it has a translation key, but
the translation itself may be missing, or worse yet, outdated. With i18n_extension at least you know
that the translation to the default language exists and is not outdated._

<br>

**Q: What happens if a developer tries to call `i18n` on a string without translations, wouldn't
that be harder to catch?**

**A:** _With i18n_extension you can generate a report with all missing translations, and you can
even add those checks to tests. In other words, you can just freely modify any translatable string,
and before your launch you get the reports and fix all the translations._

<br>

**Q: There are a lot of valid usages for String that don't deal with user-facing messages. I like to
use auto-complete to see what methods are available (by typing `someString.`), and seeing loads of
unrelated extension methods in there could be annoying.**

**A:** _The translation extension is contained in your widget file. You won't have this extension in
scope for your business classes, for example. So `.i18n` will only appear in your auto-complete
inside of your widget classes, where it makes sense._

<br>

**Q: Do I actually need one `.i18n.dart` (a translations file) per widget?**

**A:** _No you don't. It's suggested that you create a translation file per widget if you are doing
translations by hand, but that's not a requirement. The reason I think separate files is a good idea
is that sometimes internationalization is not only translations. You may need to format dates in
specific ways, or make complex functions to create specific strings that depend on variables etc. So
in these cases you will probably need somewhere to put this code. In any case, to make translations
work all you need a Translation object which you can create in many ways, by adding maps to it using
the `+` operator, or by adding other translation objects together using the `*` operator. You can
create this Translation objects anywhere you want, in a single file per widget, in a single file for
many widgets, or in a single file for the whole app. Also, if you are not doing translations by hand
but importing strings from translation files, then you don't even need a separate file. You can just
add
`extension Localization on String { String get i18n => localize(this, Translations.byText('en_us') + load('file.json')); } `
to your own widget file._

<br>

**Q: Won't having multiple files with `extension Localization` lead to people importing the wrong
file and have translations missing?**

**A:** _The package records all your missing translations, and you can also easily log or throw an
exception if they are missing. So you will know if you import the wrong file. You can also add this
reports to your unit tests. It will let you know even if you import the right file and translations
are missing in some language, and it will let you know even if you import from `.arb` files and
translations are missing in some language._

<br>

**Q: Are there importers for X?**

**A:** _Currently, only `.PO` and `.JSON` importers are supported out-of-the-box. Keep in mind this
lib development is still new, and I hope the community will help writing more importers/exporters.
We hope to have those for `.arb` `.icu` `.xliff` `.csv` and `.yaml`, but we're not there yet.
However, since the `Translations` object use maps as input/output, you can use whatever file you
want if you convert them to a map yourself._

<br>

**Q: How does it report missing translations?**

**A:** _At the moment you should just print `Translations.missingKeys`
and `Translations.missingTranslations`. We'll later create a `Translations.printReport()` function
that correlates these two pieces of information and outputs a more readable report.

<br>

**Q: The package says it's "Non-boilerplate", but doesn't `.i18n.dart` contain boilerplate?**

**A:** _The only necessary boilerplate for `.i18n.dart` files
is `static var _t = Translations.byText('...') +`
and `String get i18n => localize(this, _t);`. The rest are the translations themselves. So, yeah,
it's not completely without boilerplate, but saying "Less-boilerplate" is not that catchy._

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
