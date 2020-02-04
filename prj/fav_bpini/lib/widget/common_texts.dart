import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle monserratStyle = TextStyle(fontFamily: "Montserrat");
}

class HeadingText extends StatelessWidget {
  final String text;
  final double fontSize;

  HeadingText(this.text, {this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return HeaderPadding(child: Text(text, style: TextStyles.monserratStyle.copyWith(fontSize: fontSize)));
  }
}

class HeaderPadding extends StatelessWidget {
  final Widget child;

  HeaderPadding({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 25.0),
      child: child,
    );
  }
}
