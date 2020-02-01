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
    p.style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );

    for (TextBlock textBlock in textBlocks) {
      var padding = 0.05;

      var horizontalPadding = imageSize.width * padding;
      var verticalPadding = imageSize.height * padding;

      var rect = Rect.fromLTWH(
          (textBlock.boundingBox.left - horizontalPadding) *
              size.height /
              imageSize.width,
          (textBlock.boundingBox.top - verticalPadding) * size.width / imageSize.height,
          (textBlock.boundingBox.width + horizontalPadding) * size.height / imageSize.width,
          (textBlock.boundingBox.height + verticalPadding) * size.width / imageSize.height);

      final textPainter = TextPainter(
        text: TextSpan(text: textBlock.text, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: rect.width,
      );
      debugPrint(
          "${textBlock.boundingBox.width} ${textBlock.boundingBox.height} + ${imageSize.width} ${imageSize.height} + ${size.width} + ${size.height}");
      canvas.drawRect(rect, p);
      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }
//    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(VrpHighlighterPainter oldDelegate) {
    debugPrint(
        "shouldRepaint - " + (oldDelegate.textBlocks != textBlocks).toString());
    return oldDelegate.textBlocks != textBlocks;
  }
}
