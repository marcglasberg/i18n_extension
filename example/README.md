# I18n examples

Please run `main.dart` in folders:

---

## `example/lib/example1` 

Demonstrates basic translations using a `I18n` widget.
  
There are 3 widget files that need translations:
* main.dart
* my_screen.dart
* my_widget.dart

And there is one translations-file for each one:
* main.i18n.dart
* my_screen.i18n.dart
* my_widget.i18n.dart

Note: We could have put all translations into a single translations-file
that would be used by all widget files. It's up to you how to organize
things.

Note: The translations-files in this example use strings as keys.
For example:

    "You clicked the button %d times:".plural(counter),

---

## `example/lib/example2` 

Demonstrates basic translations using a `I18n` widget.
  
There are 3 widget files that need translations:
* main.dart
* my_screen.dart
* my_widget.dart

But this time we demonstrate how to use a single translations-file for all of them:
* my.i18n.dart

Note: The translations-files in this example use identifiers as keys. For example:

     youClickedThisNumberOfTimes.plural(counter)

---

## `example/lib/example3` 

Demonstrates having two `I18n` widgets. It is NOT recommended to have two `I18n` widgets, at all.
However, if for some reason it is inevitable, I've provided the `I18n.forceRebuild()` method to help you deal with it.

---
