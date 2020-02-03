import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpFinderEvent extends Equatable {
  VrpFinderEvent() : super();
}

@immutable
class LoadCamera extends VrpFinderEvent {
  @override
  List<Object> get props => [];
}

 @immutable
class TextFound extends VrpFinderEvent {
  final List<TextBlock> textBlocks;
  final Size imageSize;

  TextFound(this.textBlocks, this.imageSize);

  @override
  List<Object> get props => [textBlocks];
}

@immutable
class VrpFound extends VrpFinderEvent {
  final VrpFinderResult result;

  VrpFound(this.result);

  @override
  List<Object> get props => [result];
}
