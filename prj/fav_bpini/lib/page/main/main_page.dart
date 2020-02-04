import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/page/vrp_list/vrp_list_page.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent.withOpacity(0.5),
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: VrpListPage(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              '/finder',
            );
          },
          tooltip: 'New VRP',
          backgroundColor: Colors.orange,
          child: Icon(Icons.add),
          elevation: 2.0,
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {},
                ),
              ],
            ),
            color: Colors.blueAccent,
            shape: CircularNotchedRectangle()));
  }
}
