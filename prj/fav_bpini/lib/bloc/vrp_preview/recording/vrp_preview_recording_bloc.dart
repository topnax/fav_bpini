import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_event.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class VrpPreviewRecordingBloc extends Bloc<VrpPreviewRecordingEvent, VrpPreviewRecordingState> {
  final _sound = FlutterSound();
  var audioPath;
  var recorded = false;

  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;

  @override
  VrpPreviewRecordingState get initialState => InitialVrpPreviewRecordingState();

  @override
  Stream<VrpPreviewRecordingState> mapEventToState(
    VrpPreviewRecordingEvent event,
  ) async* {
    debugPrint("event is ");
    if (event is RecordingStarted) {
      debugPrint("Received recording started event");
//      debugPrint("requesting permission");
//      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
//      debugPrint("requested permission");
//      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
//      debugPrint("got permission status");

//      if (permission == PermissionStatus.granted) {
      debugPrint("Mic permission granted");
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
//      } else {
//        debugPrint("No permissions granted");
//        yield RecordingFailed("Bez povolení nelze nahrávat zvuk z mikrofonu.");
//      }
    } else if (event is RecordingUpdated) {
      yield RecordingInProgress(DateTime.fromMillisecondsSinceEpoch(event.currentPosition.toInt()));
    } else if (event is RecordingStopped) {
      debugPrint("RecordingStopped event");
      try {
        _recorderSubscription.cancel();
        _sound.stopRecorder();
        recorded = true;
        yield RecordingSuccess(audioPath);
      } catch (exception) {
        recorded = false;
        debugPrint("Exception while stopping recorder: " + exception);
        yield RecordingFailed("Nepodařilo se zastavit nahrávání.");
      }
    } else if (event is PlaybackStarted) {
      try {
        await _sound.startPlayer(audioPath);

        _playerSubscription = _sound.onPlayerStateChanged.listen((event) {
          if (event != null) {
            add(PlaybackUpdated(event.currentPosition.toInt()));
          } else {
            add(PlaybackStopped());
          }
        });
      } catch (exception) {
        debugPrint("Exception while starting player: " + exception);
        yield PlaybackFailed("Nepodařilo se spustit přehrávání.");
      }
    } else if (event is PlaybackUpdated) {
      yield PlaybackInProgress(DateTime.fromMillisecondsSinceEpoch(event.currentPosition.toInt()));
    } else if (event is PlaybackStopped) {
      debugPrint("PlaybackStopped event");
      try {
        _playerSubscription.cancel();
        _sound.stopPlayer();
        yield RecordingSuccess(audioPath);
      } catch (exception) {
        debugPrint("Exception while stopping player: " + exception);
        yield RecordingFailed("Nepodařilo se zastavit nahrávání.");
      }
    }
  }

  @override
  Future<Function> close() {
    _sound.stopPlayer();
    _sound.stopRecorder();
    return this.close();
  }
}
