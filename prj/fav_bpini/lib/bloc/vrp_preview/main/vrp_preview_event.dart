import 'package:equatable/equatable.dart';
import 'package:favbpini/database/database.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpPreviewEvent extends Equatable {}

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
  final FoundVrpRecord record;
  final bool edit;

  SubmitVRP(this.record, {this.edit = false});

  @override
  List<Object> get props => [record, edit];
}

@immutable
class DiscardVRP extends VrpPreviewEvent {
  final String pathToImage;

  DiscardVRP(this.pathToImage);

  @override
  List<Object> get props => [pathToImage];
}

