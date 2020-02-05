import 'package:favbpini/bloc/vrp_preview/bloc.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VrpPreviewPage extends StatefulWidget {
  final VrpFinderResult result;

  @override
  VrpPreviewPageState createState() => VrpPreviewPageState(result);

  VrpPreviewPage(this.result);
}

class VrpPreviewPageState extends State<VrpPreviewPage> with SingleTickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();

  final VrpFinderResult _result;

  final DateTime _dateTimeScanned = DateTime.now();

  VrpPreviewBloc _bloc;

  VrpPreviewPageState(this._result) {
    _bloc = VrpPreviewBloc(_result.foundVrp, _addressController);
  }

  static const TextStyle _vrpStyle = TextStyle(fontSize: 60, fontFamily: "SfAtarianSystem");

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
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 36.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.black,
                  onPressed: () {},
                )
              ],
            ),
          ),
          Container(
            child: Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeadingText("Nová SPZ"),
                          Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "Naskenováno ${DateFormat('dd.MM.yyyy HH:mm').format(_dateTimeScanned)},",
                                        style: TextStyles.monserratStyle,
                                      )),
                                  Center(child: _buildVrp(_result.foundVrp.firstPart, _result.foundVrp.secondPart)),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      shape: new RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(18.0),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          '/finder',
                                        );
                                      },
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(right: 5.0),
                                            child: Icon(Icons.replay),
                                          ),
                                          Text("Znovu".toUpperCase(), style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          HeadingText(
                            "Adresa",
                            fontSize: 22,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                      hintText: "Adresa, kde byla SPZ naskenována",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.amber,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                BlocBuilder<VrpPreviewBloc, VrpPreviewState>(
                                  bloc: _bloc,
                                    builder: (BuildContext context, VrpPreviewState state) {
                                  if (!(state is PositionLoading)) {
                                    return IconButton(
                                        icon: Icon(Icons.location_on),
                                        color: Colors.blueAccent,
                                        onPressed: () => {_bloc.add(GetAddressByPosition())});
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                })
                              ],
                            ),
                          ),
                          HeadingText(
                            "Poznámka",
                            fontSize: 22,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Vlastní poznámka",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.amber,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(7.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/',
                            );
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Icon(Icons.close),
                              ),
                              Text("Zrušit", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(7.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/',
                            );
                          },
                          color: Colors.orange,
                          textColor: Colors.white,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Icon(Icons.done),
                              ),
                              Text("Uložit", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildVrp(String firstPart, String secondPart) {
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
      child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(firstPart, secondPart)),
    );
  }

  Widget _buildVrpContentRow(String firstPart, String secondPart) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              firstPart,
              style: _vrpStyle,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            Text(
              secondPart,
              style: _vrpStyle,
            )
          ],
        ),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.star_border,
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
              child: _buildVrpContentRow(firstPart, secondPart))
        ],
      ),
    );
  }
}
