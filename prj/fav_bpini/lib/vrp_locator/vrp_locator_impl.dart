import 'dart:io';

import 'package:camera/camera.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:image/image.dart' as imglib;
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const vrpWTBThreshold = 0.55;

class VrpFinderImpl implements VrpFinder {
  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image) async {
    var start = DateTime.now();
    List<TextBlock> detectedBlocks = await OcrManager.scanText(image);
    debugPrint("scanText took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");
    print("about to find blocks");
    start = DateTime.now();
    var img = convertCameraImage(image);
    debugPrint("convert image took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");

    var results = detectedBlocks.map((tb) {

      var start = DateTime.now();
      var bw = getBlackAndWhiteImage(img, area: tb.boundingBox);
      debugPrint("getBlackAndWhite took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");

//      var file = await _localFile;
//      debugPrint("local file is: " + file.path);
//      file..writeAsBytesSync(imglib.encodePng(bw, level: 1));

      var wtb = getWhiteToBlackRatio(tb.boundingBox, img);
      return VrpFinderResult(VRP("", ""), bw.getWhiteBalance().toDouble(),
          "whole text{${tb.text}}, line count: ${tb.lines.length}, 1st line element cound: ${tb.lines[0].elements.length}", rect: tb.boundingBox);
    }).toList();
    return Future<List<VrpFinderResult>>.value(results);
//
//    if (detectedBlocks.length > 0) {
//      var img = convertCameraImage(image
//      );
//
////      detectedBlocks.forEach((tb) => print("${getWhiteToBlackRatio(tb.boundingBox, img)} - ${tb.text}"));
//
//      detectedBlocks = detectedBlocks.where((tb) {
//        var wtb = getWhiteToBlackRatio(tb.boundingBox, img
//        );
//        print("${wtb} - ${tb.text} stop"
//        );
//        return wtb > vrpWTBThreshold;
//      }
//      ).toList();
//
//      var results = findSuitableTextBlock(detectedBlocks
//      );
//
//      return results
  }

//    var result = VrpFinderResult(VRP("3P6", "6768"), rect: Rect.fromLTWH(10, 10, 50, 10));
//  var result = null;
//
//  return
//
//  Future<VrpFinderResult>
//
//      .
//
//  value
//
//  (
//
//  null
//
//  );
}

//VrpFinderResult findSuitableTextBlock(List<TextBlock> textBlocks) {
//  var results = textBlocks.where((tb) =>
//  tb.text
//      .replaceAll(" ", ""
//  )
//      .length == 7
//  ).map((tb) {
//    var plateText = tb.text.replaceAll(" ", ""
//    );
//    return VrpFinderResult(VRP(plateText.substring(0, 3
//    ), plateText.substring(2, 6
//    )
//    ), rect: tb.boundingBox
//    );
//  }
//  ).toList();
//  if (results.length > 0) {
//    return results[0];
//  } else {
//    return null;
//  }
//}}

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/test_${DateTime.now().millisecondsSinceEpoch}.png');
}
