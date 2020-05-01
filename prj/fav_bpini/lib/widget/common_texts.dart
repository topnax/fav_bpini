import 'package:favbpini/utils/size_config.dart';
import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle montserratStyle = TextStyle(fontFamily: "Montserrat");
}

class HeadingText extends StatelessWidget {
  final String text;
  double fontSize;
  final bool noPadding;

  HeadingText(this.text, {this.fontSize, this.noPadding = false}) {
    if (fontSize == null) {
      fontSize = SizeConfig.blockSizeHorizontal * 7.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !noPadding ? HeaderPadding(child: _buildText()) : _buildText();
  }

  Widget _buildText() {
    return Text(text, style: TextStyles.montserratStyle.copyWith(fontSize: fontSize));
  }
}

class HeaderPadding extends StatelessWidget {
  final Widget child;

  HeaderPadding({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical, left: 25.0),
      child: child,
    );
  }
}
