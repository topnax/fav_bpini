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
      final int uvIndex = uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
// Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
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

imglib.Image getBlackAndWhiteImage(imglib.Image image, {Rect area}) {
  if (area == null) {
    area = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  }
  debugPrint(
      "for bb of ${area.top.toString()}, ${area.left.toString()}, ${area.width.toString()},${area.height.toString()}");

  var grayScale = convertImageToGrayScale(image, area: area);
//  return grayScale;
  var bht = getBht(getGrayScaleHistogram(grayScale));
  debugPrint("bht is ${bht}");

  var bw = imglib.Image(area.width.toInt(), area.height.toInt());
  for (int i = 0; i < area.height.toInt(); i++) {
    for (int j = 0; j < area.width.toInt(); j++) {
      bw.setPixel(j, i, (grayScale.getPixel(j, i) & 0xFF) > bht ? 0xFFFFFFFF : 0xFF000000);
    }
  }

  return bw;
}

imglib.Image getImageCutout(imglib.Image image, Rect area) {
  var bw = imglib.Image(area.width.toInt(), area.height.toInt());
  for (int i = area.top.toInt(); i < area.top.toInt() + area.height.toInt(); i++) {
    for (int j = area.left.toInt(); j < area.left.toInt() + area.width.toInt(); j++) {
      bw.setPixel(j - area.left.toInt(), i - area.top.toInt(), (image.getPixel(j, i)));
    }
  }

  return bw;
}

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

int getBht(List<int> histogram, {int minCount = 5}) {
  var start = 0;
  while (histogram[start] < minCount && start < histogram.length - 1) {
    start++;
  }

  var end = histogram.length - 1;
  while (histogram[end] < minCount && end > 0 && end - 1 > start) {
    end--;
  }

  if (start == end) {
    debugPrint(start.toString());
  }

  //     h_c = int(round(np.average(np.linspace(0, 2 ** 8 - 1, n_bins), weights=hist)))
  int center = ((start + end) / 2).floor();
  debugPrint(
      "start=${start.toString()}, end=${end.toString()}, center=${center.toString()}, h.len=${histogram.length.toString()}");
  int weightLeft = start != center ? histogram.getRange(start, center).reduce((a, b) => a + b) : 0;
  int weightRight = center != end + 1 ? histogram.getRange(center, end + 1).reduce((a, b) => a + b) : 0;

  while (start < end) {
    if (weightLeft > weightRight) {
      weightLeft -= histogram[start];
      start++;
    } else {
      weightRight -= histogram[end];
      end--;
    }

    int newCenter = ((start + end) / 2).floor();

    if (newCenter < center) {
      weightLeft -= histogram[center];
      weightRight += histogram[center];
    } else if (newCenter > center) {
      weightLeft += histogram[center];
      weightRight -= histogram[center];
    }

    center = newCenter;
  }

  return center;
}
