import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpSourceDetailEvent extends Equatable {}

@immutable
class Highlighted extends VrpSourceDetailEvent {
  final Rect highlightedArea;
  final Size imageSize;

  Highlighted(this.highlightedArea, this.imageSize);

  List<Object> get props => [highlightedArea];
}

@immutable
class NotHighlighted extends VrpSourceDetailEvent {
  List<Object> get props => [];
}
