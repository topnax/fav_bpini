import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../model/vrp.dart';
import './bloc.dart';

class VrpPreviewBloc extends Bloc<VrpPreviewEvent, VrpPreviewState> {
  final VRP vrp;
  final TextEditingController _addressController;

  VrpPreviewBloc(this.vrp, this._addressController);

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
        Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
    }
  }
}
