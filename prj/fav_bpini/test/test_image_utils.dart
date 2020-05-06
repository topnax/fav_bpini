import 'dart:math';

import 'package:favbpini/vrp_locator/vrp_finder_impl.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  test('Rectangle outside of an image check test', () {
    expect(isRectangleWithinImage(Rect.fromLTWH(0, 0, 199, 199), 200, 200), true);
    expect(isRectangleWithinImage(Rect.fromLTWH(2, 2, 199, 199), 200, 200), false);
    expect(isRectangleWithinImage(Rect.fromLTWH(-5, -10, 10, 10), 200, 200), false);
  });

  test('Distance between two vectors is sqrt((x1-x2)^2+(y1-y2)^2)', () {
    expect(distanceBetweenOffsets(Offset(0, 0), Offset(100, 100)), sqrt(20000));
    expect(distanceBetweenOffsets(Offset(100, 100), Offset(200, 200)), sqrt(20000));
    expect(distanceBetweenOffsets(Offset(200, 200), Offset(100, 100)), sqrt(20000));
    expect(distanceBetweenOffsets(Offset(200, 100), Offset(100, 200)), sqrt(20000));
    expect(distanceBetweenOffsets(Offset(100, 100), Offset(100, 100)), 0);
    expect(distanceBetweenOffsets(Offset(0, 10), Offset(20, 10)), sqrt(400));
  });
}
