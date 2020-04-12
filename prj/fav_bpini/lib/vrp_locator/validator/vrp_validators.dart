import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/utils/numbers.dart';
import 'package:favbpini/vrp_locator/validator/vrp_validator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class ClassicVehicleVrpValidator extends VrpValidator {
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
          diffRatioUpper = 0.7;
          diffRatioLower = 0.55;
          if (tb.text.contains(ONE_LINE_OLD_SEPARATOR)) {
            type = VRPType.ONE_LINE_OLD;
          }
        } else if (secondPart.length == 4) {
          diffRatioUpper = 0.67;
          diffRatioLower = 0.51;
          type = VRPType.ONE_LINE_CLASSIC;
          if (tb.text[0] != "O" && !isDigit(tb.text, 0)) {
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
  const TwoLineVrpVehicleValidator();

  @override
  VRP validateVrp(TextBlock tb) {
    if (tb.lines.length == 2) {
      // check that two lines each contain a one element
      if (tb.lines[0].elements.length == 1 && tb.lines[1].elements.length == 1) {
        if (tb.lines[1].elements[0].text.length == 4) {
          if (tb.lines[0].elements[0].text.length == 3) {
            var el1 = tb.lines[0].elements[0].boundingBox;
            var el2 = tb.lines[1].elements[0].boundingBox;

            var diff = ((el1.left) - (el2.left)).abs();

            var diffRatio = diff / tb.boundingBox.width;

            if (diffRatio < .06) {
              return VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text, VRPType.TWO_LINE_OTHER);
            }
          } else if (tb.lines[0].elements[0].text.length == 2) {
            var el1 = tb.lines[0].elements[0].boundingBox;
            var el2 = tb.lines[1].elements[0].boundingBox;

            var diff = (el1.left) - (el2.left);

            var diffRatio = diff / tb.boundingBox.width;

            if (diffRatio > 0.10 && diffRatio < .25) {
              return VRP(tb.lines[0].elements[0].text, tb.lines[1].elements[0].text, VRPType.TWO_LINE_BIKE);
            }
          }
        }
      }
    }
    return null;
  }
}
