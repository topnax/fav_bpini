import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {

  TextBlock vrpBlock = null;

  @override
  MainPageState createState() => MainPageState(vrpBlock: vrpBlock);

  MainPage({vrpBlock});
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextBlock vrpBlock = null;
  MainPageState({vrpBlock}){
    _tabPages = <Widget>[
      VrpPreviewPage(vrpBlock: vrpBlock),
      Center(child: Icon(Icons.settings, size: 64.0, color: Colors.blue)),
    ];
    _tabs = <Tab>[
      Tab(icon: Icon(Icons.format_list_bulleted)),
      Tab(icon: Icon(Icons.settings)),
    ];
  }

  get versionNumber => 4;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _tabPages.length, vsync: this, initialIndex: 0);
  }

  var _tabPages;
  var _tabs;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("app_title")+ " vc"+ versionNumber.toString()),
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

  Widget _buildMainBody() {
    return Container(
        child: Center(
      child: Text("Welcome to VRP App"),
    ));
  }
}
