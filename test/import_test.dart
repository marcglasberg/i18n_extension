import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';

void main() {
  test("Import JSON translation", () async {
    var jsonSource = File("test/fixtures/de_DE.json").readAsStringSync();
    var translation = await JSONImporter().fromString("de", jsonSource);
    var myTranslations = Translations.byLocale("en_gb") + translation;
    expect(myTranslations.translations.length, 32);
    expect(localize("View", myTranslations, locale: "de"), "Ansicht");
  });

  test("Import PO translation", () async {
    var poSource = File("test/fixtures/strings-de.po").readAsStringSync();
    var translation = await GettextImporter().fromString("de", poSource);
    var myTranslations = Translations.byLocale("en_gb") + translation;
    expect(myTranslations.translations.length, 30);
    expect(localize("View", myTranslations, locale: "de"), "Ansicht");
    expect(
        localizePlural(0, "Error while uploading document", myTranslations,
            locale: "de"),
        "Fehler beim Hochladen des Dokuments");
    expect(
        localizePlural(1, "Error while uploading document", myTranslations,
            locale: "de"),
        "Fehler beim Hochladen des Dokument");
    expect(
        localizePlural(2, "Error while uploading document", myTranslations,
            locale: "de"),
        "Fehler beim Hochladen des Dokuments");
  });
}
