import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _tabPages.length, vsync: this, initialIndex: 0);
  }

  final _tabPages = <Widget>[
    VrpPreviewPage(),
    Center(child: Icon(Icons.settings, size: 64.0, color: Colors.blue)),
  ];
  static const _tabs = <Tab>[
    Tab(icon: Icon(Icons.format_list_bulleted)),
    Tab(icon: Icon(Icons.settings)),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("app_title")),
          centerTitle: true,
        ),
        body: TabBarView(
          controller: _tabController,
          children: _tabPages,
        ),
        bottomNavigationBar: Material(
          color: Colors.blue,
          child: TabBar(
            tabs: _tabs,
            controller: _tabController,
          ),
        ));
  }

}
