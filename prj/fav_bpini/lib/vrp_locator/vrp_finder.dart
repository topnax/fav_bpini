import 'dart:ui';

import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/utils/image/image_wrappers.dart';
import 'package:image/image.dart' as imglib;

abstract class VrpFinder {
  /// Finds a VRP in the given image
  Future<VrpFinderResult> findVrpInImage(ImageWrapper imageWrapper);
}

/// A record containing VRP and additional meta data
class VrpFinderResult {
  /// An attribute that contains the VRP ID
  final VRP foundVrp;

  /// A rectangle that surrounds the VRP in the image in which the VRP was recognized
  final Rect rect;

  /// White to black ratio of the area containing the VRP
  final double wtbRatio;

  /// Additional information about the found VRP
  final String meta;

  /// An image in which the VRP was found
  final imglib.Image image;

  /// A path to the file containing the source image
  String srcPath;

  VrpFinderResult(this.foundVrp, this.wtbRatio, this.meta, {this.rect, this.image, this.srcPath = ""});
}
