import 'dart:math' as m;

import 'package:camera/camera.dart';
import "package:executorservices/executorservices.dart";
import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/vrp_locator/validator/vrp_validator.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

const vrpWTBThreshold = 0.55;

class CameraImageTextBlocCarrier {
  final imglib.Image image;
  final List<PossibleVrp> possibleVrps;

  CameraImageTextBlocCarrier(this.image, this.possibleVrps);
}

class PossibleVrp {
  final VRP vrp;
  final TextBlock textBlock;

  PossibleVrp(this.vrp, this.textBlock);
}

double distanceBetweenOffsets(Offset a, Offset b) {
  return m.sqrt((m.pow(a.dx - b.dx, 2) - m.pow(a.dy - b.dy, 2)).abs());
}

class VrpFinderImpl implements VrpFinder {
  static const OCR_TIME_LIMIT = 700;
  static const INVALID_TO_VALID_CHAR_MAP = {"Q": "0", "O": "0"};

  static const INVALID_CHAR_SET = {"CH", "G", "W", ",", "."};

  static const ONE_LINE_OLD_SEPARATOR = "-";

  final executorService = ExecutorService.newSingleExecutor();

  Future<VrpFinderResult> findVrpInImage(CameraImage image) async {
    var start = DateTime.now();

    List<TextBlock> detected = await OcrManager.scanText(OcrManager.getFirebaseVisionImageFromCameraImage(image));

    var textBlocks = List<TextBlock>.from(detected);

    var timeTookToOcr = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    log.d("got ocr #${textBlocks.length} ${timeTookToOcr}ms");

    final _validators = [ClassicVehicleVrpValidator(), TwoLineVrpVehicleValidator()];

    final Offset imageCenter = Offset((image.height / 2).toDouble(), (image.width / 2).toDouble());

    bool deepScan = timeTookToOcr < OCR_TIME_LIMIT;
//    deepScan = true;

    var possibleVrps = List<PossibleVrp>();
    textBlocks.forEach((tb) {
      var foundInvalid = false;
      for (var ch in VrpFinderImpl.INVALID_CHAR_SET) {
        if (tb.text.contains(ch)) {
          foundInvalid = true;
        }
      }

      if (!foundInvalid) {
        for (var validator in _validators) {
          var vrp = validator.validateVrp(tb);
          if (vrp != null) {
            possibleVrps.add(PossibleVrp(vrp, tb));
          }
        }
      }
    });

    // sort detected text blocks by their distance to the center of the image
    possibleVrps.sort((a, b) => distanceBetweenOffsets(a.textBlock.boundingBox.center, imageCenter)
        .compareTo(distanceBetweenOffsets(b.textBlock.boundingBox.center, imageCenter)));

    VrpFinderResult result;
    if (possibleVrps.length > 0) {
      start = DateTime.now();
      var img = convertCameraImage(image);
//      var img = await executorService.submitCallable(convertCameraImage, image);

      log.d(
          "convertCameraImageTook: ${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch).toString()}");

      if (!deepScan) {
        result = VrpFinderResult(possibleVrps[0].vrp, vrpWTBThreshold, "found without having to perform wtb",
            rect: possibleVrps[0].textBlock.boundingBox, image: img);
      } else {
        start = DateTime.now();
        result = await findVrpResultsFromImage(img, possibleVrps);
//        result = await executorService.submitCallable(
//            findVrpResultsFromCameraImage, CameraImageTextBlocCarrier(img, possibleVrps));
        log.d("deep scan took: ${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch).toString()}");
      }

      var firstPart, secondPart = "";
      VrpFinderImpl.INVALID_TO_VALID_CHAR_MAP.forEach((invalidChar, replacementChar) {
        firstPart = result.foundVrp.firstPart.replaceAll(invalidChar, replacementChar);
        secondPart = result.foundVrp.secondPart.replaceAll(invalidChar, replacementChar);
      });

      return VrpFinderResult(VRP(firstPart, secondPart, result.foundVrp.type), result.wtb, result.meta,
          rect: result.rect, image: result.image);
    }

    return null;
  }
}
//
//VrpFinderResult findVrpResultsFromCameraImage(CameraImageTextBlocCarrier carrier) {
//  return findVrpResultsFromImage(carrier.image, carrier.possibleVrps);
//}

Future<VrpFinderResult> findVrpResultsFromImage(imglib.Image img, List<PossibleVrp> possibleVrps) async {
  var start = DateTime.now();
  var result = possibleVrps.firstWhere((tb) =>
      _isRectangleWithinImage(tb.textBlock.boundingBox, img.width, img.height) &&
      getBlackAndWhiteImage(getImageCutout(img, tb.textBlock.boundingBox)).getWhiteBalance() > 120);
  log.i("bwi filter took: ${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch).toString()}");

  if (result != null) {
    return Future.value(
        VrpFinderResult(result.vrp, 666, "found by BWT", rect: result.textBlock.boundingBox, image: img));
  }
  return null;
}
//
//class VrpFinderImpl2 implements VrpFinder {
//  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image) async {
//    var start = DateTime.now();
//    List<TextBlock> detectedBlocks = await OcrManager.scanText(image);
//    debugPrint("scanText took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");
//    print("about to find blocks");
//    start = DateTime.now();
//    var img = convertCameraImage(image);
//    debugPrint("convert image took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");
//
//    start = DateTime.now();
//
//    var bw = getBlackAndWhiteImage(img);
//
////    file..writeAsBytesSync(imglib.encodePng(bw, level: 1));
//
//    var results = detectedBlocks
//        .where((tb) => _isRectangleWithinImage(tb.boundingBox, img.width, img.height))
//        .map((tb) {
//          return VrpFinderResult(
//              VRP("", ""), getImageCutout(bw, tb.boundingBox).getWhiteBalance().toDouble(), "whole text{${tb.text}}",
//              rect: tb.boundingBox);
//        })
//        .where((result) => result.wtb > 0)
//        .toList();
//    return Future<List<VrpFinderResult>>.value(results);
//  }
//}

bool _isRectangleWithinImage(Rect rect, int width, int height) {
  return rect.left >= 0 &&
      rect.top >= 0 &&
      rect.left + rect.width.toInt() < width &&
      rect.top + rect.height.toInt() < height;
}
