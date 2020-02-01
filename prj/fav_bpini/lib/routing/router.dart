import 'package:favbpini/page/main/main_page.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
//    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainPage());
      case '/found':
        return MaterialPageRoute(builder: (_) => MainPage(vrpBlock: settings.arguments));
      case '/finder':
        return MaterialPageRoute(builder: (_) => VrpFinderPage());
//      case '/camera':
//        return MaterialPageRoute(builder: (_) => TakePictureScreen(args));

      default:
      // If there is no such named route in the switch statement, e.g. /third
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
