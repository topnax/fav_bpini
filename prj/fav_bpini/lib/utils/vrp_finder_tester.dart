import 'dart:io';

import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/utils/image/image_wrappers.dart';
import 'package:favbpini/vrp_locator/vrp_finder_impl.dart';
import 'package:image/image.dart' as imglib;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class VrpFinderTester {
  Future<VrpFinderTesterResult> startTestInFolder(List<File> files) async {
    var dir = await getTemporaryDirectory();
    var tempFile = File(dir.path + '/temp.png');
    final impl = VrpFinderImpl();
    var total = 0;
    var totalAttempts = 0;
    var failure = 0;
    var angles = [0, -3, -2, -1, 1, 2, 3];
    var totalTime = 0;
    var results = List<VrpFinderTesterTestCaseResult>();
    for (var file in files) {
      var found = false;
      var foundIncorrect = false;
      var attempt = 0;
      var name = basenameWithoutExtension(file.path);
      var parts = name.split("_");
      var img = imglib.decodeImage(file.readAsBytesSync());
      for (var angle in angles) {
        log.e("trying angle $angle");
        attempt++;
        if (parts.length == 2) {
          var tempImg = angle != 0 ? imglib.copyRotate(img, angle) : img;
          tempFile.writeAsBytesSync(imglib.encodeJpg(tempImg));
          final im = FileImageWrapper(tempImg, tempFile.path);
          var start = DateTime.now();
          var result = await impl.findVrpInImage(im);
          totalTime += DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
          if (result != null) {
            if (parts[0] != result.foundVrp.firstPart || parts[1] != result.foundVrp.secondPart) {
              log.e(
                  "INCORRECT '${result.foundVrp.firstPart} ${result.foundVrp.secondPart}' instead of ${parts[0]} ${parts[1]}");
              foundIncorrect = true;
            } else {
              found = true;
            }
            if (found) {
              log.e("bht is: ${result.wtbRatio}");
            }
            results.add(VrpFinderTesterTestCaseResult(
                VRP(parts[0], parts[1], VRPType.ONE_LINE_CLASSIC), result.foundVrp, file.path));
            break;
          } else {
            log.e("did not find anything for instead of ${parts[0]} ${parts[1]}");
          }
        }
      }
      totalAttempts += attempt;
      if (!found) {
        failure++;
        log.e("FAILED TO RECOGNIZE VRP");
        if (!foundIncorrect) {
          results
              .add(VrpFinderTesterTestCaseResult(VRP(parts[0], parts[1], VRPType.ONE_LINE_CLASSIC), null, file.path));
        }
      } else {
        if (attempt > 1) {
          log.e("RECOGNIZED AFTER $attempt tries");
        }
      }
      total++;
    }
    log.i(
        "SUMMARY:\nFAILURE:$failure\nSUCCESS:${total - failure}\nACCURACY:${(total - failure) / total * 100}%\nTOTAL:$total\nTOTAL ATTEMPTS:${totalAttempts}\nATTEMPTS PER TEST CASE:${totalAttempts / total}\nTotal time:${totalTime}ms\nTime per record:${totalTime / totalAttempts}ms");
    return VrpFinderTesterResult(failure, total - failure, results, totalAttempts, totalTime);
  }
}

class VrpFinderTesterResult {
  final int failure;
  final int success;
  final int attempts;
  final int timeTook;
  final List<VrpFinderTesterTestCaseResult> testCases;

  VrpFinderTesterResult(this.failure, this.success, this.testCases, this.attempts, this.timeTook);
}

class VrpFinderTesterTestCaseResult {
  VRP expected;
  VRP found;
  String path;

  VrpFinderTesterTestCaseResult(this.expected, this.found, this.path);
}
