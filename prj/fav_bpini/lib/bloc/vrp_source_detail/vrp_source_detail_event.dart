import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpSourceDetailEvent extends Equatable {}

@immutable
class OnHighlight extends VrpSourceDetailEvent {
  final Rect highlightedArea;
  final Size imageSize;

  OnHighlight(this.highlightedArea, this.imageSize);

  List<Object> get props => [highlightedArea];
}

@immutable
class OnHideHighlight extends VrpSourceDetailEvent {
  List<Object> get props => [];
}


