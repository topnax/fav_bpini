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

class TextFound extends VrpFinderEvent {
  final List<TextBlock> textBlocks;
  final Size imageSize;

  TextFound(this.textBlocks, this.imageSize);

  @override
  List<Object> get props => [textBlocks];
}
