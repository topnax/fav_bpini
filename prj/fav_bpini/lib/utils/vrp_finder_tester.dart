import 'dart:io';

import 'package:favbpini/main.dart';
import 'package:favbpini/utils/image_wrappers.dart';
import 'package:favbpini/vrp_locator/vrp_finder_impl.dart';
import 'package:image/image.dart' as imglib;
import 'package:path/path.dart';

Future<void> startTestInFolder(List<File> files) async {
  final impl = VrpFinderImpl();
  for (var file in files) {
    var name = basenameWithoutExtension(file.path);
    var parts = name.split("_");
    if (parts.length == 2) {
      final im = FileImageWrapper(imglib.decodeImage(file.readAsBytesSync()), file.path);
      var result = await impl.findVrpInImage(im);
      if (result != null) {
        log.i("found '${result.foundVrp.firstPart} ${result.foundVrp.secondPart}'");
      } else {
        log.e("did not find anything");
      }
    }
  }
}
