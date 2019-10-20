# i18n_extension

Mind-blowing Easy Translation and Internationalization (i18n) for Flutter

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
translated, by simply adding `.i18n` to them.

2. When you want to start your translation efforts, it can automatically list for you
all strings that need translation. If you miss any strings, or if you later add more strings
or modify some of them, it will let you know what changed and how to fix it.

3. You can then provide your translations manually, in a very easy-to-use format.

4. Or you can easily integrate it with professional translation services, import it from,
or export it to any format you want.

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

When you first create a widget that will have translated strings, add this import to the widget's
file:

```dart
import 'package:i18n_extension/default.i18n.dart';
```

This will simply allow you to add `.i18n` to your strings, but won't translate anything.

When you are ready to create your translations, you must create a dart file to hold them.
This file can have any name, but I suggest you give it the same name as your widget
and the termination `.18n.dart`. For example, if your widget is in file `my_widget.dart`
the translations would be in file `my_widget.i18n.dart`

You must then remove the previous default import, and instead import your own translation file:

```dart
import 'my_widget.i18n.dart';
```

Your translation file should be like this:

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

You can translate as many strings as you want, by adding them like this:

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

The locale you define in `Translations("en_us")` is called the **default locale**.
All strings in your widget file are supposed to be the translation to that locale.
Those strings are used as **keys** for the translations to other locales.

## Strings themselves are the translation keys

.......


