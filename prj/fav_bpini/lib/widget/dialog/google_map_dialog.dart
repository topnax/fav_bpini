import 'package:favbpini/widget/dialog/dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The position of the marker to be shown on the map
  final LatLng markerPosition;

  // The title of the marker
  final String markerTitle;

  GoogleMapDialog({@required this.title, this.markerPosition, this.markerTitle});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      padding: EdgeInsets.only(top: 13),
      title: title,
      child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          child: AspectRatio(
              aspectRatio: 16 / 16,
              child: Stack(
                children: [
                  FutureBuilder(
                    future: Future<double>.delayed(Duration(milliseconds: 500), () => 1.0),
                    builder: (context, snapshot) => AnimatedOpacity(
                      opacity: snapshot.hasData ? snapshot.data : 0.0,
                      duration: Duration(seconds: 1),
                      child: Stack(children: [
                        snapshot.hasData ? _buildGoogleMap(context) : Container(color: Colors.red),
                      ]),
                    ),
                  ),
                  Positioned.fill(
                      child: IgnorePointer(
                    child: FutureBuilder(
                      future: Future.delayed(Duration(milliseconds: 1500)),
                      builder: (context, snapshot) => AnimatedOpacity(
                          opacity: snapshot.connectionState == ConnectionState.done ? 0 : 1,
                          duration: Duration(milliseconds: 1000),
                          child: snapshot.connectionState != ConnectionState.done
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(color: Theme.of(context).dialogBackgroundColor)),
                    ),
                  )),
                ],
              ))),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      ].toSet(),
      mapToolbarEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: markerPosition != null
          ? CameraPosition(
              target: LatLng(markerPosition.latitude, markerPosition.longitude),
              zoom: 14.4746,
            )
          : null,
      markers: {
        markerPosition != null
            ? Marker(
                // This marker id can be anything that uniquely identifies each marker.
                markerId: MarkerId(markerPosition.toString()),
                position: markerPosition,
                icon: BitmapDescriptor.defaultMarker,
              )
            : null,
      },
    );
  }
}
