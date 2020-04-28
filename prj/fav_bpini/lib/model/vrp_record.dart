import 'package:favbpini/model/vrp.dart';
import 'package:geolocator/geolocator.dart';

class VRPRecord {
  /// The scanned VRP.
  final VRP vrp;

  /// The date the VRP was scanned.
  final DateTime date;

  /// The position at which the VRP was scanned.
  final Position position;

  /// The address at which the VRP was scanned.
  final String address;

  VRPRecord(this.vrp, this.date, this.position, this.address);
}
