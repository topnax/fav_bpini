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

        print("${address} loaded");
        yield PositionLoaded(position, address);
        _addressController.text = address;
      } catch (e) {
        print("${e} error");
        yield PositionFailed();
      }
    } else if (event is DiscardVRP) {
      File(event.pathToImage).delete();
      debugPrint("Deleted: ${event.pathToImage}");
    } else if (event is SubmitVRP) {
      var tempFile = File(event.sourceImagePath);

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

        database.addVrpRecord(FoundVrpRecordsCompanion.insert(
            date: Value(event.date),
            top: event.area.top.toInt(),
            left: event.area.left.toInt(),
            width: event.area.width.toInt(),
            height: event.area.height.toInt(),
            firstPart: event.vrp.firstPart,
            secondPart: event.vrp.secondPart,
            latitude: position.latitude,
            longitude: position.longitude,
            address: _addressController.text.trim().isNotEmpty ? _addressController.text : "Nezadáno",
            note: _noteController.text,
            sourceImagePath: storePath));

        debugPrint("Successfully added a new VrpRecord to the database");

        yield VrpSubmitted();
      } catch (err) {
        print("caught error: $err");
      }
    }
  }
}
