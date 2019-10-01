import 'package:flutter/material.dart';

class VrpPreviewPage extends StatefulWidget {
  @override
  VrpPreviewPageState createState() => VrpPreviewPageState();
}

class VrpPreviewPageState extends State<VrpPreviewPage>
    with SingleTickerProviderStateMixin {
  TextStyle _vrpStyle = TextStyle(fontSize: 60, fontFamily: "SfAtarianSystem");

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.red, //                   <--- border color
        width: 5.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: _buildVrp("9H9", "7903")),
        ],
      ),
    );
  }

  Widget _buildVrp(String firstPart, String secondPart) {
    return Container(
      decoration: BoxDecoration(color:Colors.black, borderRadius: BorderRadius.circular(6)),
      child: Padding(
          padding: EdgeInsets.all(4),
          child: _buildVrpInner(firstPart, secondPart)),
    );
  }

  Widget _buildVrpContentRow(String firstPart, String secondPart) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            firstPart,
            style: _vrpStyle,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          Text(
            secondPart,
            style: _vrpStyle,
          )
        ],
      ),
    );
  }

  Widget _buildVrpInner(String firstPart, String secondPart) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[900]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 2),child: Column(children: <Widget>[Icon(Icons.star_border, color: Colors.yellow,),Padding(padding: EdgeInsets.symmetric(vertical: 8),),Text("CZ", style: TextStyle(color: Colors.white),)],),),

              ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
              padding: EdgeInsets.only(top: 0),
              child: _buildVrpContentRow(firstPart, secondPart))
        ],
      ),
    );
  }
}
