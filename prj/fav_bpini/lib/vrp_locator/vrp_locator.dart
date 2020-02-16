import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/model/vrp.dart';

abstract class VrpFinder {
  Future<List<VrpFinderResult>> findVrpInImage(CameraImage image);
}

class VrpFinderResult {
  final VRP foundVrp;
  final Rect rect;
  final double wtb;
  final String meta;

  VrpFinderResult(this.foundVrp, this.wtb, this.meta, {this.rect});
}
