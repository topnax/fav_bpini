import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() => runApp(VRPApp());

class VRPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => Database(),
      child: MaterialApp(
        title: "VRP App",
        supportedLocales: [
          Locale('en', 'US'),
          Locale('cs', 'CZ'),
        ],

        darkTheme: ThemeData.dark(),

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
    );
  }
}

