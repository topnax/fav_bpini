import 'dart:ui';

import 'package:equatable/equatable.dart';
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

class VrpFound extends VrpFinderEvent {
  final TextLine textLine;
  final Size imageSize;

  VrpFound(this.textLine, this.imageSize);
  @override
  List<Object> get props => [textLine, imageSize];
}

class TextFound extends VrpFinderEvent {
  final String textFound;
  final List<TextBlock> detectedTextBlocks;
  final Size imageSize;

  TextFound(this.textFound, this.detectedTextBlocks, this.imageSize);
  @override
  List<Object> get props => [textFound, detectedTextBlocks, imageSize];
}
