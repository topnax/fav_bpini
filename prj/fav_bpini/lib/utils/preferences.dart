import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const THEME_STATUS_KEY = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS_KEY, value);
  }

  Future<bool> getDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS_KEY) ?? false;
  }

  static const AUTO_POSITION_LOOKUP_KEY = "AUTOPOSITIONLOOKUP";

  setAutoPositionLookup(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(AUTO_POSITION_LOOKUP_KEY, value);
  }

  Future<bool> getAutoPositionLookup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AUTO_POSITION_LOOKUP_KEY) ?? false;
  }

}

class PreferencesProvider with ChangeNotifier {
  Preferences preferences = Preferences();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    preferences.setDarkTheme(value);
    notifyListeners();
  }

  bool _autoPositionLookup = false;

  bool get autoPositionLookup => _autoPositionLookup;

  set autoPositionLookup(bool value) {
    _autoPositionLookup = value;
    preferences.setAutoPositionLookup(value);
    notifyListeners();
  }
}
