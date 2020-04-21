import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../model/vrp.dart';

@immutable
abstract class VrpPreviewState extends Equatable {
  VrpPreviewState() : super();
}

class InitialVrpPreviewState extends VrpPreviewState {
  final VRP vrp;

  InitialVrpPreviewState(this.vrp);

  @override
  List<Object> get props => [vrp];
}

class PositionFailed extends VrpPreviewState {
  final String error;

  PositionFailed(this.error);

  @override
  List<Object> get props => [];
}

class PositionLoading extends VrpPreviewState {
  PositionLoading();

  @override
  List<Object> get props => [];
}

class PositionLoaded extends VrpPreviewState {
  final double longitude;
  final double latitude;
  final addressLoaded;

  PositionLoaded({this.addressLoaded = false, @required this.latitude, @required this.longitude});

  @override
  List<Object> get props => [addressLoaded];
}

class VrpSubmitted extends VrpPreviewState {
  VrpSubmitted();

  @override
  List<Object> get props => [];
}
