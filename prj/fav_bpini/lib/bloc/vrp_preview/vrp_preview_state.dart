import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

import '../../model/vrp.dart';

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
  PositionFailed();

  @override
  List<Object> get props => [];
}

class PositionLoading extends VrpPreviewState {
  PositionLoading();

  @override
  List<Object> get props => [];
}

class PositionLoaded extends VrpPreviewState {
  final Position position;
  final String address;

  PositionLoaded(this.position, this.address);

  @override
  List<Object> get props => [this.position, this.address];
}

class VrpSubmitted extends VrpPreviewState {
  VrpSubmitted();

  @override
  List<Object> get props => [];
}
