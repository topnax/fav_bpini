import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:image/image.dart' as imglib;

abstract class VrpFinder {
  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image);
}

class VrpFinderResult {
  final VRP foundVrp;
  final Rect rect;
  final double wtb;
  final String meta;
  final imglib.Image image;
  String srcPath;

  VrpFinderResult(this.foundVrp, this.wtb, this.meta, {this.rect, this.image, this.srcPath = ""});
}
