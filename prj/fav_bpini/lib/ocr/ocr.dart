import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class OcrManager {

  static FirebaseVisionImage  getFirebaseVisionImageFromCameraImage(CameraImage image){
    /*
     * https://firebase.google.com/docs/ml-kit/android/recognize-text
     */

    final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
        rawFormat: image.format.raw,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        planeData: image.planes
            .map((currentPlane) => FirebaseVisionImagePlaneMetadata(
            bytesPerRow: currentPlane.bytesPerRow, height: currentPlane.height, width: currentPlane.width))
            .toList(),
        rotation: ImageRotation.rotation90);

    return FirebaseVisionImage.fromBytes(image.planes[0].bytes, metadata);
  }

  static Future<List<TextBlock>> scanText(FirebaseVisionImage visionImage) async {
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);


    return visionText?.blocks;
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  FirebaseVisionImageMetadata buildMetaData(CameraImage image) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: ImageRotation.rotation90,
      planeData: image.planes.map((Plane plane) {
        return FirebaseVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      }).toList(),
    );
  }
}
