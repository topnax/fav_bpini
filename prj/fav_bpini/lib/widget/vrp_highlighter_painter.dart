import 'package:favbpini/vrp_locator/vrp_finder.dart';
import 'package:flutter/material.dart';

/// Used for debug purposes
class VrpHighlighterPainter extends CustomPainter {
  static const _latencyTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 8,
  );

  final Size imageSize;
  final List<VrpFinderResult> results;
  final int _timeTook;

  VrpHighlighterPainter(this.results, this.imageSize, this._timeTook);

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

      if (result.foundVrp == null) {
        p2.color = Color(0xAA0000).withOpacity(0.5);
      } else {
        p2.color = Color(0x00AA00).withOpacity(0.5);
      }

      var rect = Rect.fromLTWH(
          (result.rect.left - horizontalPadding) * size.height / imageSize.width,
          (result.rect.top - verticalPadding) * size.width / imageSize.height,
          (result.rect.width + horizontalPadding) * size.height / imageSize.width,
          (result.rect.height + verticalPadding) * size.width / imageSize.height);

      canvas.drawRect(rect, p2);
      var textPainter = TextPainter(
        text: TextSpan(text: result.wtbRatio.toString() + " - " + result.meta, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: rect.width,
      );

      canvas.drawRect(rect, p);

      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }
    var textPainter = TextPainter(
      text: TextSpan(text: "${_timeTook}ms", style: _latencyTextStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: 500,
    );
    textPainter.paint(canvas, Offset(20, 20));
  }

  @override
  bool shouldRepaint(VrpHighlighterPainter oldDelegate) {
    return oldDelegate.results != results || _timeTook != oldDelegate._timeTook;
  }
}
