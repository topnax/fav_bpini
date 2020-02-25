import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_event.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VrpPreviewRecordingBloc extends Bloc<VrpPreviewRecordingEvent, VrpPreviewRecordingState> {
  final _sound = FlutterSound();
  var audioPath;
  var recorded = false;

  @override
  VrpPreviewRecordingState get initialState => InitialVrpPreviewRecordingState();

  @override
  Stream<VrpPreviewRecordingState> mapEventToState(VrpPreviewRecordingEvent event,) async* {
    debugPrint("event is ");
    if (event is RecordingStarted) {
      debugPrint("requesting permission");
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
      debugPrint("requested permission");
      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
      debugPrint("got permission status");

      if (permission == PermissionStatus.granted) {
        debugPrint("Mic permission granted");
        yield RecordingInProgress(DateTime.fromMillisecondsSinceEpoch(0));
        final dir = await getTemporaryDirectory();
        debugPrint("Starting recording...");
        audioPath = "$dir/${DateTime
            .now()
            .millisecondsSinceEpoch}.audio";
        try {
          await _sound.startRecorder(uri: audioPath);

          debugPrint("Starterd recording");

          _sound.onRecorderStateChanged.listen((event) {
            add(RecordingUpdated(event.currentPosition.toInt()));
          });
        } catch (exception) {
          debugPrint("Exception while starting recorder: " + exception);
          yield RecordingFailed("Nepodařilo se spustit nahrávání.");
        }
      } else {
        debugPrint("No permissions granted");
        yield RecordingFailed("Bez povolení nelze nahrávat zvuk z mikrofonu.");
      }
    } else if (event is RecordingUpdated) {
      yield RecordingInProgress(DateTime.fromMillisecondsSinceEpoch(event.currentPosition.toInt()));
    } else if (event is RecordingStopped) {
      try {
        _sound.stopRecorder();
        recorded = true;
        yield InitialVrpPreviewRecordingState();
      } catch (exception) {
        recorded = false;
        debugPrint("Exception while stopping recorder: " + exception);
        yield RecordingFailed("Nepodařilo se zastavit nahrávání.");
      }
    } else if (event is PlaybackStarted) {
      try {
        await _sound.startPlayer(audioPath);

        _sound.onPlayerStateChanged.listen((event) {
          add(PlaybackUpdated(event.currentPosition.toInt()));
        });
      } catch (exception) {
        debugPrint("Exception while starting player: " + exception);
        yield PlaybackFailed("Nepodařilo se spustit přehrávání.");
      }
    } else if (event is PlaybackUpdated) {
      yield PlaybackInProgress(DateTime.fromMillisecondsSinceEpoch(event.currentPosition.toInt()));
    } else if (event is PlaybackStopped) {
      try {
        _sound.stopPlayer();
      } catch (exception) {
        debugPrint("Exception while stopping player: " + exception);
        yield RecordingFailed("Nepodařilo se zastavit nahrávání.");
      }
    }
  }
}
