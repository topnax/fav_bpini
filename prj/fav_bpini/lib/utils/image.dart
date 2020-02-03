import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

imglib.Image convertCameraImage(CameraImage image) {
  int width = image.width;
  int height = image.height;
// imglib -> Image package from https://pub.dartlang.org/packages/image
  var img = imglib.Image(width, height); // Create Image buffer
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
// Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
// color: 0x FF  FF  FF  FF
//           A   B   G   R
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }
// Rotate 90 degrees to upright
  var img1 = imglib.copyRotate(img, 90);
  return img1;
}

double getWhiteToBlackRatio(Rect boundingBox, imglib.Image img) {
  int total = 0;
  int white = 0;
  for (int i = max(boundingBox.top.toInt(), 0);
      i < min(boundingBox.bottom.toInt(), img.height);
      i++) {
    for (int j = max(boundingBox.left.toInt(), 0);
        j < min(boundingBox.right.toInt(), img.width);
        j++) {
      var color = img.getPixel(j, i);
      int r = (color & 0xFF);
      int g = ((color >> 8) & 0xFF);
      int b = ((color >> 16) & 0xFF);
      var y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      white += y < 128 ? 0 : 1;
      total++;
    }
  }

  return (white.toDouble() / total.toDouble());

//  for (var textBlock in detectedBlocks) {
//    int total = 0;
//    int white = 0;
//    for (int i = max(textBlock.boundingBox.top.toInt(), 0);
//    i < min(textBlock.boundingBox.bottom.toInt(), img.height);
//    i++) {
//      for (int j = max(textBlock.boundingBox.left.toInt(), 0);
//      j < min(textBlock.boundingBox.right.toInt(), img.width);
//      j++) {
//        var color = img.getPixel(j, i);
//        int r = (color & 0xFF);
//        int g = ((color >> 8) & 0xFF);
//        int b = ((color >> 16) & 0xFF);
//        var y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
//        white += y < 128 ? 0 : 1;
//        total++;
//      }
//    }
//    debugPrint(textBlock.text +
//        " - ratio " +
//        (white.toDouble() / total.toDouble()).toString());
//  }
}
