import 'package:camera/camera.dart';
import "package:executorservices/executorservices.dart";
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/utils/numbers.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

const vrpWTBThreshold = 0.55;

class CameraImageTextBlocCarrier {
  final CameraImage image;
  final List<TextBlock> detectedBlocks;
  final bool checkBlackWhiteRatio;

  CameraImageTextBlocCarrier(this.image, this.detectedBlocks, this.checkBlackWhiteRatio);
}

class VrpFinderImpl implements VrpFinder {
  static const OCR_TIME_LIMIT = 700;
  static const INVALID_TO_VALID_CHAR_MAP = {"Q": "0", "O": "0"};

  static const INVALID_CHAR_SET = {"CH", "G", "W"};

  static const ONE_LINE_OLD_SEPARATOR = "-";

  final executorService = ExecutorService.newSingleExecutor();

  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image) async {
    var start = DateTime.now();
    debugPrint("doing ocr");
    List<TextBlock> detectedBlocks = await OcrManager.scanText(OcrManager.getFirebaseVisionImageFromCameraImage(image));

    var timeTookToOcr = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    debugPrint("got ocr #${detectedBlocks.length} ${timeTookToOcr}ms");

    start = DateTime.now();
    var results = await executorService.submitCallable(findVrpResultsFromCameraImage,
        CameraImageTextBlocCarrier(image, detectedBlocks, timeTookToOcr < OCR_TIME_LIMIT));
    debugPrint("got vrp in ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch}ms");

    return Future<List<VrpFinderResult>>.value(results);
  }
}

List<VrpFinderResult> findVrpResultsFromCameraImage(CameraImageTextBlocCarrier carrier) {
  CameraImage image = carrier.image;
  List<TextBlock> detectedBlocks = carrier.detectedBlocks;
  var img = convertCameraImage(image);

  return findVrpResultsFromImage(img, detectedBlocks, carrier.checkBlackWhiteRatio);
}

List<VrpFinderResult> findVrpResultsFromImage(
    imglib.Image img, List<TextBlock> detectedBlocks, bool computeBlackToWhiteRatio) {
  print("computeBWR " + computeBlackToWhiteRatio.toString());gd
  var results = detectedBlocks
      // filter text blocks that are within the image
      .where((tb) => _isRectangleWithinImage(tb.boundingBox, img.width, img.height))
      // map text blocks to results
      .map((tb) {
        for (var ch in VrpFinderImpl.INVALID_CHAR_SET) {
          if (tb.text.contains(ch)) {
            return null;
          }
        }

        if (tb.lines.length == 1) {
          // one line VRP
          if (tb.lines[0].elements.length == 2 && tb.lines[0].elements[0].text.length == 3) {
            var el1 = tb.lines[0].elements[0].boundingBox;
            var el2 = tb.lines[0].elements[1].boundingBox;

            var diff = (el2.left + el2.width) - (el1.left + el1.width);

            var diffRatio = diff / tb.boundingBox.width;

            var diffRatioUpper = 0.0;
            var diffRatioLower = 20.0;

            var type;

            if (tb.lines[0].elements[1].text.length == 5) {
              type = VRPType.ONE_LINE_VIP;
              diffRatioUpper = 0.7;
              diffRatioLower = 0.55;
              if (tb.text.contains(VrpFinderImpl.ONE_LINE_OLD_SEPARATOR)) {
                type = VRPType.ONE_LINE_OLD;
              }
            } else if (tb.lines[0].elements[1].text.length == 4) {
              diffRatioUpper = 0.65;
              diffRatioLower = 0.51;
              type = VRPType.ONE_LINE_CLASSIC;
              if (!isDigit(tb.text, 0)) {
                return null;
              }
            }

            if (diffRatio > diffRatioLower && diffRatio < diffRatioUpper) {
              var bwr = computeBlackToWhiteRatio
                  ? getBlackAndWhiteImage(img, area: tb.boundingBox).getWhiteBalance().toDouble()
                  : 256.0;

              return VrpFinderResult(VRP(tb.lines[0].elements[0].text, tb.lines[0].elements[1].text, type), bwr,
                  "diffRatio=${diff / tb.boundingBox.width}",
                  rect: tb.boundingBox, image: img);
            } else {
              return null;
            }
          }
        } else if (tb.lines.length == 2) {
          debugPrint("two lines");
          // check that two lines each contain a one element
          if (tb.lines[0].elements.length == 1 && tb.lines[1].elements.length == 1) {
            debugPrint("first condition");
            if (tb.lines[1].elements[0].text.length == 4) {
              debugPrint("second condition");
              if (tb.lines[0].elements[0].text.length == 3) {
                var el1 = tb.lines[0].elements[0].boundingBox;
                var el2 = tb.lines[1].elements[0].boundingBox;

                var diff = ((el1.left) - (el2.left)).abs();

                var diffRatio = diff / tb.boundingBox.width;

                debugPrint("truck $diffRatio ${tb.boundingBox.width}");
                debugPrint("${el1.left} ${el1.width}");
                debugPrint("${el2.left} ${el2.width}");
                debugPrint("${diffRatio}");
                if (diffRatio < .06) {
                  var bwr = computeBlackToWhiteRatio
                      ? getBlackAndWhiteImage(img, area: tb.boundingBox).getWhiteBalance().toDouble()
                      : 256.0;

                  return VrpFinderResult(
                      VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text, VRPType.TWO_LINE_OTHER),
                      bwr,
                      "diffRatio=${diffRatio}",
                      rect: tb.boundingBox,
                      image: img);
                }
              } else if (tb.lines[0].elements[0].text.length == 2) {
                var el1 = tb.lines[0].elements[0].boundingBox;
                var el2 = tb.lines[1].elements[0].boundingBox;

                var diff = (el1.left) - (el2.left);

                var diffRatio = diff / tb.boundingBox.width;

                debugPrint("moto $diffRatio ${tb.boundingBox.width}");
                debugPrint("${el1.left} ${el1.width}");
                debugPrint("${el2.left} ${el2.width}");
                if (diffRatio > 0.10 && diffRatio < .25) {
                  var bwr = computeBlackToWhiteRatio
                      ? getBlackAndWhiteImage(img, area: tb.boundingBox).getWhiteBalance().toDouble()
                      : 256.0;

                  return VrpFinderResult(
                      VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text, VRPType.TWO_LINE_BIKE),
                      bwr,
                      "diffRatio=${diffRatio}",
                      rect: tb.boundingBox,
                      image: img);
                }
              }
            }
          }
        }
        return null;
      })
      .where((result) => result != null && result.wtb > 120)
      .map((result) {
        var firstPart = result.foundVrp.firstPart;
        var secondPart = result.foundVrp.secondPart;
        VrpFinderImpl.INVALID_TO_VALID_CHAR_MAP.forEach((invalidChar, replacementChar) {
          firstPart = firstPart.replaceAll(invalidChar, replacementChar);
          secondPart = secondPart.replaceAll(invalidChar, replacementChar);
        });
        return VrpFinderResult(VRP(firstPart, secondPart, result.foundVrp.type), result.wtb, result.meta,
            rect: result.rect, image: result.image);
      })
      .toList();

  return results;
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
