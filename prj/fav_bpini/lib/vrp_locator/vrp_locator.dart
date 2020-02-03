import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/model/vrp.dart';

abstract class VrpFinder {
  Future<VrpFinderResult>findVrpInImage(CameraImage image);
}

class VrpFinderResult {
  final VRP foundVrp;
  final Rect rect;

  VrpFinderResult(this.foundVrp, {this.rect});
}
