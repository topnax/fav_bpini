import 'package:camera/camera.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

const vrpWTBThreshold = 0.55;

class VrpFinderImpl implements VrpFinder {
  Future<VrpFinderResult> findVrpInImage(CameraImage image) async {
    List<TextBlock> detectedBlocks = await OcrManager.scanText(image);
    print("about to find blocks");

    if (detectedBlocks.length > 0) {
      var img = convertCameraImage(image);

//      detectedBlocks.forEach((tb) => print("${getWhiteToBlackRatio(tb.boundingBox, img)} - ${tb.text}"));

      detectedBlocks = detectedBlocks.where((tb) {
        var wtb = getWhiteToBlackRatio(tb.boundingBox, img);
        print("${wtb} - ${tb.text} stop");
        return wtb > vrpWTBThreshold;
      }).toList();

      var results = findSuitableTextBlock(detectedBlocks);

      return Future<VrpFinderResult>.value(results);
    }

//    var result = VrpFinderResult(VRP("3P6", "6768"), rect: Rect.fromLTWH(10, 10, 50, 10));
    var result = null;

    return Future<VrpFinderResult>.value(null);
  }

  VrpFinderResult findSuitableTextBlock(List<TextBlock> textBlocks) {
    var results = textBlocks.where((tb) => tb.text.replaceAll(" ", "").length == 7).map((tb) {
      var plateText = tb.text.replaceAll(" ", "");
      return VrpFinderResult(VRP(plateText.substring(0, 3), plateText.substring(2, 6)), rect: tb.boundingBox);
    }).toList();
    if (results.length > 0) {
      return results[0];
    } else {
      return null;
    }
  }
}
