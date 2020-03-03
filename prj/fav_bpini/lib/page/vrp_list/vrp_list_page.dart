import 'dart:io';

import 'package:favbpini/database/database.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/model/vrp_record.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildVRPHistory(_getSampleRecords()),
    );
  }

  List<VRPRecord> _getSampleRecords() {
    return [
      VRPRecord(VRP("3P8", "6768"), DateTime.now(), Position(), "Basarykova 1997, Ostrov"),
      VRPRecord(VRP("4A1", "8648"), DateTime.now().add(Duration(days: -50)), Position(), "Družstevní 1442, Plzeň"),
      VRPRecord(VRP("4S3", "3368"), DateTime.now().add(Duration(days: -90)), Position(), "Hlavní 10, Ostrov"),
      VRPRecord(VRP("6P4", "9778"), DateTime.now().add(Duration(days: -90)), Position(), "Technická 3, Plzeň"),
      VRPRecord(VRP("3K3", "3654"), DateTime.now().add(Duration(days: -44)), Position(), "Krátká 13, Karlovy Vary"),
      VRPRecord(VRP("3A1", "2214"), DateTime.now().add(Duration(days: -11)), Position(), "Náměstí Míru 10, Plzeň"),
      VRPRecord(VRP("6T1", "7454"), DateTime.now().add(Duration(days: -5)), Position(), "Dělnická 22, Teplice"),
      VRPRecord(VRP("1L4", "9631"), DateTime.now().add(Duration(days: -600)), Position(), "Družební 1997, Ostrov"),
      VRPRecord(VRP("1L4", "9631"), DateTime.now().add(Duration(days: -600)), Position(), "Družební 1997, Ostrov"),
      VRPRecord(VRP("1L4", "9631"), DateTime.now().add(Duration(days: -600)), Position(), "Družební 1997, Ostrov"),
      VRPRecord(VRP("1L4", "9631"), DateTime.now().add(Duration(days: -600)), Position(), "Družební 1997, Ostrov"),
      VRPRecord(VRP("1L4", "9631"), DateTime.now().add(Duration(days: -600)), Position(), "Družební 1997, Ostrov"),
    ];
  }

  Widget _buildVRPHistory(List<VRPRecord> vrpRecordList) {
    return Expanded(
      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeadingText("Historie"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: StreamBuilder<List<FoundVrpRecord>>(
                stream: Provider.of<Database>(context).watchAllRecords(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      return FutureBuilder<String>(
                        future: Future<String>.delayed(Duration(milliseconds: 500), () {
                          return "Whatever";
                        }),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshotz) {
                          return snapshotz.hasData
                              ? ListView(padding: EdgeInsets.all(0),children: [
                                  for (FoundVrpRecord record in snapshot.data)
                                    _buildVRPRecordCard(
                                        VRPRecord(
                                            VRP(record.firstPart, record.secondPart),
                                            record.date,
                                            Position(longitude: record.longitude, latitude: record.latitude),
                                            record.address),
                                        record,
                                        context, snapshot)
                                ])
                              : ListView(children: [for (var i = 0; i < 10; i++) _buildVRPRecordCardLoading()]);
                        },
                      );
                    } else {
                      return Center(child: Text("Nenalezen žádný záznam", style: Theme.of(context).textTheme.subhead));
                    }
                  } else {
                    return ListView(children: [for (var i = 0; i < 10; i++) _buildVRPRecordCardLoading()]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVRPRecordCard(VRPRecord record, FoundVrpRecord dbItem, BuildContext context, AsyncSnapshot<List<FoundVrpRecord>> snapshot) {
    return Dismissible(
      key: Key(dbItem.toString()),
      background: Container(color: Colors.white30),
      onDismissed: (direction) async {
        var sourceImage = File(dbItem.sourceImagePath);
        if (await sourceImage.exists()){
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
