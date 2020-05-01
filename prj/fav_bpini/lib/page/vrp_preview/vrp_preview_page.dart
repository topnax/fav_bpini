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
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/utils/preferences.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:favbpini/vrp_locator/vrp_finder.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:favbpini/widget/dialog/edit_vrp_dialog.dart';
import 'package:favbpini/widget/dialog/google_map_dialog.dart';
import 'package:favbpini/widget/vrp/vrp_preview.dart';
import 'package:favbpini/widget/vrp_source_detail_painter.dart';
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
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: SizeConfig.blockSizeHorizontal * 7,
                    color: Theme.of(context).textTheme.body1.color,
                    onPressed: () {
                      onPop(context);
                    },
                  ),
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
                              _buildVrpPreview(context),
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
                              _buildAddressSection(context),
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
                      _buildBottomButtons(context),
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

  Padding _buildAddressSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate("vrp_preview_page_address_hint"),
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
          _buildCoordinates(context)
        ],
      ),
    );
  }

  Padding _buildVrpPreview(BuildContext context) {
    return Padding(
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
                    style: TextStyles.montserratStyle,
                  )),
            ),
            Center(child: VrpPreview(VRP(_record.firstPart, _record.secondPart, VRPType.values[_record.type]))),
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
    );
  }

  Padding _buildBottomButtons(BuildContext context) {
    return Padding(
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
                Text(AppLocalizations.of(context).translate("cancel"), style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
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
          var position = LatLng(BlocProvider.of<VrpPreviewBloc>(context).position.latitude,
              BlocProvider.of<VrpPreviewBloc>(context).position.longitude);
          if (position.latitude != 0 && position.longitude != 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: IconButton(
                icon: Icon(Icons.map),
                onPressed: () async {
                  if (!bottomSheetShown) {
                    BlocProvider.of<VrpPreviewBloc>(context).mapController = Completer();
                    bottomSheetShown = true;
                    await showDialog(
                        context: context,
                        builder: (context) => GoogleMapDialog(
                            title: AppLocalizations.of(context)
                                .translate("vrp_preview_page_dialog_position_address_on_a_map"),
                            markerPosition: position));
                    bottomSheetShown = false;
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
          await _showEditVrpDialog(context);
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

  Widget _buildCoordinates(BuildContext context) {
    return BlocBuilder<VrpPreviewBloc, VrpPreviewState>(builder: (context, state) {
      if (state is PositionLoaded) {
        return _buildCoordinatesLabel(context, LatLng(state.latitude, state.longitude));
      } else {
        if (_record.longitude != 0 && _record.latitude != 0) {
          return _buildCoordinatesLabel(context, LatLng(_record.latitude, _record.longitude));
        } else {
          return Container();
        }
      }
    });
  }

  Widget _buildCoordinatesLabel(BuildContext context, LatLng position) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Text("${position.latitude} °N, ${position.longitude}°E"),
        ));
  }

  _showEditVrpDialog(BuildContext context) async {
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
