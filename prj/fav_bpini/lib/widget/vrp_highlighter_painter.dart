import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class VrpHighlighterPainter extends CustomPainter {
  final Size imageSize;
  final List<TextBlock> textBlocks;

  VrpHighlighterPainter(this.textBlocks, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();
    p.color = Colors.red;
    p.strokeWidth = 2;
    p.style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.blue,
      fontSize: 14,
    );

    for (TextBlock textBlock in textBlocks) {
      var rect = Rect.fromLTWH(
          textBlock.boundingBox.left * size.width / imageSize.width,
          textBlock.boundingBox.top * size.height / imageSize.height,
          textBlock.boundingBox.width * size.width / imageSize.width,
          textBlock.boundingBox.height * size.height / imageSize.height);

//      final textPainter = TextPainter(
//        text: TextSpan(text: textBlock.text, style: textStyle),
//        textDirection: TextDirection.ltr,
//      );
//      textPainter.layout(
//        minWidth: rect.width,
//        maxWidth: rect.height,
//      );
      debugPrint("${textBlock.boundingBox.width} ${textBlock.boundingBox.width} + ${imageSize.width} ${imageSize.height} + ${size.width} + ${size.height}");
      canvas.drawRect(rect, p);
//      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }
    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(VrpHighlighterPainter oldDelegate) {
    debugPrint(
        "shouldRepaint - " + (oldDelegate.textBlocks != textBlocks).toString());
    return oldDelegate.textBlocks != textBlocks;
  }
}
