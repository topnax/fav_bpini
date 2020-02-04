import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/model/vrp_record.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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

        crossAxisAlignment: CrossAxisAlignment.start,
//      crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          HeadingText("Historie"),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top:0),
            child: ListView(

              children: [for (VRPRecord record in vrpRecordList) _buildVRPRecordCard(record)],

            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildVRPRecordCard(VRPRecord record) {
    return Dismissible(
      key: Key(record.toString() + DateTime.now().toString()),
      background: Container(color: Colors.white30),
      onDismissed: (direction) {},
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 25, right: 25),
        child: Material(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => {debugPrint("printed")},
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
                          DateFormat('dd.MM.yyyy').format(record.date),
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

//  Widget _buildVRPList(List<VRPRecord> vrpRecordList) {
//
//  }
}
