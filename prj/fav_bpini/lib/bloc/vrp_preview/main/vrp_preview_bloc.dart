import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moor/src/runtime/data_class.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'bloc.dart';

const sourceImagesFolderName = "source";
const audioNotesFolderName = "audio_notes";

class VrpPreviewBloc extends Bloc<VrpPreviewEvent, VrpPreviewState> {
  final VRP vrp;
  final TextEditingController _addressController;
  final TextEditingController _noteController;
  final Database database;

  var position = Position(longitude: 0, latitude: 0);

  VrpPreviewBloc(this.vrp, this._addressController, this._noteController, this.database);

  @override
  VrpPreviewState get initialState => InitialVrpPreviewState(vrp);

  @override
  Stream<VrpPreviewState> mapEventToState(
    VrpPreviewEvent event,
  ) async* {
    if (event is GetAddressByPosition) {
      yield PositionLoading();
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      try {
        print("Started getting current position");
        position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        print("Got position");

        List<Placemark> placemarks = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);
        var address = "nenalezeno";
        if (placemarks.length > 0) {
          address = "${placemarks[0].thoroughfare}, ${placemarks[0].subLocality} ${placemarks[0].postalCode}";
        }

        print("$address loaded");
        yield PositionLoaded(position, address);
        _addressController.text = address;
      } catch (e) {
        print("$e error");
        yield PositionFailed();
      }
    } else if (event is DiscardVRP) {
//      File(event.pathToImage).delete();
//      debugPrint("Deleted: ${event.pathToImage}");
    } else if (event is SubmitVRP) {
      var dir = await getApplicationDocumentsDirectory();

      var audioNotePath  = await handleAudioNote(event, dir);

      await handleSourceImageEvent(dir, event);

      var address = _addressController.text.trim().isNotEmpty ? _addressController.text : "Nezadáno";

      if (!event.edit) {
        database.addVrpRecord(FoundVrpRecordsCompanion.insert(
            date: Value(event.record.date),
            top: event.record.top,
            left: event.record.left,
            width: event.record.width,
            height: event.record.height,
            firstPart: event.record.firstPart,
            secondPart: event.record.secondPart,
            latitude: event.record.latitude,
            longitude: event.record.longitude,
            address: address,
            note: _noteController.text,
            audioNotePath: audioNotePath,
            sourceImagePath: event.record.sourceImagePath));
        debugPrint("Successfully added a new VrpRecord to the database");
      } else {
        database
            .updateEntry(event.record.copyWith(address: address, note: _noteController.text, audioNotePath: audioNotePath));
      }

      yield VrpSubmitted();
    }
  }

  Future handleSourceImageEvent(Directory rootDirectory, SubmitVRP event) async {
    var tempFile = File(event.record.sourceImagePath);
    var sourceImagesDirectory = Directory(rootDirectory.path + "/" + sourceImagesFolderName);
    if (!await sourceImagesDirectory.exists()) {
      await sourceImagesDirectory.create();
      debugPrint(sourceImagesDirectory.path + " created");
    } else {
      debugPrint(sourceImagesDirectory.path + " already exists");
    }

    var storePath = sourceImagesDirectory.path + "/" + p.basename(tempFile.path);

    debugPrint("Store path is =$storePath");

    try {
      tempFile.copy(storePath);

      debugPrint("Copied =$storePath");
      debugPrint("Successfully added a new VrpRecord to the database");
    } catch (err) {
      // TODO what to do when copying fails?
      print("caught error: $err");
    }
  }

  Future<String> handleAudioNote(SubmitVRP event, Directory rootDirectory) async {
    var result = event.audioNotePath;
    if (event.audioNoteEdited) {
      if (event.audioNoteDeleted) {
        result = "";
      } else {
        // copy the audio file from the temp directory and move it to the persistent one
        var audioNotesDirectory = Directory(rootDirectory.path + "/" + audioNotesFolderName);

        if (!await audioNotesDirectory.exists()) {
          await audioNotesDirectory.create();
        }

        var audioStorePath = audioNotesDirectory.path + "/" + p.basename(File(event.audioNotePath).path);
        var tempFile = File(event.audioNotePath);

        try {
          debugPrint("Copied a new audio note");
          tempFile.copy(audioStorePath);
          result = audioStorePath;
        } catch (err) {
          print("caught error: $err");
        }
      }
    }
    if (event.audioNoteEdited) {
      debugPrint("deleting previous audio note");
      var previousNoteFile = File(event.record.audioNotePath);
      if (await previousNoteFile.exists()) {
        await previousNoteFile.delete();
        debugPrint("Deleted previous audio note file=${previousNoteFile.path}");
      } else {
        debugPrint("Did not delete previous audio note file");
      }
    }

    return Future.value(result);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
