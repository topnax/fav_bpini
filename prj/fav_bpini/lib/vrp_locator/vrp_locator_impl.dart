import 'package:camera/camera.dart';
import "package:executorservices/executorservices.dart";
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const vrpWTBThreshold = 0.55;

class Prepravka {
  final CameraImage image;
  final List<TextBlock> detectedBlocks;

  Prepravka(this.image, this.detectedBlocks);
}

class VrpFinderImpl implements VrpFinder {
  static const INVALID_TO_VALID_CHAR_MAP = {"Q": "0", "O": "0"};

  static const INVALID_CHAR_SET = {"CH", "G", "W"};

  final executorService = ExecutorService.newSingleExecutor();

  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image) async {
    List<TextBlock> detectedBlocks = await OcrManager.scanText(image);

//    var img = await compute(convertCameraImage, image);
//    return Future<List<VrpFinderResult>>.value(List<VrpFinderResult>());

    var img = executorService.submitCallable(findResults, Prepravka(image, detectedBlocks));
//    var img = await compute(findResults, Prepravka(image, detectedBlocks));

    return Future<List<VrpFinderResult>>.value(img);
  }
}

List<VrpFinderResult> findResults(Prepravka prepravka) {
  CameraImage image = prepravka.image;
  List<TextBlock> detectedBlocks = prepravka.detectedBlocks;
  var img = convertCameraImage(image);

//    return Future<List<VrpFinderResult>>.value(results);

  var results = detectedBlocks
      // filter text blocks that are within the image
      .where((tb) => _isRectangleWithinImage(tb.boundingBox, img.width, img.height))
      // map text blocks to results
      .map((tb) {
        for (var ch in VrpFinderImpl.INVALID_CHAR_SET){
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

            if (tb.lines[0].elements[1].text.length == 5) {
              diffRatioUpper = 0.7;
              diffRatioLower = 0.55;
            } else if (tb.lines[0].elements[1].text.length == 4) {
              diffRatioUpper = 0.65;
              diffRatioLower = 0.51;
            }

            if (diffRatio > diffRatioLower && diffRatio < diffRatioUpper) {
              var bw = getBlackAndWhiteImage(img, area: tb.boundingBox);

              return VrpFinderResult(VRP(tb.lines[0].elements[0].text, tb.lines[0].elements[1].text),
                  bw.getWhiteBalance().toDouble(), "diffRatio=${diff / tb.boundingBox.width}",
                  rect: tb.boundingBox, image: img);
            } else {
              return null;
//          return VrpFinderResult(
//              null, -1, "diffRatio=${diff / tb.boundingBox.width}",
//              rect: tb.boundingBox);
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
                  var bw = getBlackAndWhiteImage(img, area: tb.boundingBox);

                  return VrpFinderResult(VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text),
                      bw.getWhiteBalance().toDouble(), "diffRatio=${diffRatio}",
                      rect: tb.boundingBox, image: img);
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
                  var bw = getBlackAndWhiteImage(img, area: tb.boundingBox);

                  return VrpFinderResult(VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text),
                      bw.getWhiteBalance().toDouble(), "diffRatio=${diffRatio}",
                      rect: tb.boundingBox, image: img);
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
    return VrpFinderResult(VRP(firstPart, secondPart), result.wtb, result.meta,rect: result.rect, image: result.image);
  })
      .toList();

  return results;
}

class VrpFinderImpl2 implements VrpFinder {
  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image) async {
    var start = DateTime.now();
    List<TextBlock> detectedBlocks = await OcrManager.scanText(image);
    debugPrint("scanText took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");
    print("about to find blocks");
    start = DateTime.now();
    var img = convertCameraImage(image);
    debugPrint("convert image took:${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch)}ms");

    start = DateTime.now();

    var bw = getBlackAndWhiteImage(img);

//    file..writeAsBytesSync(imglib.encodePng(bw, level: 1));

    var results = detectedBlocks
        .where((tb) => _isRectangleWithinImage(tb.boundingBox, img.width, img.height))
        .map((tb) {
          return VrpFinderResult(
              VRP("", ""), getImageCutout(bw, tb.boundingBox).getWhiteBalance().toDouble(), "whole text{${tb.text}}",
              rect: tb.boundingBox);
        })
        .where((result) => result.wtb > 0)
        .toList();
    return Future<List<VrpFinderResult>>.value(results);
  }
}

bool _isRectangleWithinImage(Rect rect, int width, int height) {
  return rect.left >= 0 &&
      rect.top >= 0 &&
      rect.left + rect.width.toInt() < width &&
      rect.top + rect.height.toInt() < height;
}
