import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final String title;

  CustomDialog({this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        title: Row(
          children: [
            Expanded(child: HeadingText(title, fontSize: 18, noPadding: true)),
            IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop())
          ],
        ),
        content: Padding(padding: EdgeInsets.only(left: 25, right: 25), child: child));
  }
}
