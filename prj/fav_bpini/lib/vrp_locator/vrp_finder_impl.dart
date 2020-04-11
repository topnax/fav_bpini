import 'dart:math' as m;

import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:favbpini/utils/image_wrappers.dart';
import 'package:favbpini/vrp_locator/validator/vrp_validators.dart';
import 'package:favbpini/vrp_locator/vrp_finder.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

const vrpWTBThreshold = 0.55;

class VrpFinderImpl implements VrpFinder {
  static const OCR_TIME_LIMIT_MS = 700;

  static const INVALID_TO_VALID_CHAR_MAP = {"Q": "0", "O": "0"};

  static const INVALID_CHAR_SET = {"CH", "G", "W", ",", "."};

  static const _VALIDATORS = [const ClassicVehicleVrpValidator(), const TwoLineVrpVehicleValidator()];

  Future<VrpFinderResult> findVrpInImage(ImageWrapper imageWrapper) async {
    var start = DateTime.now();

    // perform ocr which filters out text blocks that do not match VRP formats
    final vrpCandidates =
        await getVrpCandidates(imageWrapper.getFirebaseVisionImage(), imageWrapper.width, imageWrapper.height);

    var ocrTime = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    log.d("OCR finished and found #${vrpCandidates.length} possible VRPs, took:  ${ocrTime}ms");

    // further filter an image by thresholding only if the OCR took less than some time
    bool doThreshold = ocrTime < OCR_TIME_LIMIT_MS;

    for (final possibleVrp in vrpCandidates) {
      var start = DateTime.now();
      var img = imageWrapper.getImage();
      log.d(
          "getting imglib.Image took: ${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch).toString()}ms");
      VrpFinderResult result;

      if (!doThreshold) {
        result = VrpFinderResult(possibleVrp.vrp, vrpWTBThreshold, "found without having to perform wtb",
            rect: possibleVrp.textBlock.boundingBox, image: img);
      } else {
        start = DateTime.now();
        result = await findVrpByThreshold(img, vrpCandidates);
        log.d("threholding took: ${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch).toString()}");
      }

      if (result != null) {
        String firstPart, secondPart = "";
        VrpFinderImpl.INVALID_TO_VALID_CHAR_MAP.forEach((invalidChar, replacementChar) {
          firstPart = result.foundVrp.firstPart.replaceAll(invalidChar, replacementChar);
          secondPart = result.foundVrp.secondPart.replaceAll(invalidChar, replacementChar);
        });

        return VrpFinderResult(
            VRP(firstPart.toUpperCase(), secondPart.toUpperCase(), result.foundVrp.type), result.wtb, result.meta,
            rect: result.rect, image: result.image);
      }
    }
    return null;
  }

  Future<List<VrpCandidate>> getVrpCandidates(FirebaseVisionImage image, int width, int height) async {
    // find text blocks in an image
    final textBlocks = List<TextBlock>.from(await OcrHelper.scanText(image));

    log.d("OCR found ${textBlocks.length} blocks");

    final Offset imageCenter = Offset((width / 2).toDouble(), (height / 2).toDouble());

    var candidates = List<VrpCandidate>();

    textBlocks.forEach((tb) {
      // check whether the text block contains forbidden characters
      for (var ch in VrpFinderImpl.INVALID_CHAR_SET) {
        if (tb.text.contains(ch)) {
          return;
        }
      }

      // check this text block matches some VRP type
      for (var validator in _VALIDATORS) {
        var vrp = validator.validateVrp(tb);
        if (vrp != null) {
          candidates.add(VrpCandidate(vrp, tb));
        }
      }
    });

    // sort detected text blocks by their distance to the center of the image
    candidates.sort((a, b) => distanceBetweenOffsets(a.textBlock.boundingBox.center, imageCenter)
        .compareTo(distanceBetweenOffsets(b.textBlock.boundingBox.center, imageCenter)));

    return Future<List<VrpCandidate>>.value(candidates);
  }
}

Future<VrpFinderResult> findVrpByThreshold(imglib.Image img, List<VrpCandidate> candidates) async {
  var start = DateTime.now();
  if (candidates.isNotEmpty) {
    var result = candidates.firstWhere((tb) =>
        _isRectangleWithinImage(tb.textBlock.boundingBox, img.width, img.height) &&
        getBlackAndWhiteImage(getImageCutout(img, tb.textBlock.boundingBox)).getWhiteBalance() > 120);
    log.i("bwi filter took: ${(DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch).toString()}");

    if (result != null) {
      return Future.value(
          VrpFinderResult(result.vrp, 666, "found by BWT", rect: result.textBlock.boundingBox, image: img));
    }
  }
  return null;
}

class VrpCandidate {
  final VRP vrp;
  final TextBlock textBlock;

  VrpCandidate(this.vrp, this.textBlock);
}

double distanceBetweenOffsets(Offset a, Offset b) {
  return m.sqrt((m.pow(a.dx - b.dx, 2) - m.pow(a.dy - b.dy, 2)).abs());
}

bool _isRectangleWithinImage(Rect rect, int width, int height) {
  return rect.left >= 0 &&
      rect.top >= 0 &&
      rect.left + rect.width.toInt() < width &&
      rect.top + rect.height.toInt() < height;
}
