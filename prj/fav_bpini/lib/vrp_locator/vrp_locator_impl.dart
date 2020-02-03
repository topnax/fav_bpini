import 'dart:math';

import 'package:camera/camera.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

const vrpWTBThreshold = 0.6;

class VrpFinderImpl implements VrpFinder {
  Future<VrpFinderResult> findVrpInImage(CameraImage image) async {
    List<TextBlock> detectedBlocks = await OcrManager.scanText(image);

    if (detectedBlocks.length > 0) {
      var img = convertCameraImage(image);
      detectedBlocks = detectedBlocks
          .where(
              (tb) =>
          getWhiteToBlackRatio(tb.boundingBox, img) > vrpWTBThreshold)
          .toList();
    }

    var result = VrpFinderResult(VRP("3P6","6768"), rect: Rect.fromLTWH(10,10, 50, 10));

    return Future<VrpFinderResult>.value(result);
  }

  TextBlock findSuitableTextBlocks(List<TextBlock> textBlocks) {

  }



}
