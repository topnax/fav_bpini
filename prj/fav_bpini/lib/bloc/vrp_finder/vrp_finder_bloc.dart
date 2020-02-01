import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import './bloc.dart';

class VrpFinderBloc extends Bloc<VrpFinderEvent, VrpFinderState> {
  CameraController _cameraController;
  bool _isScanBusy = false;

  bool _streamStarted = false;

  VrpFinderBloc();

  factory VrpFinderBloc.dispatch() => VrpFinderBloc()..add(LoadCamera());

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

            List<TextBlock> detectedBlocks =
                await OcrManager.scanText(availableImage);

            _isScanBusy = false;
          });
        }

        yield CameraLoadedState(controller, false, "");
      }
    } else if (event is TextFound && state is CameraLoadedState) {
      yield CameraLoadedState(
          (state as CameraLoadedState).controller, true, event.textFound);
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

//  @override
//  void dispose() {
//    super.dispose();
//    debugPrint("Bloc disposed");
//    _cameraController.stopImageStream();
//    _cameraController.dispose();
//    _timer.cancel();
//  }
}
