import 'package:camera/camera.dart';
import 'package:favbpini/ocr/ocr.dart';
import 'package:favbpini/utils/image.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart' as imglib;

abstract class ImageWrapper {
  FirebaseVisionImage getFirebaseVisionImage();
  imglib.Image getImage();
  int get width;
  int get height;
}

class CameraImageWrapper extends ImageWrapper {
  final CameraImage _cameraImage;

  CameraImageWrapper(this._cameraImage);

  @override
  imglib.Image getImage() {
    return convertCameraImage(_cameraImage);
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
