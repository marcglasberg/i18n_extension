# i18n_extension

## Translation and Internationalization (i18n) for Flutter

Imagine you have a widget with some text in it:

```dart
Text("Hello, how are you?")
```

Now imagine you can translate it by simply adding `.i18n` to the string:

```dart
Text("Hello, how are you?".i18n)
```

If the current locale is, say, 'pt_BR' the text in the screen should read
"Olá, como vai você?". And so on for any other locales you want to support.

With the [`i18n_extension`](https://pub.dev/packages/async_redux/) package you can do just that.

## Purpose

This package has you covered in all stages of your translation efforts:

1. When you create your widgets, it makes it easy for you to define which strings should be
translated, by simply adding `.i18n` to them. These strings are called _"translatable strings"_.

2. When you want to start your translation efforts, it can automatically list for you
all strings that need translation. If you miss any strings, or if you later add more strings
or modify some of them, it will let you know what changed and how to fix it.

3. You can then provide your translations manually, in a very easy-to-use format.

4. Or you can easily integrate it with professional translation services, importing it from,
or exporting it to any format you want.

## Setup

Wrap your widget tree with the `I18n` widget, like this:

```dart
@override
Widget build(BuildContext context) {
  return I18n(
    child: Scaffold( ... )
  );
}
```

This will get the current system locale, but you can override it like this:

```dart
return I18n(
  locale: Locale("pt_br"),
  child: Scaffold( ... )
```

When you create a widget that will have a translatable strings,
add this default import to the widget's file:

```dart
import 'package:i18n_extension/default.i18n.dart';
```

This will simply allow you to add `.i18n` to your strings, but won't translate anything.

When you are ready to create your translations, you must create a dart file to hold them.
This file can have any name, but I suggest you give it the same name as your widget
but with the termination `.18n.dart`. For example, if your widget is in file `my_widget.dart`
the translations could be in file `my_widget.i18n.dart`

You must then remove the previous default import, and instead import your own translation file:

```dart
import 'my_widget.i18n.dart';
```

Your translation file itself will be something like this:

```dart
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {

  static var t = Translations("en_us") +
    {
      "en_us": "Hello, how are you?",
      "pt_br": "Olá, como vai você?",
      "es": "¿Hola! Cómo estás?",
      "fr": "Salut, comment ca va?",
      "de": "Hallo, wie geht es dir?",
    };

  String get i18n => localize(this, t);
}
```

The above example shows a single translatable string, translated to American English,
Brazilian Portuguese, and general Spanish, French and German.
You can, however, translate as many strings as you want, by simply adding more
**translation maps**:

```dart
static var t = Translations("en_us") +
    {
      "en_us": "Hello, how are you?",
      "pt_br": "Olá, como vai você?",
    } +
    {
      "en_us": "Hi",
      "pt_br": "Olá",
    } +
    {
      "en_us": "Goodbye",
      "pt_br": "Adeus",
    };
```

## Strings themselves are the translation keys

The locale you pass in the `Translations()` constructor is called the **default locale**.
For example, in `Translations("en_us")` the default locale is `en_us`.
All translatable strings in the widget file should be in the language of that locale.
The strings themselves are used as **keys** when searching for translations to the other locales.

For example, in the `Text` below, `"Hello, how are you?"` is both the translation to English,
and the key to use when searching for its translations:

```dart
Text("Hello, how are you?".i18n)
```

If any translation key is missing from the translation maps, the key itself will be used,
so the text will still appear in the screen, untranslated.

If the translation key is found, it will choose the language according to the following rules:

1. Use the translation to the exact locale, for example `en_us`.

2. If this is absent, use the translation to the general language of the locale,
   for example `en_us`.

3. If this is absent, use the translation to any other locale with the same language,
   for example `en_uk`.

4. If this is absent, use the key itself as the translation.

### Managing keys

Other translation packages ask you to define key identifiers for each translation,
and use those. For example, the above text key could be `helloHowAreYou` or simply `greetings`.
And then you could access it like this: `MyLocalizations.of(context).greetings`.

However, having to define identifiers is not only a boring task, but it also forces you
to navigate to the translation if you need to remember the exact text of the widget.

With `i18n_extension` you can simply type the text you want and that's it.
If some string is already translated and you later you change it in the widget file,
this will break the link between the key and the translation map.
However, `i18n_extension` is smart enough to let you know when that happens,
so it's easy to fix. You can even add this check to tests, as to make sure all translations are
linked and complete.

When you run your app or tests, each key not found will be recorded to the static set
`Translations.missingKeys`. And if the key is found but there is no translation to the
current locale, it will be recorded to `Translations.missingTranslations`.

You can manually inspect those sets to see if they're empty, or create tests to do that
automatically, for example:

```dart
expect(Translations.missingKeys, isEmpty);
expect(Translations.missingTranslations, isEmpty);
```

Another thing you may do if you want, is to throw an error if some translation is missing.
To that end, inject callbacks into `Translations.missingKeyCallback` and
`Translations.missingTranslationCallback`. For example:

```dart
Translations.missingKeyCallback = (key, locale)
  => throw TranslationsException("Translation key in '$locale' is missing: '$key'.");

Translations.missingTranslationCallback = (key, locale)
  => throw TranslationsException("There are no translations in '$locale' for '$key'.");
```

Or instead of throwing you could log the problem,
or send an email to the person responsible for the translations.

### Importing and exporting

[talk about .arb files, .json, and other formats]

.......


