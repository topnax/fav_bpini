import 'dart:async';
import 'dart:io';

import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/bloc/vrp_preview/main/bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_bloc.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_event.dart';
import 'package:favbpini/bloc/vrp_preview/recording/vrp_preview_recording_state.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_event.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_state.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/main.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/utils/preferences.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:favbpini/vrp_locator/vrp_finder.dart';
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
  static TextStyle _vrpStyle =
      TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 11, fontWeight: FontWeight.w600, color: Colors.black);
  static const TextStyle _vrpStyleSmaller = TextStyle(fontSize: 42, fontWeight: FontWeight.w600, color: Colors.black);

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  FoundVrpRecord _record;
  final bool _edit;

  PersistentBottomSheetController bottomSheetController;
  bool bottomSheetShown = false;

  VrpPreviewPageState(this._record, this._edit) {
    _addressController.text = _record.address;
    _noteController.text = _record.note;
  }

  @override
  Widget build(BuildContext context) {
    var database = Provider.of<Database>(context);
    var localizations = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<VrpPreviewBloc>(create: (context) {
          var bloc = VrpPreviewBloc(
              VRP(_record.firstPart, _record.secondPart, VRPType.values[_record.type]),
              _addressController,
              _noteController,
              database,
              _record.sourceImagePath,
              _edit,
              localizations,
              _record.latitude,
              _record.longitude);
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
          child: Scaffold(body: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) => BlocListener(
        bloc: BlocProvider.of<VrpPreviewBloc>(context),
        listener: (context, state) {
          if (state is VrpSubmitted) {
            onPop(context);
          } else if (state is PositionFailed) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                  "${AppLocalizations.of(context).translate("vrp_preview_error_while_gathering_location")}: ${state.error}"),
            ));
          } else if (state is PositionLoaded) {
            String message;
            if (state.addressLoaded) {
              message = AppLocalizations.of(context).translate("vrp_preview_page_position_loaded_with_address");
            } else {
              message = AppLocalizations.of(context).translate("vrp_preview_page_position_loaded");
            }
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(message),
            ));
          }
        },
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + SizeConfig.safeBlockVertical * 2.5),
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
                      iconSize: SizeConfig.blockSizeHorizontal * 7,
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
                              HeadingText(_edit
                                  ? AppLocalizations.of(context).translate("vrp_preview_page_title_edit")
                                  : AppLocalizations.of(context).translate("vrp_preview_page_title_edit")),
                              Padding(
                                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
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
                                              "${AppLocalizations.of(context).translate("vrp_preview_page_scanned_at")} ${DateFormat('dd.MM.yyyy HH:mm').format(_record.date)},",
                                              style: TextStyles.monserratStyle,
                                            )),
                                      ),
                                      Center(
                                          child: _buildVrp(VRP(
                                              _record.firstPart, _record.secondPart, VRPType.values[_record.type]))),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              _buildEditButton(context),
                                              _buildRescanButton(context),
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
                                      AppLocalizations.of(context).translate("vrp_preview_page_address"),
                                      fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                                    ),
                                  ),
                                  _buildShowInMapIcon(context)
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
                                          hintText:
                                              AppLocalizations.of(context).translate("vrp_preview_page_address_hint"),
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
                                    _buildGetLocationIcon(context)
                                  ],
                                ),
                              ),
                              HeadingText(
                                AppLocalizations.of(context).translate("vrp_preview_page_note"),
                                fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                              ),
                              _buildNoteSection(context),
                              HeadingText(
                                AppLocalizations.of(context).translate("vrp_preview_page_source"),
                                fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                              ),
                              _buildSourcePreview(),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 1.5),
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
                                  Text(AppLocalizations.of(context).translate("cancel"),
                                      style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                            RaisedButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(7.0),
                              ),
                              onPressed: () {
                                var recordingBloc = BlocProvider.of<VrpPreviewRecordingBloc>(context);
                                var mainBloc = BlocProvider.of<VrpPreviewBloc>(context);

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
                                  Text(AppLocalizations.of(context).translate("save"), style: TextStyle(fontSize: 18)),
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
    );
  }

  Padding _buildNoteSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate("vrp_preview_page_note_hint"),
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
              if (currentState is RecordingSuccess && !(previousState is RecordingInProgress)) {
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
                  content: Text(AppLocalizations.of(context).translate("vrp_preview_page_audio_note_success")),
                ));
              }
            },
            child: _buildRecordAudioNoteControls(context),
          )
        ],
      ),
    );
  }

  BlocBuilder<VrpPreviewRecordingBloc, dynamic> _buildRecordAudioNoteControls(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<VrpPreviewRecordingBloc>(context),
        builder: (context, state) {
          if (state is InitialVrpPreviewRecordingState) {
            return IconButton(
                icon: Icon(Icons.mic),
                color: Colors.blueAccent,
                onPressed: () => BlocProvider.of<VrpPreviewRecordingBloc>(context).add(RecordingStarted()));
          } else if (state is RecordingInProgress) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(DateFormat('mm:ss:SS', 'en_US').format(state.currentTime),
                      style: Theme.of(context).textTheme.body2),
                ),
                IconButton(
                    icon: Icon(Icons.stop),
                    color: Colors.blueAccent,
                    onPressed: () => BlocProvider.of<VrpPreviewRecordingBloc>(context).add(RecordingStopped()))
              ],
            );
          } else if (state is RecordingSuccess) {
            return Row(
              children: [
                IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.redAccent,
                    onPressed: () => BlocProvider.of<VrpPreviewRecordingBloc>(context).add(RecordRemoved())),
                IconButton(
                    icon: Icon(Icons.play_arrow),
                    color: Colors.blueAccent,
                    onPressed: () => BlocProvider.of<VrpPreviewRecordingBloc>(context).add(PlaybackStarted())),
              ],
            );
          } else if (state is PlaybackInProgress) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(DateFormat('mm:ss:SS', 'en_US').format(state.currentTime),
                      style: Theme.of(context).textTheme.body2),
                ),
                IconButton(
                    icon: Icon(Icons.stop),
                    color: Colors.blueAccent,
                    onPressed: () => BlocProvider.of<VrpPreviewRecordingBloc>(context).add(PlaybackStopped()))
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLocalizations.of(context).translate("error")),
          );
        });
  }

  BlocBuilder<VrpPreviewBloc, VrpPreviewState> _buildGetLocationIcon(BuildContext context) {
    return BlocBuilder<VrpPreviewBloc, VrpPreviewState>(
        bloc: BlocProvider.of<VrpPreviewBloc>(context),
        builder: (BuildContext context, VrpPreviewState state) {
          if (!(state is PositionLoading)) {
            return IconButton(
                icon: Icon(Icons.location_on),
                color: Colors.blueAccent,
                onPressed: () => {BlocProvider.of<VrpPreviewBloc>(context).add(GetAddressByPosition())});
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _buildShowInMapIcon(BuildContext context) {
    return BlocBuilder(
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
                    BlocProvider.of<VrpPreviewBloc>(context).mapController = Completer();
                    bottomSheetShown = true;
                    showBottomSheet(context: context, builder: (context) => _buildMapBottomSheetContent())
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
        });
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FlatButton(
        child: Text(AppLocalizations.of(context).translate("vrp_preview_page_edit")),
        onPressed: () async {
          await _asyncInputDialog(context);
        },
      ),
    );
  }

  Widget _buildRescanButton(BuildContext context) {
    return RaisedButton(
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(18.0),
      ),
      onPressed: () async {
        final result =
            await Navigator.of(context).pushNamed('/finder', arguments: VrpFinderPageArguments(rescan: true));
        if (result is VrpFinderResult) {
          setState(() {
            _record = _record.copyWith(
                type: result.foundVrp.type.index,
                firstPart: result.foundVrp.firstPart,
                secondPart: result.foundVrp.secondPart,
                sourceImagePath: result.srcPath,
                top: result.rect.top.toInt(),
                left: result.rect.left.toInt(),
                width: result.rect.width.toInt(),
                height: result.rect.height.toInt());
          });
          var bloc = BlocProvider.of<VrpPreviewBloc>(context);
          if (_record.latitude != 0 &&
              _record.longitude != 0 &&
              Provider.of<PreferencesProvider>(context, listen: false).autoPositionLookup) {
            bloc.add(GetAddressByPosition());
          }
          bloc.add(VrpRescanned(result.srcPath));
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
          Text(AppLocalizations.of(context).translate("vrp_preview_page_again").toUpperCase(),
              style: TextStyle(fontSize: 16)),
        ],
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
            title: AppLocalizations.of(context).translate("vrp_preview_page_dialog_position_title"),
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
      Navigator.pop(context);
    } else {
      Navigator.popUntil(context, ModalRoute.withName("/"));
    }
    return false;
  }

  Widget _buildSourcePreview() {
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
                  File image = new File(_record.sourceImagePath); // Or any other way to get a File instance.
                  var decodedImage = await decodeImageFromList(image.readAsBytesSync());
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(Highlighted(
                      Rect.fromLTWH(_record.left.toDouble(), _record.top.toDouble(), _record.width.toDouble(),
                          _record.height.toDouble()),
                      Size(decodedImage.width.toDouble(), decodedImage.height.toDouble())));
                },
                onTapUp: (_) {
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(NotHighlighted());
                },
                onTapCancel: () {
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(NotHighlighted());
                },
                child: Stack(
                  children: [
                    Image.file(File(_record.sourceImagePath)),
                    if (state is HighlightedDetail)
                      AspectRatio(
                          aspectRatio: state.imageSize.width / state.imageSize.height,
                          child: CustomPaint(painter: VrpSourceDetailPainter(state.highlightedArea, state.imageSize))),
                    if (state is ClassicDetail)
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

  Widget _buildVrp(VRP vrp) {
    if (vrp.type == VRPType.ONE_LINE_CLASSIC) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(vrp.firstPart, vrp.secondPart)),
      );
    } else if (vrp.type == VRPType.ONE_LINE_VIP) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(vrp.firstPart, vrp.secondPart, vip: true)),
      );
    } else if (vrp.type == VRPType.ONE_LINE_OLD) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(padding: EdgeInsets.all(4), child: _buildVrpInner(vrp.firstPart, vrp.secondPart, old: true)),
      );
    } else if (vrp.type == VRPType.TWO_LINE_BIKE || vrp.type == VRPType.TWO_LINE_OTHER) {
      return Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
        child: Padding(
            padding: EdgeInsets.all(4), child: _buildVrpInnerTwoRows(vrp.firstPart, vrp.secondPart, bike: true)),
      );
    }
  }

  Widget _buildVrpContentRow(String firstPart, String secondPart, {vip = false, twoRows = false}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: !twoRows ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  firstPart,
                  style: vip ? _vrpStyleSmaller : _vrpStyle,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 3),
                ),
                if (!twoRows)
                  Text(
                    secondPart,
                    style: vip ? _vrpStyleSmaller : _vrpStyle,
                  )
              ],
            ),
          ),
          if (twoRows)
            Text(
              secondPart,
              style: vip ? _vrpStyleSmaller : _vrpStyle,
            ),
        ],
      ),
    );
  }

  Widget _buildVrpInner(String firstPart, String secondPart, {bool vip = false, old = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[900]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!old)
            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: <Widget>[
                    if (vip)
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                      )
                    else
                      Icon(
                        Icons.blur_circular,
                        color: Colors.yellow,
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    Text(
                      vip ? "VIP" : "CZ",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
              padding: EdgeInsets.only(top: 0),
              child: _buildVrpContentRow(firstPart, secondPart, vip: vip))
        ],
      ),
    );
  }

  Widget _buildVrpInnerTwoRows(String firstPart, String secondPart, {bool bike = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue[900]),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.blur_circular,
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
                  child: _buildVrpContentRow(firstPart, secondPart, twoRows: true))
            ],
          ),
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
                            AppLocalizations.of(context).translate("vrp_preview_page_dialog_position_address_on_a_map"),
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
                      )),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _asyncInputDialog(BuildContext context) async {
    var result = await showDialog<VRP>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return EditVrpDialog(VRP(_record.firstPart, _record.secondPart, VRPType.values[_record.type]));
      },
    );
    if (result != null) {
      setState(() {
        _record = _record.copyWith(
            firstPart: result.firstPart.toUpperCase(),
            secondPart: result.secondPart.toUpperCase(),
            type: result.type.index);
      });
    }
  }
}

class EditVrpDialog extends StatefulWidget {
  final VRP vrp;

  EditVrpDialog(this.vrp);

  @override
  _EditVrpDialogState createState() => new _EditVrpDialogState(vrp);
}

class _EditVrpDialogState extends State<EditVrpDialog> {
  final VRP vrp;
  String _firstPart;
  String _secondPart;
  int _type;

  _EditVrpDialogState(this.vrp) {
    _type = vrp.type.index;
  }

  var _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      title: Row(
        children: [
          Expanded(
              child: HeadingText(AppLocalizations.of(context).translate("vrp_preview_page_edit_dialog_title"),
                  fontSize: 18, noPadding: true)),
          IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop())
        ],
      ),
      content: Form(
        autovalidate: true,
        key: _formState,
        child: SingleChildScrollView(
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
                          return AppLocalizations.of(context)
                              .translate("vrp_preview_page_edit_dialog_this_part_must_not_be_empty");
                        }

                        if (value.length > 3) {
                          return AppLocalizations.of(context)
                              .translate("vrp_preview_page_edit_dialog_this_part_mustnt_be_greater_than_three");
                        }
                        return null;
                      },
                      initialValue: vrp.firstPart,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).translate("vrp_preview_page_edit_dialog_first_part"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.amber,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      onSaved: (newValue) => _firstPart = newValue,
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
                              return AppLocalizations.of(context)
                                  .translate("vrp_preview_page_edit_dialog_this_part_must_not_be_empty");
                            }
                            if (value.length > 5) {
                              return AppLocalizations.of(context)
                                  .translate("vrp_preview_page_edit_dialog_this_part_mustnt_be_greater_than_five");
                            }
                            return null;
                          },
                          initialValue: vrp.secondPart,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).translate("vrp_preview_page_edit_dialog_second_part"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.amber,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          onSaved: (newValue) => _secondPart = newValue),
                    )
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("vrp_preview_page_edit_dialog_type"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: DropdownButton<int>(
                        value: _type,
//                        value: _record.type,
                        items: VRPType.values.map((VRPType type) {
                          return DropdownMenuItem<int>(
                              value: type.index,
                              child: Text(
                                type.getName(context),
                              ));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _type = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                  child: Text(
                    AppLocalizations.of(context).translate("ok"),
                  ),
                  color: Colors.orange,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  onPressed: () {
                    if (_formState.currentState.validate()) {
                      _formState.currentState.save();
                      log.d("form done");
                      log.d(_firstPart);
                      log.d(_secondPart);
                      log.d(VRPType.values[_type].getName(context));
                      Navigator.of(context).pop(VRP(_firstPart, _secondPart, VRPType.values[_type]));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
