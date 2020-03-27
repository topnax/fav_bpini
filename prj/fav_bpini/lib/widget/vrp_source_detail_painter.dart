import 'dart:ui';

import 'package:flutter/material.dart';

class VrpSourceDetailPainter extends CustomPainter {
  final Rect _highlightedArea;
  final Size _imageSize;

  VrpSourceDetailPainter(this._highlightedArea, this._imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();
    p.style = PaintingStyle.fill;

    p.color = Colors.black54;
    var screen = Rect.fromLTWH(0, 0, size.width, size.height);
    var widthRatio = size.width / _imageSize.width;
    var heightRatio = size.height / _imageSize.height;

    // clip the whole screen
    canvas.clipRect(screen, clipOp: ClipOp.intersect);

    // exclude highlighted area
    canvas.clipRect(
        Rect.fromLTWH(_highlightedArea.left * widthRatio, _highlightedArea.top * heightRatio,
            _highlightedArea.width * widthRatio, _highlightedArea.height * heightRatio),
        clipOp: ClipOp.difference);

    // draw over the whole screen
    canvas.drawRect(screen, p);

//
//    p.color = Colors.white;
//    p.blendMode = BlendMode.srcOver;
//
//
//
//    canvas.clipRect(rect)
//
//
//
//    canvas.drawRect(
//        Rect.fromLTWH(_highlightedArea.left * widthRatio, _highlightedArea.top * heightRatio,
//            _highlightedArea.width * widthRatio, _highlightedArea.height * heightRatio),
//        p);
  }

  @override
  bool shouldRepaint(VrpSourceDetailPainter oldDelegate) {
    return _highlightedArea != oldDelegate._highlightedArea;
  }
}
