import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:flutter/material.dart';
import './bloc.dart';

class VrpFinderBloc extends Bloc<VrpFinderEvent, VrpFinderState> {
  CameraController _cameraController;
  Timer _timer;
  bool _isScanBusy = false;

  bool _streamStarted = false;

  VrpFinderBloc();

  factory VrpFinderBloc.dispatch() => VrpFinderBloc()..dispatch(LoadCamera());

  @override
  VrpFinderState get initialState => CameraInitialState();

  @override
  Stream<VrpFinderState> mapEventToState(
    VrpFinderEvent event,
  ) async* {
    if (event is LoadCamera) {
      List<CameraDescription> cameras = await availableCameras();
      if (cameras.length < 1) {
        yield CameraErrorState("No camera found");
      } else {
        var controller = await _getCameraController();

        if (!_streamStarted && controller.value.isInitialized) {
          await controller.startImageStream((CameraImage availableImage) async {
            _streamStarted = true;
            if (_isScanBusy) {
//              print("1.5 -------- isScanBusy, skipping...");
              return;
            }

//            print("1 -------- isScanBusy = true");
//            print("Camera.dart: " + availableImage.width.toString() + " - " + availableImage.height.toString());
            _isScanBusy = true;

            String textDetected = await OcrManager.scanText(availableImage);

            if (textDetected != null) {
              debugPrint("textDetected: " + textDetected);
              dispatch(TextFound(textDetected));
            }

            _isScanBusy = false;
          });
        }

        yield CameraLoadedState(controller, false, "");
      }
    } else if (event is TextFound && currentState is CameraLoadedState) {
      yield CameraLoadedState((currentState as CameraLoadedState).controller,
          true, event.textFound);
    }
  }

  Future<CameraController> _getCameraController() async {
    if (_cameraController == null) {
      List<CameraDescription> cameras = await availableCameras();
      _cameraController = CameraController(
        // Get a specific camera from the list of available cameras
        cameras[0],
        // Define the resolution to use
        ResolutionPreset.high,
      );
    }
    await _cameraController.initialize();
    return _cameraController;
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("Bloc disposed");
    _cameraController.stopImageStream();
    _cameraController.dispose();
    _timer.cancel();
  }
}
