import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import './bloc.dart';

class VrpFinderBloc extends Bloc<VrpFinderEvent, VrpFinderState> {
  CameraController _cameraController;

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
        yield CameraLoadedState(controller);
      }
    }
  }

  Future<CameraController> _getCameraController() async {
    if (_cameraController == null) {
      List<CameraDescription> cameras = await availableCameras();
      _cameraController = CameraController(
        // Get a specific camera from the list of available cameras
        cameras[0],
        // Define the resolution to use
        ResolutionPreset.medium,
      );
    }
    await _cameraController.initialize();
    return _cameraController;
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }
}
