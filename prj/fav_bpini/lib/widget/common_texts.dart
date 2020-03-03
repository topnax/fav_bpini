import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle monserratStyle = TextStyle(fontFamily: "Montserrat");
}

class HeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool noPadding;

  HeadingText(this.text, {this.fontSize = 28, this.noPadding = false});

  @override
  Widget build(BuildContext context) {
    return !noPadding ? HeaderPadding(child: _buildText()) : _buildText();
  }

  Widget _buildText() {
    return Text(text, style: TextStyles.monserratStyle.copyWith(fontSize: fontSize));
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
