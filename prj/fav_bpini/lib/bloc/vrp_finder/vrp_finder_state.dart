import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
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
  final bool textFound;
  final String ocrText;

  CameraLoadedState(this.controller, this.textFound, this.ocrText);

  @override
  List<Object> get props => [controller, textFound, ocrText];
}

@immutable
class CameraErrorState extends VrpFinderState {
  final String errorDescription;

  CameraErrorState(this.errorDescription);

  @override
  List<Object> get props => [errorDescription];
}

