import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpPreviewEvent extends Equatable {
}

@immutable
class GetAddressByPosition extends VrpPreviewEvent {

  GetAddressByPosition();

  @override
  List<Object> get props => [];

}

@immutable
class RescanVRP extends VrpPreviewEvent {

  RescanVRP();

  @override
  List<Object> get props => [];

}

@immutable
class SubmitVRP extends VrpPreviewEvent {

  SubmitVRP();

  @override
  List<Object> get props => [];

}
