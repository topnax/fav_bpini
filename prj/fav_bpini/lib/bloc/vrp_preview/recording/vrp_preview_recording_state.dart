import 'package:equatable/equatable.dart';

abstract class VrpPreviewRecordingState extends Equatable {
  const VrpPreviewRecordingState();
}

class InitialVrpPreviewRecordingState extends VrpPreviewRecordingState {
  @override
  List<Object> get props => [];
}

class RecordingInProgress extends VrpPreviewRecordingState {
  final DateTime currentTime;

  RecordingInProgress(this.currentTime);

  @override
  List<Object> get props => [currentTime];
}

class RecordingFailed extends VrpPreviewRecordingState {
  final String error;

  RecordingFailed(this.error);

  @override
  List<Object> get props => [error];
}

class RecordingSuccess extends VrpPreviewRecordingState {
  final String path;

  RecordingSuccess(this.path);

  @override
  List<Object> get props => [path];
}

class PlaybackInProgress extends VrpPreviewRecordingState {
  final DateTime currentTime;

  PlaybackInProgress(this.currentTime);

  @override
  List<Object> get props => [currentTime];
}


class PlaybackFailed extends VrpPreviewRecordingState {
  final String error;

  PlaybackFailed(this.error);

  @override
  List<Object> get props => [error];
}
