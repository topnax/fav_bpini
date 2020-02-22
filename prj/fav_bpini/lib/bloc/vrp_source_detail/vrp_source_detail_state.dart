import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpSourceDetailState extends Equatable {
  VrpSourceDetailState() : super();
}

@immutable
class StaticDetail extends VrpSourceDetailState {
  @override
  List<Object> get props => [];
}

@immutable
class HighlightedDetail extends VrpSourceDetailState {
  final Rect highlightedArea;
  final Size imageSize;

  HighlightedDetail(this.highlightedArea, this.imageSize);

  @override
  List<Object> get props => [];
}
