import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:flutter/material.dart';

/// a reusable [Scaffold] widget
class CommonScaffold extends StatelessWidget {
  final Widget child;
  final Function onLeftButtonPressed;
  final Function onRightButtonPressed;
  final Widget rightButtonHint;

  CommonScaffold({@required this.child, this.onLeftButtonPressed, this.onRightButtonPressed, this.rightButtonHint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + SizeConfig.safeBlockVertical * 2.5),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.settings),
                      iconSize: SizeConfig.blockSizeHorizontal * 7,
                      color: Theme.of(context).textTheme.body1.color,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/settings");
                      },
                    )
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context).pushNamed('/finder', arguments: VrpFinderPageArguments());
          },
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
                  icon: Icon(Icons.filter_list),
                  color: Colors.white,
                  onPressed: onLeftButtonPressed,
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.sort),
                      color: Colors.white,
                      onPressed: onRightButtonPressed,
                    ),
                    if (rightButtonHint != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: rightButtonHint,
                      ),
                  ],
                ),
              ],
            ),
            color: Colors.blueAccent,
            shape: CircularNotchedRectangle()));
  }
}
