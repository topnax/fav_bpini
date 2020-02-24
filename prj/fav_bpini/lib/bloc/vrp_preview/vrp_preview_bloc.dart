import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:favbpini/database/database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/vrp.dart';
import './bloc.dart';
import 'package:path/path.dart' as p;
import 'package:moor/src/runtime/data_class.dart';

const sourceImagesFolderName = "source";

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
      if (!event.edit) {
        var tempFile = File(event.record.sourceImagePath);

        debugPrint("tempFile@${tempFile.path} exists=${tempFile.existsSync()}");

        var dir = await getApplicationDocumentsDirectory();

        var t = Directory(dir.path + "/" + sourceImagesFolderName);
        if (!await t.exists()) {
          await t.create();
          debugPrint(t.path + " created");
        } else {
          debugPrint(t.path + " already exists");
        }

        var storePath = t.path + "/" + p.basename(tempFile.path);

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
            sourceImagePath: event.record.sourceImagePath));
        debugPrint("Successfully added a new VrpRecord to the database");
      } else {
        database.updateEntry(event.record.copyWith(address: address, note: _noteController.text));
      }

      yield VrpSubmitted();
    } else if (event is RecordStarted) {

    } else if (event is RecordStopped) {

    }
  }

  @override
  Future<Function> close() {

    return super.close();
  }


}
