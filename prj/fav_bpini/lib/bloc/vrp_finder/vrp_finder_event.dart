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
  final int timeTook;
  final String pathToImage;
  final DateTime date;

  VrpFound(this.result, this.timeTook, this.pathToImage, this.date);

  @override
  List<Object> get props => [result];
}

@immutable
class VrpResultsFound extends VrpFinderEvent {
  final List<VrpFinderResult> results;
  final Size size;
  final int timeTook;
  final DateTime date;

  VrpResultsFound(this.results, this.size, this.timeTook, this.date);

  @override
  List<Object> get props => [results, size];
}
