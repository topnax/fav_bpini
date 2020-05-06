import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  /// Child widget that will be displayed in the body of the dialog
  final Widget child;

  /// Title of the dialog
  final String title;

  /// Padding of the content of the dialog
  final EdgeInsets padding;

  CustomDialog({this.child, this.title, this.padding = const EdgeInsets.all(25)});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        title: Row(
          children: [
            Expanded(child: HeadingText(title, fontSize: 18, noPadding: true)),
            IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop())
          ],
        ),
        content: child);
  }
}
