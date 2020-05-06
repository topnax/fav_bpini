import 'package:favbpini/main.dart';

abstract class ThresholdFinder {
  int getThreshold(List<int> histogram, {int minCount = 5});
}

class BalancedHistogramThresholdFinder {
  ///
  int getThresholdUsingBHT(List<int> histogram, {int minCount = 5}) {
    var start = 0;
    while (histogram[start] < minCount && start < histogram.length - 1) {
      start++;
    }

    var end = histogram.length - 1;
    while (histogram[end] < minCount && end > 0 && end - 1 > start) {
      end--;
    }

    int center = ((start + end) / 2).floor();
    log.d(
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
}
