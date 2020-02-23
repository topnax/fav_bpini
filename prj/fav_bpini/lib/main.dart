import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/routing/router.dart';
import 'package:favbpini/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() => runApp(VRPApp());

class VRPApp extends StatefulWidget {

  @override
  VRPAppState createState() => VRPAppState();
}

class VRPAppState extends State<VRPApp>{

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) => Provider(
          create: (_) => Database(),
          child: MaterialApp(
            title: "VRP App",
            supportedLocales: [
              Locale('en', 'US'),
              Locale('cs', 'CZ'),
            ],

            darkTheme: value.darkTheme ? ThemeData.dark(): ThemeData.light(),

            // These delegates make sure that the localization data for the proper language is loaded
            localizationsDelegates: [
              AppLocalizations.delegate,
              // Built-in localization of basic text for Material widgets
              GlobalMaterialLocalizations.delegate,
              // Built-in localization for text direction LTR/RTL
              GlobalWidgetsLocalizations.delegate,
            ],

            // Returns a locale which will be used by the app
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }
              // If the locale of the device is not supported, use the first one
              // from the list (English, in this case).
              return supportedLocales.first;
            },

            initialRoute: '/',
            onGenerateRoute: Router.generateRoute,
          ),
        ),
      ),
    );
  }
}

