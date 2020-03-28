import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/routing/router.dart';
import 'package:favbpini/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

final log = Logger(printer: SimplePrinter(printTime: false));

void main() {
  if (!kDebugMode) {
    Logger.level = Level.nothing;
  } else {
    Logger.level = Level.debug;
  }
  runApp(VRPApp());
}

class VRPApp extends StatefulWidget {
  @override
  VRPAppState createState() => VRPAppState();
}

class VRPAppState extends State<VRPApp> {
  PreferencesProvider preferencesProvider = PreferencesProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    preferencesProvider.darkTheme = await preferencesProvider.preferences.getDarkTheme();
    preferencesProvider.autoPositionLookup = await preferencesProvider.preferences.getAutoPositionLookup();
    preferencesProvider.appLanguageCode = await preferencesProvider.preferences.getAppLanguageCode();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ChangeNotifierProvider(
      create: (_) {
        return preferencesProvider;
      },
      child: Consumer<PreferencesProvider>(
        builder: (context, value, child) {
          log.d("selected language code: " + value.appLanguageCode);
          return Provider(
            create: (_) => Database(),
            child: MaterialApp(
              title: "VRP App",
              supportedLocales: [
                Locale('en', 'US'),
                Locale('cs', 'CZ'),
              ],

              locale: Locale(value.appLanguageCode),

              theme: value.darkTheme
                  ? ThemeData.dark().copyWith(
                      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
                    )
                  : ThemeData.light().copyWith(
                      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
                    ),

              // These delegates make sure that the localization data for the proper language is loaded
              localizationsDelegates: [
                AppLocalizationsDelegate(myLocale: Locale(value.appLanguageCode)),
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
        },
      ),
    );
  }
}
