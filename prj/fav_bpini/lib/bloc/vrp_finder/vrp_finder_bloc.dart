import 'dart:async';
import 'dart:io';

import 'package:image/image.dart' as imglib;
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/vrp_locator/vrp_locator_impl.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

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
              return;
            }

            _isScanBusy = true;

            var start = DateTime.now().millisecondsSinceEpoch;
            var results = await _finder.findVrpInImage(availableImage);
            var took = DateTime.now().millisecondsSinceEpoch - start;
            debugPrint("findVrpInImage took ${took.toString()}ms");

            if (results.length > 0) {
              var result = results.where((res) => res.foundVrp != null).toList();
              if (result.length > 0) {
                debugPrint("adding vrp found event");

                var directory = await _localPath;
                var path = "$directory/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

                File(path)..writeAsBytesSync(imglib.encodeJpg(result[0].image, quality: 40));

                add(VrpFound(result[0], took, path));

                this.close();
                return;
              }
            }

            add(VrpResultsFound(
                results, Size(availableImage.width.toDouble(), availableImage.height.toDouble()), took));

            _isScanBusy = false;
          });
        }

        yield CameraLoadedState(controller);
      }
    } else if (event is TextFound) {
      yield CameraFoundText(_cameraController, event.textBlocks, event.imageSize);
    } else if (event is VrpFound) {
      yield VrpFoundState(event.result, event.timeTook, event.pathToImage);
    } else if (event is VrpResultsFound) {
      yield ResultsFoundState(event.results, event.size, _cameraController, event.timeTook);
    }
  }

  Future<CameraController> _getCameraController() async {
    if (_cameraController == null) {
      List<CameraDescription> cameras = await availableCameras();
      _cameraController = CameraController(
        // get a specific camera from the list of available cameras
        cameras[0],
        // define the resolution to use
        ResolutionPreset.high,
      );
    }
    if (!_cameraController.value.isInitialized) {
      await _cameraController.initialize();
    }
    return _cameraController;
  }

  @override
  Future<void> close() {
    debugPrint("disposing a vrp finder bloc");
    _streamStarted = false;
    if (_cameraController != null) {
      _cameraController.dispose();
      _cameraController = null;
    }
    return super.close();
  }
}

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();

  return directory.path;
}
