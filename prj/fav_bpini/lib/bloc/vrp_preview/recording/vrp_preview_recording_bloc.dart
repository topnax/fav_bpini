import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_event.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class VrpPreviewRecordingBloc extends Bloc<VrpPreviewRecordingEvent, VrpPreviewRecordingState> {
  final _sound = FlutterSound();
  var audioPath = "";
  final initialAudioPath;
  var deletedNote = false;
  var audioNoteEdited = false;

  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;

  VrpPreviewRecordingBloc(this.audioPath) : this.initialAudioPath = audioPath;

  @override
  VrpPreviewRecordingState get initialState {
    if (audioPath != "") {
      return RecordingSuccess(audioPath);
    } else {
      return InitialVrpPreviewRecordingState();
    }
  }

  @override
  Stream<VrpPreviewRecordingState> mapEventToState(
    VrpPreviewRecordingEvent event,
  ) async* {
    if (event is RecordingStarted) {
      debugPrint("Received recording started event");
      yield RecordingInProgress(DateTime.fromMillisecondsSinceEpoch(0));
      final dir = await getTemporaryDirectory();
      debugPrint("Starting recording...");
      audioPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.audio";

      debugPrint("The path to audio is: $audioPath");
      try {
        await _sound.startRecorder(uri: audioPath);

        debugPrint("Starterd recording");

        _recorderSubscription = _sound.onRecorderStateChanged.listen((event) {
          add(RecordingUpdated(event.currentPosition.toInt()));
        });
      } catch (exception) {
        debugPrint("Exception while starting recorder: " + exception);
        yield RecordingFailed("Nepodařilo se spustit nahrávání.");
      }
    } else if (event is RecordingUpdated) {
      yield RecordingInProgress(DateTime.fromMillisecondsSinceEpoch(event.currentPosition.toInt()));
    } else if (event is RecordingStopped) {
      debugPrint("RecordingStopped event");
      try {
        _recorderSubscription.cancel();
        _sound.stopRecorder();
        yield RecordingSuccess(audioPath);
        audioNoteEdited = true;
        deletedNote = false;
      } catch (exception) {
        debugPrint("Exception while stopping recorder: " + exception);
        yield RecordingFailed("Nepodařilo se zastavit nahrávání.");
      }
    } else if (event is PlaybackStarted) {
      try {
        debugPrint("playing $audioPath");
        if (!(await File(audioPath).exists())) {
          throw Exception("file does not exist");
        } else {
          debugPrint("exists");
        }
        await _sound.startPlayer(audioPath);

        _playerSubscription = _sound.onPlayerStateChanged.listen((event) {
          if (event != null) {
            add(PlaybackUpdated(event.currentPosition.toInt()));
          } else {
            add(PlaybackStopped());
          }
        });
      } catch (exception) {
        debugPrint("Exception while starting player: " + exception.toString());
        yield PlaybackFailed("Nepodařilo se spustit přehrávání.");
      }
    } else if (event is PlaybackUpdated) {
      yield PlaybackInProgress(DateTime.fromMillisecondsSinceEpoch(event.currentPosition.toInt()));
    } else if (event is PlaybackStopped) {
      debugPrint("PlaybackStopped event");
      try {
        _playerSubscription.cancel();
        if (_sound.audioState == t_AUDIO_STATE.IS_PLAYING) {
          _sound.stopPlayer();
        }
        yield RecordingSuccess(audioPath);
      } catch (exception) {
        debugPrint("Exception while stopping player: " + exception);
        yield RecordingFailed("Nepodařilo se zastavit nahrávání.");
      }
    } else if (event is RecordRemoved) {
      audioNoteEdited = true;
      deletedNote = true;
      if (audioPath != initialAudioPath) {
        await File(audioPath).delete();
      }
      audioPath = "";
      yield InitialVrpPreviewRecordingState();
    }
  }

  @override
  Future<void> close() {
    if (_sound.audioState == t_AUDIO_STATE.IS_PLAYING) {
      _sound.stopPlayer();
    } else if (_sound.audioState == t_AUDIO_STATE.IS_RECORDING) {
      _sound.stopRecorder();
    }

    return super.close();
  }
}
