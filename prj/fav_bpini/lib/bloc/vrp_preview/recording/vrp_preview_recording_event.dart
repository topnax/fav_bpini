import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class VrpPreviewRecordingEvent extends Equatable {
  const VrpPreviewRecordingEvent();
}

@immutable
class RecordingStarted extends VrpPreviewRecordingEvent {
  RecordingStarted();

  @override
  List<Object> get props => [];
}

@immutable
class RecordingStopped extends VrpPreviewRecordingEvent {
  RecordingStopped();

  @override
  List<Object> get props => [];
}

@immutable
class RecordingUpdated extends VrpPreviewRecordingEvent {
  final int currentPosition;

  RecordingUpdated(this.currentPosition);

  @override
  List<Object> get props => [currentPosition];
}

@immutable
class PlaybackStarted extends VrpPreviewRecordingEvent {
  PlaybackStarted();

  @override
  List<Object> get props => [];
}

@immutable
class PlaybackUpdated extends VrpPreviewRecordingEvent {
  final int currentPosition;

  PlaybackUpdated(this.currentPosition);

  @override
  List<Object> get props => [currentPosition];
}

@immutable
class PlaybackStopped extends VrpPreviewRecordingEvent {
  PlaybackStopped();

  @override
  List<Object> get props => [];
}


@immutable
class RecordRemoved extends VrpPreviewRecordingEvent {
  RecordRemoved();

  @override
  List<Object> get props => [];
}

