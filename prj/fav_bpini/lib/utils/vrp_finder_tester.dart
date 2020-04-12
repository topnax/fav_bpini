import 'dart:io';

import 'package:favbpini/main.dart';
import 'package:favbpini/utils/image_wrappers.dart';
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
    for (var file in files) {
      var found = false;
      var attempt = 0;
      var name = basenameWithoutExtension(file.path);
      var parts = name.split("_");
      var img = imglib.decodeImage(file.readAsBytesSync());
      for (var angle in angles) {
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
            } else {
              attempt++;
              found = true;
              break;
            }
            break;
          } else {
            log.e("did not find anything for instead of ${parts[0]} ${parts[1]}");
          }
          attempt++;
        }
      }
      totalAttempts += attempt;
      if (!found) {
        failure++;
        log.e("FAILED TO RECOGNIZE VRP");
      } else {
        if (attempt > 0) {
          log.e("RECOGNIZED AFTER $attempt tries");
        }
      }
      total++;
    }
    log.i(
        "SUMMARY:\nFAILURE:$failure\nSUCCESS:${total - failure}\nACCURACY:${(total - failure) / total * 100}%\nTOTAL:$total\nTOTAL ATTEMPTS:${totalAttempts}\nATTEMPTS PER TEST CASE:${totalAttempts / total}\nTotal time:${totalTime}ms\nTime per record:${totalTime / totalAttempts}ms");
    return VrpFinderTesterResult(failure, total - failure, total, totalAttempts, totalTime);
  }
}

class VrpFinderTesterResult {
  final int failure;
  final int success;
  final int testCases;
  final int attempts;
  final int timeTook;

  VrpFinderTesterResult(this.failure, this.success, this.testCases, this.attempts, this.timeTook);
}
