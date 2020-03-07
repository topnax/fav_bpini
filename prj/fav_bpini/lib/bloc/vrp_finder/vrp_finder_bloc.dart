import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/vrp_locator/vrp_locator_impl.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;
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
      debugPrint("here1");
      List<CameraDescription> cameras = await availableCameras();
      debugPrint("here2");
      if (cameras.length < 1) {
        yield CameraErrorState("vrp_finder_error_no_camera");
      } else {
        var controller;
        try {
          controller = await _getCameraController();
        } catch (e) {
          if (e is CameraException) {
            debugPrint("e content ${e.description}");
            if (e.description.toString().toLowerCase().contains("permission")) {
              yield CameraErrorState("vrp_finder_error_permissions");
            }
          } else {
            yield CameraErrorState("vrp_finder_error_other");
          }

          return;
        }
        debugPrint("here3");
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

                debugPrint("Written to $path");

                add(VrpFound(result[0], took, path, DateTime.now()));

                this.close();
                return;
              }
            }

            add(VrpResultsFound(results, Size(availableImage.width.toDouble(), availableImage.height.toDouble()), took,
                DateTime.now()));

            _isScanBusy = false;
          });
        }

        yield CameraLoadedState(controller);
      }
    } else if (event is TextFound) {
      yield CameraFoundText(_cameraController, event.textBlocks, event.imageSize);
    } else if (event is VrpFound) {
      yield VrpFoundState(event.result, event.timeTook, event.pathToImage, event.date);
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
      debugPrint("here bi");
      await _cameraController.initialize();
      debugPrint("here ai");
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
//  final directory = await getExternalStorageDirectory();
  final directory = await getTemporaryDirectory();

  return directory.path;
}
