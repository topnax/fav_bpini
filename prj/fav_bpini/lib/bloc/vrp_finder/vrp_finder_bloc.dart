import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
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
              return;
            }
            _isScanBusy = true;

            List<TextBlock> detectedTextBlocks =
                await OcrManager.scanText(availableImage);

            if (detectedTextBlocks != null) {
              dispatch(TextFound(
                  "",
                  detectedTextBlocks,
                  Size(availableImage.width.toDouble(),
                      availableImage.height.toDouble())));
            }

            _isScanBusy = false;
          });
        }

        yield CameraLoadedState(
            controller, false, "", new List<TextBlock>(), Size(0, 0));
      }
    } else if (event is TextFound && currentState is CameraLoadedState) {
      debugPrint("yielding");
      yield CameraLoadedState((currentState as CameraLoadedState).controller,
          true, event.textFound, event.detectedTextBlocks, event.imageSize);
      debugPrint("yielded");
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
