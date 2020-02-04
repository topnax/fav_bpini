import 'package:favbpini/model/vrp.dart';
import 'package:geolocator/geolocator.dart';

class VRPRecord {
  final VRP vrp;
  final DateTime date;
  final Position position;
  final String address;

  VRPRecord(this.vrp, this.date, this.position, this.address);
}
