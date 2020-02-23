import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:flutter/material.dart';

class CommonScaffold extends StatelessWidget {
  final Widget child;

  CommonScaffold({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 36.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.menu),
                      color: Theme.of(context).textTheme.body1.color,
                      onPressed: () {},
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
//            var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//            imglib.Image img = imglib.decodeJpg(File(image.path).readAsBytesSync());
//            var bw = getBlackAndWhiteImage(img, area: Rect.fromLTWH(150, 179, 120,35));
//            var file = await _localFile;
//            debugPrint("local file is: " + file.path);
//            file..writeAsBytesSync(imglib.encodePng(bw, level: 1));

            Navigator.of(context).pushNamed(
              '/finder', arguments: VrpFinderPageArguments()
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
                  icon: Icon(Icons.sort),
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
