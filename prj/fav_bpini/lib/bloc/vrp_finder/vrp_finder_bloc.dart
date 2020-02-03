import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/vrp_locator/vrp_locator_impl.dart';
import 'package:flutter/widgets.dart';

import './bloc.dart';

class VrpFinderBloc extends Bloc<VrpFinderEvent, VrpFinderState> {
  CameraController _cameraController;
  bool _isScanBusy = false;

  bool _streamStarted = false;

  VrpFinder _finder = VrpFinderImpl();

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
              debugPrint("scanner is busy");
              return;
            }

            _isScanBusy = true;

            debugPrint("Started scanning...");

            var result = await _finder.findVrpInImage(availableImage);

            if (result != null) {
              add(VrpFound(result));
              close();
            }

            _isScanBusy = false;
            debugPrint("Not busy...");
          });
        }

        yield CameraLoadedState(controller);
      }
    } else if (event is TextFound) {
      yield CameraFoundText(_cameraController, event.textBlocks, event.imageSize);
    } else if (event is VrpFound) {
      yield VrpFoundState(event.result);
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
  Future<Function> close() {
    debugPrint("Bloc disposed");
    _cameraController.stopImageStream();
    _cameraController.dispose();
    return super.close();
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
