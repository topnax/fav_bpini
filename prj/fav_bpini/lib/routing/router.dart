import 'package:favbpini/page/main/main_page.dart';
import 'package:favbpini/page/settings/settings_page.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainPage(), settings: RouteSettings(name: "/"));

      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsPage());

      case '/finder':
        if (settings.arguments is VrpFinderPageArguments) {
          return MaterialPageRoute(builder: (_) => VrpFinderPage(settings.arguments));
        }
        return _errorRoute();

      case '/found':
        if (settings.arguments is VrpPreviewPageArguments) {
          return MaterialPageRoute(builder: (_) => VrpPreviewPage(settings.arguments));
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('VRPApp'),
        ),
        body: Center(
          child: Text('ERROR - no route found'),
        ),
      );
    });
  }
}
