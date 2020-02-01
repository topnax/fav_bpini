import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
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
class VrpFoundState extends VrpFinderState {
  final TextLine textLine;
  final Size imageSize;

  VrpFoundState(this.textLine, this.imageSize);
  @override
  List<Object> get props => [textLine, imageSize];
}

@immutable
class CameraLoadedState extends VrpFinderState {
  final CameraController controller;
  final bool textFound;
  final String ocrText;
  final Size imageSize;
  final List<TextBlock> detectedTextBlocks;


  CameraLoadedState(this.controller, this.textFound, this.ocrText, this.detectedTextBlocks, this.imageSize);

  @override
  List<Object> get props => [controller, textFound, ocrText, detectedTextBlocks, imageSize];
}

@immutable
class CameraErrorState extends VrpFinderState {
  final String errorDescription;

  CameraErrorState(this.errorDescription);

  @override
  List<Object> get props => [errorDescription];
}

