import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/main.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/vrp_locator/vrp_locator_impl.dart';
import 'package:flutter/services.dart';
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
    log.wtf("Received $event");
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
            log.e("e content ${e.description}");
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
            log.wtf("receiving an image");
            _streamStarted = true;
            if (_isScanBusy) {
              log.wtf("skipping is busy");
              return;
            }

            _isScanBusy = true;

            var start = DateTime.now().millisecondsSinceEpoch;

            var took;
            VrpFinderResult result;
            try {
              log.wtf("about to find vrps");
              result = await _finder.findVrpInImage(availableImage);
              log.d("finished");
              took = DateTime.now().millisecondsSinceEpoch - start;
              log.d("findVrpInImage took ${took.toString()}ms");
            } catch (e, s) {
              if (e is PlatformException) {
                log.e("Caught PE code:${e.code}, message:${e.message}");
                return;
              }
              log.e("some other exception ${e.toString()}");
              log.e(s.toString());
            }

            if (result == null) {
              _isScanBusy = false;
              return;
            }

            await controller.stopImageStream();

            var directory = await _localPath;
            var path = "$directory/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

            File(path)..writeAsBytesSync(imglib.encodeJpg(result.image, quality: 40));

            log.d("Written to $path");
            add(VrpFound(result, took, path, DateTime.now()));
            await this.close();
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
      await _cameraController.initialize();
    }
    return _cameraController;
  }

  @override
  Future<void> close() async {
    _streamStarted = false;
    if (_cameraController != null) {
      await _cameraController.dispose();
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
