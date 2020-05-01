import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/utils/numbers.dart';
import 'package:favbpini/vrp_locator/validator/vrp_validator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class ClassicVehicleVrpValidator extends VrpValidator {
  static const VIP_DIFF_RATIO_UPPER_THRESHOLD = 0.7;
  static const VIP_DIFF_RATIO_LOWER_THRESHOLD = 0.55;
  static const CLASSIC_DIFF_RATIO_UPPER_THRESHOLD = 0.67;
  static const CLASSIC_DIFF_RATIO_LOWER_THRESHOLD = 0.51;
  static const ONE_LINE_OLD_SEPARATOR = "-";

  const ClassicVehicleVrpValidator();

  @override
  VRP validateVrp(TextBlock tb) {
    if (tb.lines.length == 1 && tb.lines[0].elements.length == 2) {
      String firstPart = tb.lines[0].elements[0].text;
      String secondPart = tb.lines[0].elements[1].text;

      if (secondPart.length == 5 && secondPart[4] == "|") {
        secondPart = secondPart.substring(0, 4);
      }

      // one line VRP
      if (firstPart.length == 3) {
        var el1 = tb.lines[0].elements[0].boundingBox;
        var el2 = tb.lines[0].elements[1].boundingBox;

        var diff = (el2.left + el2.width) - (el1.left + el1.width);

        var diffRatio = diff / tb.boundingBox.width;

        var diffRatioUpper = 0.0;
        var diffRatioLower = 20.0;

        var type;
        if (secondPart.length == 5) {
          type = VRPType.ONE_LINE_VIP;
          diffRatioUpper = VIP_DIFF_RATIO_UPPER_THRESHOLD;
          diffRatioLower = VIP_DIFF_RATIO_LOWER_THRESHOLD;
          if (tb.text.contains(ONE_LINE_OLD_SEPARATOR)) {
            type = VRPType.ONE_LINE_OLD;
          }
        } else if (secondPart.length == 4) {
          diffRatioUpper = CLASSIC_DIFF_RATIO_UPPER_THRESHOLD;
          diffRatioLower = CLASSIC_DIFF_RATIO_LOWER_THRESHOLD;
          type = VRPType.ONE_LINE_CLASSIC;
          if (tb.text[0] != "O" && !isDigit(tb.text, 0) && tb.text[0] != "E") {
            return null;
          }
          firstPart = tb.lines[0].elements[0].text;
          if (firstPart[1] == "8") {
            firstPart = firstPart.replaceRange(1, 2, "B");
          }
          if (firstPart[1] == "0") {
            firstPart = firstPart.replaceRange(1, 2, "U");
          }
        }

        if (diffRatio > diffRatioLower && diffRatio < diffRatioUpper) {
          return VRP(firstPart, secondPart, type);
        } else {
          log.e("threw away because of ratio of $diffRatio");
        }
      }
    }
    return null;
  }
}

class TwoLineVrpVehicleValidator extends VrpValidator {
  static const OTHER_DIFF_RATIO_UPPER_THRESHOLD = .06;
  static const BIKE_DIFF_RATIO_LOWER_THRESHOLD = 0.10;
  static const BIKE_DIFF_RATIO_UPPER_THRESHOLD = .25;

  const TwoLineVrpVehicleValidator();

  @override
  VRP validateVrp(TextBlock tb) {
    if (tb.lines.length == 2) {
      // check that two lines each contain a one element
      if (tb.lines[0].elements.length == 1 && tb.lines[1].elements.length == 1) {
        if (tb.lines[1].elements[0].text.length == 4) {
          if (tb.lines[0].elements[0].text.length == 3) {
            // OTHER TWO LINE
            var el1 = tb.lines[0].elements[0].boundingBox;
            var el2 = tb.lines[1].elements[0].boundingBox;

            var diff = ((el1.left) - (el2.left)).abs();

            var diffRatio = diff / tb.boundingBox.width;

            if (diffRatio < OTHER_DIFF_RATIO_UPPER_THRESHOLD) {
              return VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text, VRPType.TWO_LINE_OTHER);
            }
          } else if (tb.lines[0].elements[0].text.length == 2) {
            // BIKE VRP
            var el1 = tb.lines[0].elements[0].boundingBox;
            var el2 = tb.lines[1].elements[0].boundingBox;

            var diff = (el1.left) - (el2.left);

            var diffRatio = diff / tb.boundingBox.width;

            if (diffRatio > BIKE_DIFF_RATIO_LOWER_THRESHOLD && diffRatio < BIKE_DIFF_RATIO_UPPER_THRESHOLD) {
              return VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text, VRPType.TWO_LINE_BIKE);
            }
          }
        }
      }
    }
    return null;
  }
}
