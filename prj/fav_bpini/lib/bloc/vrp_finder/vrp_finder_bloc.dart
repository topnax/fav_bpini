import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/widgets.dart';

import './bloc.dart';

class VrpFinderBloc extends Bloc<VrpFinderEvent, VrpFinderState> {
  CameraController _cameraController;
  bool _isScanBusy = false;

  bool _streamStarted = false;

  VrpFinderBloc();

  factory VrpFinderBloc.dispatch() =>
      VrpFinderBloc()
        ..add(LoadCamera());

  @override
  VrpFinderState get initialState => CameraInitialState();

  @override
  Stream<VrpFinderState> mapEventToState(VrpFinderEvent event,) async* {
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
              debugPrint("is busy");
              return;
            }

            _isScanBusy = true;

            debugPrint("Started scanning...");
            List<TextBlock> detectedBlocks =
            await OcrManager.scanText(availableImage);
            debugPrint("Done...");
            if (detectedBlocks.length > 0) {
              var img = convertCameraImage(availableImage);

              for (var textBlock in detectedBlocks) {
                int total = 0;
                int white = 0;
                for (int i = textBlock.boundingBox.top.toInt(); i <
                    textBlock.boundingBox.bottom.toInt(); i ++) {
                  for (int j = textBlock.boundingBox.left.toInt(); j <
                      textBlock.boundingBox.right.toInt(); j++) {
                    var color = img.getPixel(j, i);
                    int r = (color & 0xFF);
                    int g = ((color >> 8) & 0xFF);
                    int b = ((color >> 16) & 0xFF);
                    var y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
                    white += y < 128 ? 0: 1;
                    total++;
                  }
                }
                debugPrint(textBlock.text + " - ratio " + (white.toDouble() / total.toDouble()).toString());

              }

            }

            int color = 0x00AAFFCC;


            add(TextFound(
                detectedBlocks,
                Size(availableImage.width.toDouble(),
                    availableImage.height.toDouble())));

            _isScanBusy = false;
            debugPrint("Not busy...");
          });
        }

        yield CameraLoadedState(controller);
      }
    } else if (event is TextFound) {
      yield CameraFoundText(
          _cameraController, event.textBlocks, event.imageSize);
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
