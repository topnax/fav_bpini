import 'dart:io';

import 'package:favbpini/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';


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
                padding: const EdgeInsets.symmetric(horizontal:12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.menu),
                      color: Colors.black,
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
            var image = await ImagePicker.pickImage(source: ImageSource.gallery);
            imglib.Image img = imglib.decodeJpg(File(image.path).readAsBytesSync());
            var bw = getBlackAndWhiteImage(img);
            var file = await _localFile;
            debugPrint("local file is: " + file.path);
            file..writeAsBytesSync(imglib.encodePng(bw, level: 1));

//            Navigator.of(context).pushNamed(
//              '/finder',
//            );
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

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();

  return directory.path;
}
Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/test_${DateTime.now().millisecondsSinceEpoch}.png');
}



