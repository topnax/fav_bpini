import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:flutter/material.dart';

class VrpPreview extends StatelessWidget {
  static TextStyle _vrpStyle =
      TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 11, fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle _vrpStyleSmaller =
      TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 10, fontWeight: FontWeight.w600, color: Colors.black);

  final VRP vrp;

  VrpPreview(this.vrp);

  @override
  Widget build(BuildContext context) {
    return _buildVrp(vrp);
  }

  Widget _buildVrp(VRP vrp) {
    if (vrp.type == VRPType.ONE_LINE_VIP) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(vrp.firstPart, vrp.secondPart, vip: true)),
      );
    } else if (vrp.type == VRPType.ONE_LINE_OLD) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(vrp.firstPart, vrp.secondPart, old: true)),
      );
    } else if (vrp.type == VRPType.TWO_LINE_BIKE || vrp.type == VRPType.TWO_LINE_OTHER) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(
            padding: EdgeInsets.all(4), child: _buildVrpInnerTwoRows(vrp.firstPart, vrp.secondPart, bike: true)),
      );
    } else {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(vrp.firstPart, vrp.secondPart)),
      );
    }
  }

  Widget _buildVrpContentRow(String firstPart, String secondPart, {vip = false, twoRows = false}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: !twoRows ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  firstPart,
                  style: vip ? _vrpStyleSmaller : _vrpStyle,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 3),
                ),
                if (!twoRows)
                  Text(
                    secondPart,
                    style: vip ? _vrpStyleSmaller : _vrpStyle,
                  )
              ],
            ),
          ),
          if (twoRows)
            Text(
              secondPart,
              style: vip ? _vrpStyleSmaller : _vrpStyle,
            ),
        ],
      ),
    );
  }

  Widget _buildVrpInner(String firstPart, String secondPart, {bool vip = false, old = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[900]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!old)
            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: <Widget>[
                    if (vip)
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                      )
                    else
                      Icon(
                        Icons.blur_circular,
                        color: Colors.yellow,
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    Text(
                      vip ? "VIP" : "CZ",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
              padding: EdgeInsets.only(top: 0),
              child: _buildVrpContentRow(firstPart, secondPart, vip: vip))
        ],
      ),
    );
  }

  Widget _buildVrpInnerTwoRows(String firstPart, String secondPart, {bool bike = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[900]),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.blur_circular,
                        color: Colors.yellow,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      Text(
                        "CZ",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.only(top: 0),
                  child: _buildVrpContentRow(firstPart, secondPart, twoRows: true))
            ],
          ),
        ],
      ),
    );
  }
}
