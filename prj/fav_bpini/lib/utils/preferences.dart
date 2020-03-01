import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const THEME_STATUS_KEY = "THEMESTATUS";
  static const AUTO_POSITION_LOOKUP_KEY = "AUTOPOSITIONLOOKUP";
  static const APP_LANGUAGE_KEY = "APPLANGUAGE";

  static const DEFAULT_LANGUAGE_CODE = "cs";

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
    return prefs.getString(APP_LANGUAGE_KEY) ?? DEFAULT_LANGUAGE_CODE;
  }

}

class PreferencesProvider with ChangeNotifier {
  Preferences preferences = Preferences();

  bool _darkTheme = false;
  bool _autoPositionLookup = false;
  String _appLanguageCode = Preferences.DEFAULT_LANGUAGE_CODE;

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
