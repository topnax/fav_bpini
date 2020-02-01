import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image_utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprintf/sprintf.dart';
import './bloc.dart';

class VrpFinderBloc extends Bloc<VrpFinderEvent, VrpFinderState> {
  CameraController _cameraController;
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
    if (event is VrpFound) {
      yield VrpFoundState(event.textLine, event.imageSize);
    } else if (event is LoadCamera) {
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

            imglib.Image img = await convertCameraImageToImage(availableImage);

            if (detectedTextBlocks != null) {
              List<TextLine> matchingLines = List<TextLine>();
              for (TextBlock tb in detectedTextBlocks) {
                debugPrint("new text block of confidence ${tb.confidence}:");
                for (TextLine tl in tb.lines) {
                  debugPrint("confidence of ${tl.text} is ${tl.confidence}");

//                  List<String> parts = row.split(" ");
//                  debugPrint("\nPrinting:");
//                  for (var part in parts) {
//                    debugPrint(part);
//                  }
                  int whites = 0;
                  int blacks = 0;

                  if (tl.elements.length == 2 &&
                      tl.elements[0].text.length == 3 &&
                      tl.elements[1].text.length == 4) {
                    double widthRatio = tl.elements[0].boundingBox.width /
                        tl.elements[1].boundingBox.width;
                    if (widthRatio > 0.80 && widthRatio < 1.05) {
                      int height = tl.boundingBox.width.floor();
                      int width = tl.boundingBox.height.floor();
                      debugPrint(
                          "cameraimg width is ${availableImage.width}, height is ${availableImage.height}");
                      debugPrint(
                          "img width is ${img.width}, height is ${img.height}");
                      debugPrint("bb ${width}, height is ${height}");
                      debugPrint(
                          "bb ${tl.boundingBox.left}, ${tl.boundingBox.top}");
                      debugPrint("${tl.text}");
//                      for (int y = 0; y < height; y++) {
//                        for (int x = 0; x < width; x++) {
//
//                          int pixel = img.getPixel(
//                              x + tl.boundingBox.top.floor(),
//                              y + (img.height - tl.boundingBox.left.floor() + tl.boundingBox.width.floor()));
//                          int r = (pixel >> 16) & 0xff;
//                          int g = (pixel >> 8) & 0xff;
//                          int b = (pixel >> 0) & 0xff;
////                          var Y = 0.2126 * (r).toDouble() + 0.7152 * g.toDouble() + 0.0722 * b.toDouble();
//                          if (r >= 128) {
//                            whites++;
//                          } else {
//                            blacks++;
//                          }
////                          debugPrint(sprintf("pixel %d-%d : %d => %d %d %d", [x,y,pixel,r,g,b]));
//
//                        }
//                      }

                      bool isShown = await PermissionHandler().shouldShowRequestPermissionRationale(PermissionGroup.storage);
                      Map<PermissionGroup, PermissionStatus> permissions =
                          await PermissionHandler()
                              .requestPermissions([PermissionGroup.storage]);

                      final String path =
                          (await getExternalStorageDirectory()).path;
                      debugPrint(path + '/thumbnail-test.png');
                      new File(path + '/thumbnail-test.png')
                        ..writeAsBytesSync(imglib.encodePng(img));

                      debugPrint("whites are $whites");
                      debugPrint("blacks are $blacks");
                      debugPrint(tl.text);

                      matchingLines.add(tl);
                    }
                  }
                }
              }

              if (matchingLines.length > 0) {
//                nw.sort((a, b) =>
//                    a.confidence.compareTo(b.confidence
//                    )
//                );
                if (matchingLines.length > 1) {
                  matchingLines.removeRange(1, matchingLines.length - 1);
                }

                _streamStarted = false;
                controller.stopImageStream();

                dispatch(VrpFound(
                    matchingLines[0],
                    Size(availableImage.width.toDouble(),
                        availableImage.height.toDouble())));
              } else {
                dispatch(TextFound(
                    "",
                    detectedTextBlocks,
                    Size(availableImage.width.toDouble(),
                        availableImage.height.toDouble())));
              }

              _isScanBusy = false;
            }
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
    _cameraController.dispose();
    debugPrint("Camera controller disposed");
    debugPrint("Timer cancelled");
  }
}
