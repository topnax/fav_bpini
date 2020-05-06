import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image/image.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart' as imglib;

/// A wrapper used for enabling VRP recognition techniques to be used on various image formats.
/// This was specially created for the ability to test VRP recognition technique.
abstract class ImageWrapper {
  FirebaseVisionImage getFirebaseVisionImage();
  imglib.Image getImage();
  int get width;
  int get height;
}

/// An [ImageWrapper] used when recognizing a VRP from an image coming straight from the device's camera
class CameraImageWrapper extends ImageWrapper {
  final CameraImage _cameraImage;

  CameraImageWrapper(this._cameraImage);

  @override
  imglib.Image getImage() {
    // YUV420 on Android devices
    // BGRA8888 on iOS devices, not tested
    return _cameraImage.format.group == ImageFormatGroup.yuv420
        ? convertCameraImageYuv420(_cameraImage)
        : convertCameraImageBgra8888(_cameraImage);
  }

  @override
  FirebaseVisionImage getFirebaseVisionImage() {
    return OcrHelper.getFirebaseVisionImageFromCameraImage(_cameraImage);
  }

  @override
  int get height => _cameraImage.width;

  @override
  int get width => _cameraImage.height;
}

/// An [ImageWrapper] used when recognizing a VRP from a image stored on a local storage
class FileImageWrapper extends ImageWrapper {
  final imglib.Image _image;
  final String _path;
  final angleRotation;

  FileImageWrapper(this._image, this._path, {this.angleRotation = 0});

  @override
  imglib.Image getImage() {
    return imglib.copyRotate(_image, 90);
  }

  @override
  FirebaseVisionImage getFirebaseVisionImage() {
    return FirebaseVisionImage.fromFilePath(_path);
  }

  @override
  int get height => _image.height;

  @override
  int get width => _image.width;
}
