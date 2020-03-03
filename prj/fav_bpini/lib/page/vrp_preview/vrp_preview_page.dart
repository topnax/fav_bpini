import 'dart:async';
import 'dart:io';

import 'package:favbpini/bloc/vrp_preview/main/bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_event.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_state.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_event.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_state.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/utils/preferences.dart';
import 'package:favbpini/vrp_locator/vrp_locator.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:favbpini/widget/vrp_source_detail_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VrpPreviewPageArguments {
  FoundVrpRecord _record;
  final bool edit;

  VrpPreviewPageArguments(this._record, {this.edit = false});
}

class VrpPreviewPage extends StatefulWidget {
  final VrpPreviewPageArguments arguments;

  @override
  VrpPreviewPageState createState() => VrpPreviewPageState(arguments._record, arguments.edit);

  VrpPreviewPage(this.arguments);
}

class VrpPreviewPageState extends State<VrpPreviewPage> with SingleTickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  FoundVrpRecord _record;
  final bool _edit;

  PersistentBottomSheetController bottomSheetController;

  bool bottomSheetShown = false;

  VrpPreviewPageState(this._record, this._edit) {
    debugPrint("VrpPreviewPageState constructor");
    _addressController.text = _record.address;
    _noteController.text = _record.note;
  }

  static const TextStyle _vrpStyle = TextStyle(fontSize: 60, fontWeight: FontWeight.w600, color: Colors.black);

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 10,
            blurRadius: 5,
            offset: Offset(0, 7), // changes position of shadow
          ),
        ],
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)));
  }

  @override
  Widget build(BuildContext context) {
    var database = Provider.of<Database>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<VrpPreviewBloc>(create: (context) {
          var bloc = VrpPreviewBloc(VRP(_record.firstPart, _record.secondPart), _addressController, _noteController,
              database, _record.sourceImagePath, _edit, _record.latitude, _record.longitude);
          if (!_edit && Provider.of<PreferencesProvider>(context, listen: false).autoPositionLookup) {
            bloc.add(GetAddressByPosition());
          }
          return bloc;
        }),
        BlocProvider<VrpPreviewRecordingBloc>(create: (context) => VrpPreviewRecordingBloc(_record.audioNotePath))
      ],
      child: Builder(
        builder: (context) => WillPopScope(
          onWillPop: () => onPop(context),
          child: Scaffold(
              body: Builder(
            builder: (context) => BlocListener(
              bloc: BlocProvider.of<VrpPreviewBloc>(context),
              listener: (context, state) {
                if (state is VrpSubmitted) {
                  onPop(context);
                } else if (state is PositionFailed) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Chyba při získávání polohy: ${state.error}"),
                  ));
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 36.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            color: Theme.of(context).textTheme.body1.color,
                            onPressed: () {
                              onPop(context);
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    HeadingText(_edit ? "Upravit SPZ" : "Nová SPZ"),
                                    Padding(
                                      padding: EdgeInsets.only(top: 40),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Center(
                                              child: Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Text(
                                                    "Naskenováno ${DateFormat('dd.MM.yyyy HH:mm').format(_record.date)},",
                                                    style: TextStyles.monserratStyle,
                                                  )),
                                            ),
                                            Center(child: _buildVrp(_record.firstPart, _record.secondPart)),
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: FlatButton(
                                                        child: Text("UPRAVIT"),
                                                        onPressed: () async {
                                                          String s = await _asyncInputDialog(context);
                                                          debugPrint(s);
                                                        },
                                                      ),
                                                    ),
                                                    RaisedButton(
                                                      shape: new RoundedRectangleBorder(
                                                        borderRadius: new BorderRadius.circular(18.0),
                                                      ),
                                                      onPressed: () async {
                                                        final result = await Navigator.of(context).pushNamed('/finder',
                                                            arguments: VrpFinderPageArguments(rescan: true));
                                                        if (result is VrpFinderResult) {
                                                          setState(() {
                                                            debugPrint("is vrpfinderresult");
                                                            _record = _record.copyWith(
                                                                firstPart: result.foundVrp.firstPart,
                                                                secondPart: result.foundVrp.secondPart,
                                                                sourceImagePath: result.srcPath,
                                                                top: result.rect.top.toInt(),
                                                                left: result.rect.left.toInt(),
                                                                width: result.rect.width.toInt(),
                                                                height: result.rect.height.toInt());
                                                          });
                                                          var bloc = BlocProvider.of<VrpPreviewBloc>(context);
                                                          if (Provider.of<PreferencesProvider>(context, listen: false)
                                                              .autoPositionLookup) {
                                                            bloc.add(GetAddressByPosition());
                                                          }
                                                          bloc.add(VrpRescanned(result.srcPath));
                                                        } else {
                                                          debugPrint("not vrpfinderesult");
                                                        }
                                                      },
                                                      color: Colors.blue,
                                                      textColor: Colors.white,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 5.0),
                                                            child: Icon(Icons.replay),
                                                          ),
                                                          Text("Znovu".toUpperCase(), style: TextStyle(fontSize: 16)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: HeadingText(
                                            "Adresa",
                                            fontSize: 22,
                                          ),
                                        ),
                                        BlocBuilder(
                                            bloc: BlocProvider.of<VrpPreviewBloc>(context),
                                            builder: (context, state) {
                                              if ((BlocProvider.of<VrpPreviewBloc>(context).position.latitude != 0 &&
                                                  BlocProvider.of<VrpPreviewBloc>(context).position.longitude != 0)) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 22.0),
                                                  child: IconButton(
                                                    icon: Icon(Icons.map),
                                                    onPressed: () {
                                                      if (!bottomSheetShown) {
                                                        BlocProvider.of<VrpPreviewBloc>(context).mapController =
                                                            Completer();
                                                        bottomSheetShown = true;
                                                        showBottomSheet(
                                                                context: context,
                                                                builder: (context) => _buildMapBottomSheetContent())
                                                            .closed
                                                            .whenComplete(() {
                                                          bottomSheetShown = false;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                );
                                              } else {
                                                return Container();
                                              }
                                            })
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(22.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _addressController,
                                              decoration: InputDecoration(
                                                hintText: "Adresa, kde byla SPZ naskenována",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.amber,
                                                    style: BorderStyle.solid,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          BlocBuilder<VrpPreviewBloc, VrpPreviewState>(
                                              bloc: BlocProvider.of<VrpPreviewBloc>(context),
                                              builder: (BuildContext context, VrpPreviewState state) {
                                                if (!(state is PositionLoading)) {
                                                  return IconButton(
                                                      icon: Icon(Icons.location_on),
                                                      color: Colors.blueAccent,
                                                      onPressed: () => {
                                                            BlocProvider.of<VrpPreviewBloc>(context)
                                                                .add(GetAddressByPosition())
                                                          });
                                                } else {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: CircularProgressIndicator(),
                                                  );
                                                }
                                              })
                                        ],
                                      ),
                                    ),
                                    HeadingText(
                                      "Poznámka",
                                      fontSize: 22,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(22.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _noteController,
                                              decoration: InputDecoration(
                                                hintText: "Vlastní poznámka",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.amber,
                                                    style: BorderStyle.solid,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          BlocListener(
                                            bloc: BlocProvider.of<VrpPreviewRecordingBloc>(context),
                                            condition: (previousState, currentState) {
                                              if (currentState is RecordingSuccess &&
                                                  !(previousState is RecordingInProgress)) {
                                                return false;
                                              }
                                              return true;
                                            },
                                            listener: (context, state) {
                                              if (state is PlaybackFailed) {
                                                Scaffold.of(context).showSnackBar(SnackBar(
                                                  content: Text(state.error),
                                                ));
                                              } else if (state is RecordingFailed) {
                                                Scaffold.of(context).showSnackBar(SnackBar(
                                                  content: Text(state.error),
                                                ));
                                              } else if (state is RecordingSuccess) {
                                                Scaffold.of(context).showSnackBar(SnackBar(
                                                  content: Text("Poznámka úspěšně nahrána"),
                                                ));
                                              }
                                            },
                                            child: BlocBuilder(
                                                bloc: BlocProvider.of<VrpPreviewRecordingBloc>(context),
                                                builder: (context, state) {
                                                  if (state is InitialVrpPreviewRecordingState) {
                                                    return IconButton(
                                                        icon: Icon(Icons.mic),
                                                        color: Colors.blueAccent,
                                                        onPressed: () =>
                                                            BlocProvider.of<VrpPreviewRecordingBloc>(context)
                                                                .add(RecordingStarted()));
                                                  } else if (state is RecordingInProgress) {
                                                    return Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                              DateFormat('mm:ss:SS', 'en_US').format(state.currentTime),
                                                              style: Theme.of(context).textTheme.body2),
                                                        ),
                                                        IconButton(
                                                            icon: Icon(Icons.stop),
                                                            color: Colors.blueAccent,
                                                            onPressed: () =>
                                                                BlocProvider.of<VrpPreviewRecordingBloc>(context)
                                                                    .add(RecordingStopped()))
                                                      ],
                                                    );
                                                  } else if (state is RecordingSuccess) {
                                                    return Row(
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(Icons.delete),
                                                            color: Colors.redAccent,
                                                            onPressed: () =>
                                                                BlocProvider.of<VrpPreviewRecordingBloc>(context)
                                                                    .add(RecordRemoved())),
                                                        IconButton(
                                                            icon: Icon(Icons.play_arrow),
                                                            color: Colors.blueAccent,
                                                            onPressed: () =>
                                                                BlocProvider.of<VrpPreviewRecordingBloc>(context)
                                                                    .add(PlaybackStarted())),
                                                      ],
                                                    );
                                                  } else if (state is PlaybackInProgress) {
                                                    return Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: Text(
                                                              DateFormat('mm:ss:SS', 'en_US').format(state.currentTime),
                                                              style: Theme.of(context).textTheme.body2),
                                                        ),
                                                        IconButton(
                                                            icon: Icon(Icons.stop),
                                                            color: Colors.blueAccent,
                                                            onPressed: () =>
                                                                BlocProvider.of<VrpPreviewRecordingBloc>(context)
                                                                    .add(PlaybackStopped()))
                                                      ],
                                                    );
                                                  }

                                                  return Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text("Chyba"),
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                    HeadingText(
                                      "Zdroj",
                                      fontSize: 22,
                                    ),
                                    _buildSourcePreview(),
//                                        if (BlocProvider.of<VrpPreviewBloc>(context).position.latitude != 0 && BlocProvider.of<VrpPreviewBloc>(context).position.longitude != 0)
//                                        AspectRatio(
//                                          aspectRatio: 16.toDouble()/9.toDouble(),
//                                          child: GoogleMap(
//                                            mapToolbarEnabled: false,
//                                            mapType: MapType.normal,
//                                            initialCameraPosition: BlocProvider.of<VrpPreviewBloc>(context).getMapPosition(),
//                                            markers: {Marker(
//                                              // This marker id can be anything that uniquely identifies each marker.
//                                              markerId: MarkerId(""),
//                                              position: BlocProvider.of<VrpPreviewBloc>(context).getMapMarkerPosition(),
//                                              infoWindow: InfoWindow(
//                                                title: 'Pozice při naskenování',
//                                                snippet: _record.address,
//                                              ),
//                                              icon: BitmapDescriptor.defaultMarker,
//                                            )},
//                                            onMapCreated: (GoogleMapController controller) {
//                                              BlocProvider.of<VrpPreviewBloc>(context).mapController.complete(controller);
//                                            },
//                                          ),
//                                        ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(7.0),
                                    ),
                                    onPressed: () {
                                      onPop(context);
                                    },
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5.0),
                                          child: Icon(Icons.close),
                                        ),
                                        Text("Zrušit", style: TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(7.0),
                                    ),
                                    onPressed: () {
                                      var recordingBloc = BlocProvider.of<VrpPreviewRecordingBloc>(context);
                                      debugPrint("onPressed3.1");

                                      var mainBloc = BlocProvider.of<VrpPreviewBloc>(context);
                                      debugPrint("onPressed4");

                                      mainBloc.add(SubmitVRP(_record,
                                          edit: _edit,
                                          audioNotePath: recordingBloc.audioPath,
                                          audioNoteEdited: recordingBloc.audioNoteEdited,
                                          audioNoteDeleted: recordingBloc.deletedNote));
                                    },
                                    color: Colors.orange,
                                    textColor: Colors.white,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5.0),
                                          child: Icon(Icons.done),
                                        ),
                                        Text("Uložit", style: TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }

  GoogleMap _buildGoogleMap(BuildContext context) {
    return GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      mapToolbarEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: BlocProvider.of<VrpPreviewBloc>(context).getMapPosition(),
      markers: {
        Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId(""),
          position: BlocProvider.of<VrpPreviewBloc>(context).getMapMarkerPosition(),
          infoWindow: InfoWindow(
            title: 'Pozice při naskenování',
            snippet: _record.address,
          ),
          icon: BitmapDescriptor.defaultMarker,
        )
      },
      onMapCreated: (GoogleMapController controller) {
        BlocProvider.of<VrpPreviewBloc>(context).mapController.complete(controller);
      },
    );
  }

  Future<bool> onPop(BuildContext context) async {
    if (bottomSheetShown) {
      return true;
    }
    BlocProvider.of<VrpPreviewBloc>(context).add(DiscardVRP(_record.sourceImagePath));
    if (_edit) {
      debugPrint("popping");
      Navigator.pop(context);
      debugPrint("did pop");
    } else {
      debugPrint("Popping until");
      Navigator.popUntil(context, ModalRoute.withName("/"));
    }
    return false;
  }

  Widget _buildSourcePreview() {
    debugPrint("Showing ${_record.sourceImagePath}");
    return BlocProvider(
      create: (context) => VrpSourceDetailBloc(),
      child: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder(
            bloc: BlocProvider.of<VrpSourceDetailBloc>(context),
            builder: (context, state) {
              return GestureDetector(
                onTapDown: (_) async {
                  debugPrint("onTapDown");
                  File image = new File(_record.sourceImagePath); // Or any other way to get a File instance.
                  var decodedImage = await decodeImageFromList(image.readAsBytesSync());
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(OnHighlight(
                      Rect.fromLTWH(_record.left.toDouble(), _record.top.toDouble(), _record.width.toDouble(),
                          _record.height.toDouble()),
                      Size(decodedImage.width.toDouble(), decodedImage.height.toDouble())));
                },
                onTapUp: (_) {
                  debugPrint("onTapUp");
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(OnHideHighlight());
                },
                onTapCancel: () {
                  debugPrint("onTapCancel");
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(OnHideHighlight());
                },
                child: Stack(
                  children: [
                    Image.file(File(_record.sourceImagePath)),
                    if (state is HighlightedDetail)
                      AspectRatio(
                          aspectRatio: state.imageSize.width / state.imageSize.height,
                          child: CustomPaint(painter: VrpSourceDetailPainter(state.highlightedArea, state.imageSize))),
                    if (state is StaticDetail)
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.remove_red_eye, color: Colors.white),
                          )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVrp(String firstPart, String secondPart) {
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
      child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(firstPart, secondPart)),
    );
  }

  Widget _buildVrpContentRow(String firstPart, String secondPart) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              firstPart,
              style: _vrpStyle,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            Text(
              secondPart,
              style: _vrpStyle,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVrpInner(String firstPart, String secondPart) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[900]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.star_border,
                    color: Colors.yellow,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  Text(
                    "CZ",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
              padding: EdgeInsets.only(top: 0),
              child: _buildVrpContentRow(firstPart, secondPart))
        ],
      ),
    );
  }

  Widget _buildMapBottomSheetContent() {
    return Container(
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(15.0),
        child: Container(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: HeadingText(
                            "Adresa na mapě",
                            fontSize: 22,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: IconButton(
                            icon: Icon(Icons.keyboard_arrow_down),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    child: AspectRatio(
                  aspectRatio: 16.toDouble() / 10.toDouble(),
                  child: FutureBuilder(
                    future: Future<double>.delayed(Duration(milliseconds: 500), () => 1.0),
                    builder: (context, snapshot) => AnimatedOpacity(
                      opacity: snapshot.hasData ? snapshot.data : 0.0,
                      duration: Duration(seconds: 1),
                      child: _buildGoogleMap(context),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String firstPart = _record.firstPart;
    String secondPart = _record.secondPart;
    final formState = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: HeadingText('Ručně upravit SPZ', fontSize: 18, noPadding: true)),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop())
            ],
          ),
          content: Form(
            autovalidate: true,
            key: formState,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLength: 3,
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Tato část nesmí být prázdná";
                          }

                          if (value.length > 3) {
                            return "Tato část musí mít maximálně 3 znaky";
                          }
                          return null;
                        },
                        initialValue: firstPart,
                        decoration: InputDecoration(
                          hintText: "První část SPZ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        onChanged: (newValue) {
                          firstPart = newValue;
                          formState.currentState.validate();
                        },
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLength: 5,
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return "Tato část nesmí být prázdná";
                            }
                            if (value.length > 5) {
                              return "Tato část musí mít maximálně 5 znaků";
                            }
                            return null;
                          },
                          initialValue: secondPart,
                          decoration: InputDecoration(
                            hintText: "Druhá část SPZ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.amber,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          onChanged: (newValue) {
                            secondPart = newValue;
                            formState.currentState.validate();
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                if (formState.currentState.validate()) {
                  setState(() {
                    _record = _record.copyWith(firstPart: firstPart.toUpperCase(), secondPart: secondPart.toUpperCase());
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
