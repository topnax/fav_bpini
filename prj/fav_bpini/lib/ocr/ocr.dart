import 'package:camera/camera.dart';
import 'package:favbpini/main.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OcrHelper {
  /// Scans the text and returns a [Future] containing a collection of found text blocks
  static Future<List<TextBlock>> scanText(FirebaseVisionImage visionImage) async {
    log.d("starting OCR...");

    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

    VisionText visionText;
    try {
      var start = DateTime.now();
      visionText = await textRecognizer.processImage(visionImage);
      log.i("ocr finished, took  ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch}ms");
    } catch (e) {
      log.e("got ${e.toString()} during processing of image");
    } finally {
      textRecognizer.close();
    }
    return visionText?.blocks;
  }

  /// Converts a [CameraImage] to [FirebaseVisionImage]
  static FirebaseVisionImage getFirebaseVisionImageFromCameraImage(CameraImage image) {
    final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
        rawFormat: image.format.raw,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        planeData: image.planes
            .map((currentPlane) => FirebaseVisionImagePlaneMetadata(
                bytesPerRow: currentPlane.bytesPerRow, height: currentPlane.height, width: currentPlane.width))
            .toList(),
        rotation: ImageRotation.rotation90);

    var allBytes = WriteBuffer();
    allBytes.putUint8List(image.planes[0].bytes);
    allBytes.putUint8List(image.planes[1].bytes);
    allBytes.putUint8List(image.planes[2].bytes);

    var allPlanes = allBytes.done().buffer.asUint8List();

    return FirebaseVisionImage.fromBytes(allPlanes, metadata);
  }
}
