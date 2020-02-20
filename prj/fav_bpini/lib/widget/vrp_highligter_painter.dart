import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

import '../vrp_locator/vrp_locator.dart';

class VrpHighlighterPainter extends CustomPainter {
  final Size imageSize;
  final List<VrpFinderResult> results;

  VrpHighlighterPainter(this.results, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();
    p.color = Colors.lightBlueAccent;
    p.strokeWidth = 2;
    p.style = PaintingStyle.stroke;

    Paint p2 = Paint();
    p2.color = Color(0xAA0000).withOpacity(0.5);
    p2.strokeWidth = 2;
    p2.style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );

    for (VrpFinderResult result in results) {

      var horizontalPadding = 0;
      var verticalPadding = 0;

      if (result.foundVrp == null ){
        p2.color =  Color(0xAA0000).withOpacity(0.5);
      } else {
        p2.color =  Color(0x00AA00).withOpacity(0.5);
      }

      var rect = Rect.fromLTWH(
          (result.rect.left - horizontalPadding) *
              size.height /
              imageSize.width,
          (result.rect.top - verticalPadding) * size.width / imageSize.height,
          (result.rect.width + horizontalPadding) * size.height / imageSize.width,
          (result.rect.height + verticalPadding) * size.width / imageSize.height);

      canvas.drawRect(rect, p2);
      final textPainter = TextPainter(
        text: TextSpan(text: result.wtb.toString() + " - " +result.meta, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: rect.width,
      );
//      debugPrint(
//          "${result.boundingBox.width} ${result.boundingBox.height} + ${imageSize.width} ${imageSize.height} + ${size.width} + ${size.height}");
      canvas.drawRect(rect, p);

      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }
//    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(VrpHighlighterPainter oldDelegate) {
    debugPrint(
        "shouldRepaint - " + (oldDelegate.results != results).toString());
    return oldDelegate.results != results;
  }
}
