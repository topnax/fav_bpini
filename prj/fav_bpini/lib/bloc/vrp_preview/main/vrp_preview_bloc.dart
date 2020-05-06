import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moor/src/runtime/data_class.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'bloc.dart';

class VrpPreviewBloc extends Bloc<VrpPreviewEvent, VrpPreviewState> {
  /// Name of the folder in which the source images will be stored
  static const SOURCE_IMAGES_FOLDER_NAME = "source";

  /// Name of the folder in which the audio notes will be stored
  static const AUDIO_NOTES_FOLDER_NAME = "audio_notes";

  /// Used for localizing error messages
  final AppLocalizations _appLocalizations;

  /// Current VRP
  final VRP vrp;

  /// Controller of the address field
  final TextEditingController _addressController;

  /// Controller of the note fi eld
  final TextEditingController _noteController;

  /// Database provider
  final Database database;

  /// Google Map completer
  Completer<GoogleMapController> mapController = Completer();

  /// The position at which was the VRP scanned
  var position = Position(longitude: 0, latitude: 0);

  /// A flag indicating whether the VRP was rescanned
  var rescanned = false;

  /// A flag indicating whether the user is editing an existing VRP
  final bool editing;

  /// A path to the file in the local storage that represents the image in which was the VRP recognized
  final String initialSourceImagePath;

  /// A path to the file in the local storage that represents the image in which was the rescanned VRP recognized
  String _rescannedSourceImagePath;

  VrpPreviewBloc(this.vrp, this._addressController, this._noteController, this.database, this.initialSourceImagePath,
      this.editing, this._appLocalizations, double latitude, double longitude) {
    if (!editing) {
      // when not editing a record, se the _rescannedSourceImagePath to the initial one
      rescanned = true;
      _rescannedSourceImagePath = initialSourceImagePath;
    }
    position = Position(latitude: latitude, longitude: longitude);
  }

  @override
  VrpPreviewState get initialState => InitialVrpPreviewState(vrp);

  @override
  Stream<VrpPreviewState> mapEventToState(
    VrpPreviewEvent event,
  ) async* {
    if (event is GetAddressByPosition) {
      yield* _mapGetAddressByPositionToState();
    } else if (event is DiscardVRP) {
      yield* _mapDiscardVrpToState();
    } else if (event is SubmitVRP) {
      yield* mapSubmitVrpToState(event);
    } else if (event is VrpRescanned) {
      yield* _mapVrpRescannedToState(event);
    }
  }

  Stream<VrpPreviewState> _mapVrpRescannedToState(VrpRescanned event) async* {
    if (rescanned) {
      var tempFile = File(_rescannedSourceImagePath);
      if (await tempFile.exists()) {
        tempFile.delete();
        log.d("deleted temporary image source file $_rescannedSourceImagePath");
      } else {
        log.d("temporary image source file $_rescannedSourceImagePath does not exist");
      }
    } else {
      rescanned = true;
    }

    _rescannedSourceImagePath = event.pathToImage;
  }

  Stream<VrpPreviewState> _mapDiscardVrpToState() async* {
    if (rescanned) {
      var rescannedSourceImageFile = File(_rescannedSourceImagePath);
      if (await rescannedSourceImageFile.exists()) {
        rescannedSourceImageFile.delete();
        log.d("deleted previous image source file $_rescannedSourceImagePath");
      }
    }
  }

  Stream<VrpPreviewState> mapSubmitVrpToState(SubmitVRP event) async* {
    var dir = await getApplicationDocumentsDirectory();

    var audioNotePath = await handleAudioNote(event, dir);

    var imgSourcePath = await handleSourceImageEvent(dir, event);

    var address = _addressController.text.trim();

    if (!event.edit) {
      // create a new record
      database.addVrpRecord(FoundVrpRecordsCompanion.insert(
          type: Value(event.record.type),
          date: Value(event.record.date),
          top: event.record.top,
          left: event.record.left,
          width: event.record.width,
          height: event.record.height,
          firstPart: event.record.firstPart,
          secondPart: event.record.secondPart,
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          note: _noteController.text,
          audioNotePath: audioNotePath,
          sourceImagePath: imgSourcePath));
      log.d("Successfully added a new VrpRecord to the database");
    } else {
      // update the existing record
      database.updateEntry(event.record.copyWith(
          address: address,
          note: _noteController.text,
          latitude: position.latitude,
          longitude: position.longitude,
          audioNotePath: audioNotePath,
          sourceImagePath: imgSourcePath));
    }

    yield VrpSubmitted();
  }

  Stream<VrpPreviewState> _mapGetAddressByPositionToState() async* {
    yield PositionLoading();
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    final permission = await geolocator.checkGeolocationPermissionStatus();

    if (!(await geolocator.isLocationServiceEnabled())) {
      yield PositionFailed(_appLocalizations.translate("vrp_preview_error_position_disabled"));
    } else if (permission == GeolocationStatus.restricted || permission == GeolocationStatus.disabled) {
      log.e("enum is" + (await geolocator.checkGeolocationPermissionStatus()).toString());
      yield PositionFailed(_appLocalizations.translate("vrp_preview_error_position_permissions"));
    } else {
      Position position;
      try {
        log.d("Started getting current position");
        position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        log.d("Success fully received device position");
      } catch (e) {
        log.e("'$e' error during position retrieval");
        yield PositionFailed(_appLocalizations.translate("vrp_preview_error_position_unknown"));
      }

      // attempt to get address by location only if it was loaded
      if (position != null) {
        String address;
        this.position = position;

        try {
          List<Placemark> placemarks = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.length > 0) {
            address =
                "${placemarks[0].thoroughfare} ${placemarks[0].name}, ${placemarks[0].locality} ${placemarks[0].postalCode}";
            _addressController.text = address;
          }
        } catch (e) {
          log.e("Failed to get placemark from coordinates");
        }

        yield PositionLoaded(
            addressLoaded: address != null, longitude: position.longitude, latitude: position.latitude);
      }
    }
  }

  /// A method that handles the processing of the VRP source image
  Future<String> handleSourceImageEvent(Directory rootDirectory, SubmitVRP event) async {
    if (editing && !rescanned) {
      return Future<String>.value(initialSourceImagePath);
    }
    var tempFile = File(event.record.sourceImagePath);
    var sourceImagesDirectory = Directory(rootDirectory.path + "/" + SOURCE_IMAGES_FOLDER_NAME);
    if (!await sourceImagesDirectory.exists()) {
      await sourceImagesDirectory.create();
      log.d(sourceImagesDirectory.path + " created");
    } else {
      log.d(sourceImagesDirectory.path + " already exists");
    }

    var storePath = sourceImagesDirectory.path + "/" + p.basename(tempFile.path);

    log.d("Store path is =$storePath");

    try {
      tempFile.copy(storePath);
    } catch (err) {
      log.e("caught error: $err");
    }

    if (editing) {
      var previousImageSourceFile = File(initialSourceImagePath);
      if (await previousImageSourceFile.exists()) {
        previousImageSourceFile.delete();
        log.d("deleted previous image source file $initialSourceImagePath");
      }
    }

    return Future<String>.value(storePath);
  }

  /// Handles the processing of an audio note
  Future<String> handleAudioNote(SubmitVRP event, Directory rootDirectory) async {
    var result = event.audioNotePath;
    if (event.audioNoteEdited) {
      if (event.audioNoteDeleted) {
        result = "";
      } else {
        // copy the audio file from the temp directory and move it to the persistent one
        var audioNotesDirectory = Directory(rootDirectory.path + "/" + AUDIO_NOTES_FOLDER_NAME);

        if (!await audioNotesDirectory.exists()) {
          await audioNotesDirectory.create();
        }

        var audioStorePath = audioNotesDirectory.path + "/" + p.basename(File(event.audioNotePath).path);
        var tempFile = File(event.audioNotePath);

        try {
          log.d("Copied a new audio note");
          tempFile.copy(audioStorePath);
          result = audioStorePath;
        } catch (err) {
          log.e("caught error: $err");
        }
      }
    }
    if (event.audioNoteEdited) {
      log.d("deleting previous audio note");
      var previousNoteFile = File(event.record.audioNotePath);
      if (await previousNoteFile.exists()) {
        await previousNoteFile.delete();
        log.d("Deleted previous audio note file=${previousNoteFile.path}");
      } else {
        log.d("Did not delete previous audio note file");
      }
    }

    return Future.value(result);
  }

  /// Creates an instance of [CameraPosition] with the initial position of place where the VRP was scanned
  CameraPosition getInitialMapPosition() {
    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.4746,
    );
  }

  /// Returns coordinates of the location where the VRP was scanned
  LatLng getMapMarkerPosition() {
    return LatLng(position.latitude, position.longitude);
  }
}
