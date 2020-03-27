import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/vrp_locator/vrp_locator_impl.dart';
import 'package:flutter/services.dart';
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
      List<CameraDescription> cameras = await availableCameras();
      if (cameras.length < 1) {
        yield CameraErrorState("vrp_finder_error_no_camera");
      } else {
        CameraController controller;
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
        if (!_streamStarted && controller.value.isInitialized) {
          await controller.startImageStream((CameraImage availableImage) async {
            _streamStarted = true;
            if (_isScanBusy) {
              return;
            }

            _isScanBusy = true;

            var start = DateTime.now().millisecondsSinceEpoch;

            var took;
            VrpFinderResult result;
            try {
              debugPrint("about to find vrps");
              result = await _finder.findVrpInImage(availableImage);
              debugPrint("finished");
              took = DateTime.now().millisecondsSinceEpoch - start;
              debugPrint("findVrpInImage took ${took.toString()}ms");
            } catch (e, s) {
              if (e is PlatformException) {
                debugPrint("Caught PE code:${e.code}, message:${e.message}");
                return;
              }
              debugPrint("some other exception ${e.toString()}");
              debugPrint(s.toString());
            }

            if (result == null) {
              _isScanBusy = false;
              return;
            }

            controller.stopImageStream();

            var directory = await _localPath;
            var path = "$directory/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

            File(path)..writeAsBytesSync(imglib.encodeJpg(result.image, quality: 40));

            debugPrint("Written to $path");
            _isScanBusy = false;
            add(VrpFound(result, took, path, DateTime.now()));
            this.close();
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
