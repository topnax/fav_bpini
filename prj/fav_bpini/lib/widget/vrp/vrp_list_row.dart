import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VrpListRow extends StatelessWidget {
  /// The VRP this row is displaying
  final VRP vrp;

  /// The address to be displayed
  final String address;

  /// The datetime at which the VRP was scanned
  final DateTime dateTime;

  /// The function to be executed once the user dismisses this row
  final Function onDismissed;

  /// The function to be executed once the user taps this row
  final Function onTap;

  /// Key of this row
  final Key key;

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  static TextStyle _dateTextStyle;
  static TextStyle _addressStyle;
  static TextStyle _vrpTitleStyle;

  VrpListRow(
      {@required this.key,
      @required this.vrp,
      @required this.address,
      @required this.dateTime,
      @required this.onDismissed,
      @required this.onTap}) {
    _dateTextStyle = TextStyles.montserratStyle
        .copyWith(fontSize: SizeConfig.blockSizeHorizontal * 3.5, color: Colors.white, fontWeight: FontWeight.w300);
    _addressStyle =
        TextStyle(color: Colors.white, fontSize: SizeConfig.blockSizeHorizontal * 3.6, fontWeight: FontWeight.w300);
    _vrpTitleStyle =
        TextStyles.montserratStyle.copyWith(fontSize: SizeConfig.blockSizeHorizontal * 5, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      background: Container(color: Colors.white30),
      onDismissed: onDismissed,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
        child: Material(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        vrp.firstPart + " " + vrp.secondPart,
                        style: _vrpTitleStyle,
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Center(
                            child: Text(
                          _dateFormat.format(dateTime),
                          style: _dateTextStyle,
                        )))
                  ])),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      address,
                      style: _addressStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
