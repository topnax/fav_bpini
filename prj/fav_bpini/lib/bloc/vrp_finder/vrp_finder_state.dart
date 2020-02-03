import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpFinderState extends Equatable {
  VrpFinderState() : super();
}

@immutable
class CameraLoadingState extends VrpFinderState {
  @override
  List<Object> get props => [];
}

@immutable
class CameraInitialState extends VrpFinderState {
  CameraInitialState();

  @override
  List<Object> get props => [];
}

@immutable
class CameraLoadedState extends VrpFinderState {
  final CameraController controller;

  CameraLoadedState(this.controller);

  @override
  List<Object> get props => [controller];
}

@immutable
class CameraFoundText extends VrpFinderState {
  final CameraController controller;
  final List<TextBlock> textBlocks;
  final Size imageSize;

  CameraFoundText(this.controller, this.textBlocks, this.imageSize);

  @override
  List<Object> get props => [controller, textBlocks,imageSize];
}

@immutable
class VrpFoundState extends VrpFinderState {
  final VrpFinderResult result;

  VrpFoundState(this.result);

  @override
  List<Object> get props => [result];
}

@immutable
class CameraErrorState extends VrpFinderState {
  final String errorDescription;

  CameraErrorState(this.errorDescription);

  @override
  List<Object> get props => [errorDescription];
}
