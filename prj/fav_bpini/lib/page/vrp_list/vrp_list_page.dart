import 'dart:io';

import 'package:favbpini/database/database.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/model/vrp_record.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:favbpini/widget/common_scaffold.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';

class VrpListPage extends StatefulWidget {
  @override
  VrpListPageState createState() => VrpListPageState();

  VrpListPage();
}

class VrpListPageState extends State<VrpListPage> {
  VRPType _typeFilter;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      onPressed: () async {
        var result = await showDialog<VRPType>(
          context: context,
          barrierDismissible: false, // dialog is dismissible with a tap on the barrier
          builder: (BuildContext context) {
            return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                title: Row(
                  children: [
                    Expanded(child: HeadingText('Filtrovat SPZ dle typu', fontSize: 18, noPadding: true)),
                    IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop())
                  ],
                ),
                content: Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFilterDialogRow(context, null, label: "Všechny záznamy"),
                      for (var type in VRPType.values) _buildFilterDialogRow(context, type),
                    ],
                  ),
                ));
          },
        );

        debugPrint("settings staet");
        setState(() {
          _typeFilter = result;
        });
      },
      child: Container(
        child: _buildVRPHistory(),
      ),
    );
  }

  Padding _buildFilterDialogRow(BuildContext context, VRPType type, {String label}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: type != null ? Colors.blueAccent : Colors.orange,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.of(context).pop(type),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  type != null ? type.getName() : label,
                  style: TextStyles.monserratStyle.copyWith(color: Colors.white),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVRPHistory() {
    return Expanded(
      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeadingText("Historie"),
          if (_typeFilter != null)
            HeadingText(_typeFilter.getName(), fontSize: 18,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: StreamBuilder<List<FoundVrpRecord>>(
                stream: Provider.of<Database>(context).watchAllRecords(type: _typeFilter),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      return FutureBuilder<String>(
                        future: Future<String>.delayed(Duration(milliseconds: 500), () {
                          return "Whatever";
                        }),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshotz) {
                          return snapshotz.hasData
                              ? ListView(padding: EdgeInsets.all(0), children: [
                                  for (FoundVrpRecord record in snapshot.data)
                                    _buildVRPRecordCard(
                                        VRPRecord(
                                            VRP(record.firstPart, record.secondPart, VRPType.values[record.type]),
                                            record.date,
                                            Position(longitude: record.longitude, latitude: record.latitude),
                                            record.address),
                                        record,
                                        context,
                                        snapshot)
                                ])
                              : ListView(padding: EdgeInsets.all(0), children: [for (var i = 0; i < 10; i++) _buildVRPRecordCardLoading()]);
                        },
                      );
                    } else {
                      return Center(child: Text("Nenalezen žádný záznam", style: Theme.of(context).textTheme.subhead));
                    }
                  } else {
                    return ListView(padding: EdgeInsets.all(0), children: [for (var i = 0; i < 10; i++) _buildVRPRecordCardLoading()]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVRPRecordCard(
      VRPRecord record, FoundVrpRecord dbItem, BuildContext context, AsyncSnapshot<List<FoundVrpRecord>> snapshot) {
    return Dismissible(
      key: Key(dbItem.toString()),
      background: Container(color: Colors.white30),
      onDismissed: (direction) async {
        var sourceImage = File(dbItem.sourceImagePath);
        if (await sourceImage.exists()) {
          sourceImage.delete();
          debugPrint("Deleted an image: ${sourceImage.path}");
        }
        Provider.of<Database>(context, listen: false).deleteEntry(dbItem);
        setState(() {
          snapshot.data.remove(dbItem);
        });
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 25, right: 25),
        child: Material(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () =>
                {Navigator.of(context).pushNamed("/found", arguments: VrpPreviewPageArguments(dbItem, edit: true))},
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        record.vrp.firstPart + " " + record.vrp.secondPart,
                        style: TextStyles.monserratStyle.copyWith(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Center(
                            child: Text(
                          record.date != null ? DateFormat('dd.MM.yyyy HH:mm').format(record.date) : "Nenalezeno",
                          style: TextStyles.monserratStyle.copyWith(fontSize: 12, color: Colors.white),
                        )))
                  ])),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      record.address,
                      style: TextStyle(color: Colors.white),
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

  Widget _buildVRPRecordCardLoading() {
    final tween = MultiTrackTween([
      Track("color1")
          .add(Duration(milliseconds: 500), ColorTween(begin: Colors.blueAccent, end: Colors.blueAccent[100])),
      Track("color2")
          .add(Duration(milliseconds: 500), ColorTween(begin: Colors.blueAccent[100], end: Colors.blueAccent))
    ]);
//

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Padding(
          padding: EdgeInsets.only(top: 10, left: 25, right: 25),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [animation["color1"], animation["color2"]])),
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 90,
                      height: 8,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                    ),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Center(
                          child: Container(
                        width: 70,
                        height: 6,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                      )))
                ])),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Container(
                      width: 150,
                      height: 5,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//  Widget _buildVRPList(List<VRPRecord> vrpRecordList) {
//
//  }
}
