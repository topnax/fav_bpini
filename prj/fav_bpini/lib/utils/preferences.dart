import 'dart:io';

import 'package:favbpini/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const THEME_STATUS_KEY = "THEMESTATUS";
  static const AUTO_POSITION_LOOKUP_KEY = "AUTOPOSITIONLOOKUP";
  static const APP_LANGUAGE_KEY = "APPLANGUAGE";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS_KEY, value);
  }

  Future<bool> getDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS_KEY) ?? false;
  }

  setAutoPositionLookup(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(AUTO_POSITION_LOOKUP_KEY, value);
  }

  Future<bool> getAutoPositionLookup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AUTO_POSITION_LOOKUP_KEY) ?? false;
  }

  setAppLanguageCode(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(APP_LANGUAGE_KEY, languageCode);
  }

  Future<String> getAppLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var prefLanguage = prefs.getString(APP_LANGUAGE_KEY);
    if (prefLanguage == null) {
      prefLanguage = AppLocalizations.DEFAULT_LANGUAGE_CODE;
      // if no language preference is set, try to set the language according to the device's locale otherwise use the default one
      for (var langCode in AppLocalizations.SUPPORTED_LANGUAGE_CODES.keys) {
        if (Platform.localeName.contains(langCode)) {
          prefLanguage = langCode;
          break;
        }
      }
    }
    return prefLanguage;
  }
}

class PreferencesProvider with ChangeNotifier {
  Preferences preferences = Preferences();

  bool _darkTheme = false;
  bool _autoPositionLookup = false;
  String _appLanguageCode = AppLocalizations.DEFAULT_LANGUAGE_CODE;

  bool get autoPositionLookup => _autoPositionLookup;
  bool get darkTheme => _darkTheme;
  String get appLanguageCode => _appLanguageCode;

  set darkTheme(bool value) {
    _darkTheme = value;
    preferences.setDarkTheme(value);
    notifyListeners();
  }

  set autoPositionLookup(bool value) {
    _autoPositionLookup = value;
    preferences.setAutoPositionLookup(value);
    notifyListeners();
  }

  set appLanguageCode(String languageCode) {
    _appLanguageCode = languageCode;
    preferences.setAppLanguageCode(languageCode);
    notifyListeners();
  }
}
