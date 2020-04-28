import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  /// A map containing supported languages of the application.
  static const SUPPORTED_LANGUAGE_CODES = {"cs": "Čeština", "en": "English"};

  /// Default language code.
  static const DEFAULT_LANGUAGE_CODE = "en";

  /// Selected locale.
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper method to keep the code in the widgets concise
  /// Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Map containing localized strings.
  Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  /// This method will be called from every widget which needs a localized text.
  String translate(String key) {
    if (!_localizedStrings.containsKey(key)) {
      return "Untranslated (${locale.languageCode}:$key)";
    }
    return _localizedStrings[key];
  }
}

/// LocalizationsDelegate is a factory for a set of localized resources.
/// In this case, the localized strings will be gotten in an AppLocalizations object.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  static const _defaultLanguageCode = "en";

  final Locale appLocale;

  AppLocalizationsDelegate({this.appLocale = const Locale(_defaultLanguageCode)});

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.SUPPORTED_LANGUAGE_CODES.keys.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localeToBeSet = appLocale ?? locale;
    if (!isSupported(localeToBeSet)) {
      localeToBeSet = Locale(_defaultLanguageCode);
    }
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(appLocale ?? locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
