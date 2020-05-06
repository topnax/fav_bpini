import 'dart:math' hide log;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/main.dart';
import 'package:favbpini/utils/image/threshold_finder.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

/// A method that converts a [CameraImage] in format YUV420 to [imglib.Image] image
imglib.Image convertCameraImageYuv420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  const aa = 1436 / 1024;
  const bb = 46549 / 131072;
  const cc = 1814 / 1024;
  const dd = 93604 / 131072;
  var img = imglib.Image(width, height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex = uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];

      // calculate each color's intensity
      int r = (yp + vp * aa - 179).round().clamp(0, 255);
      int g = (yp - up * bb + 44 - vp * dd + 91).round().clamp(0, 255);
      int b = (yp + up * cc - 227).round().clamp(0, 255);
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }
  // Rotate 90 degrees to upright
  var rotated = imglib.copyRotate(img, 90);
  return rotated;
}

/// A method that converts a [CameraImage] in format BGRA (iOS devices) to [imglib.Image] image. Not tested on an iOS device.
imglib.Image convertCameraImageBgra8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

/// Calculates the black and white ratio in an image in the given bounding box
double getWhiteToBlackRatio(Rect boundingBox, imglib.Image img) {
  int total = 0;
  int white = 0;
  for (int i = max(boundingBox.top.toInt(), 0); i < min(boundingBox.bottom.toInt(), img.height); i++) {
    for (int j = max(boundingBox.left.toInt(), 0); j < min(boundingBox.right.toInt(), img.width); j++) {
      var color = img.getPixel(j, i);
      int r = (color & 0xFF);
      int g = ((color >> 8) & 0xFF);
      int b = ((color >> 16) & 0xFF);
      var y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      white += y < 200 ? 0 : 1;
      total++;
    }
  }

  return (white.toDouble() / total.toDouble());
}

/// Converts the given image to grayscale
imglib.Image convertImageToGrayScale(imglib.Image image, {Rect area}) {
  if (area == null) {
    area = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  }

  imglib.Image grayScaleImage = imglib.Image(area.width.toInt(), area.height.toInt());
  for (int i = area.top.toInt(); i < area.top.toInt() + area.height.toInt(); i++) {
    for (int j = area.left.toInt(); j < area.left.toInt() + area.width.toInt(); j++) {
      var color = image.getPixel(j, i);
      int r = (color & 0xFF);
      int g = ((color >> 8) & 0xFF);
      int b = ((color >> 16) & 0xFF);
      var y = (0.2126 * r + 0.7152 * g + 0.0722 * b).toInt();
      var newColor = y;
      newColor += (y << 8);
      newColor += (y << 16);
      newColor += (0xFF << 24);

      grayScaleImage.setPixel(j - area.left.toInt(), i - area.top.toInt(), newColor);
    }
  }

  return grayScaleImage;
}

/// Converts the given image to black and white color scheme. This method uses the image's histogram to find the optimal
/// threshold to binarize the image.
Future<imglib.Image> getBlackAndWhiteImage(imglib.Image image, {Rect area}) async {
  var start = DateTime.now();
  if (area == null) {
    area = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  }

  // convert the image to gray scale
  var grayScale = convertImageToGrayScale(image, area: area);
  // automatically find the threshold
  var threshold = BalancedHistogramThresholdFinder().getThresholdUsingBHT(getGrayScaleHistogram(grayScale));

  log.i("for area ${area.toString()}");
  log.i("got bht:$threshold");

  var bw = imglib.Image(area.width.toInt(), area.height.toInt());
  for (int i = 0; i < area.height.toInt(); i++) {
    for (int j = 0; j < area.width.toInt(); j++) {
      bw.setPixel(j, i, (grayScale.getPixel(j, i) & 0xFF) > threshold ? 0xFFFFFFFF : 0xFF000000);
    }
  }

  log.i("getbwi took: ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch}ms");
  return bw;
}

/// Crops an image
imglib.Image cropImage(imglib.Image image, Rect area) {
  var bw = imglib.Image(area.width.toInt(), area.height.toInt());
  for (int i = area.top.toInt(); i < area.top.toInt() + area.height.toInt(); i++) {
    for (int j = area.left.toInt(); j < area.left.toInt() + area.width.toInt(); j++) {
      bw.setPixel(j - area.left.toInt(), i - area.top.toInt(), (image.getPixel(j, i)));
    }
  }

  return bw;
}

/// Returns a histogram of the given image
List<int> getGrayScaleHistogram(imglib.Image image) {
  List<int> histogram = List(255);
  for (int i = 0; i < histogram.length; i++) {
    histogram[i] = 0;
  }

  for (int i = 0; i < image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      histogram[image.getPixel(j, i) & 0xFF]++;
    }
  }

  return histogram;
}
