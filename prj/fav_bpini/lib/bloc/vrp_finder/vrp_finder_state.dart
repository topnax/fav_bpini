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
class CameraLoading extends VrpFinderState {
  @override
  List<Object> get props => [];
}

@immutable
class CameraInitialState extends VrpFinderState {
  @override
  List<Object> get props => [];
}

@immutable
class CameraLoaded extends VrpFinderState {
  final CameraController controller;

  CameraLoaded(this.controller);

  @override
  List<Object> get props => [controller];
}

@immutable
class VrpFoundState extends VrpFinderState {
  final VrpFinderResult result;
  final int timeTook;
  final String pathToImage;
  final DateTime date;

  VrpFoundState(this.result, this.timeTook, this.pathToImage, this.date);

  @override
  List<Object> get props => [result];
}

@immutable
class CameraFailure extends VrpFinderState {
  final String errorDescription;

  CameraFailure(this.errorDescription);

  @override
  List<Object> get props => [errorDescription];
}
