import 'package:favbpini/model/vrp.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

abstract class VrpValidator {
  const VrpValidator();

  VRP validateVrp(TextBlock tb);
}
