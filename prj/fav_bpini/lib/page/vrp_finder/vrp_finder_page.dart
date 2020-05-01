// A screen that allows users to take a picture using a given camera
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/bloc/vrp_finder/bloc.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:favbpini/vrp_locator/vrp_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VrpFinderPageArguments {
  final bool rescan;

  VrpFinderPageArguments({this.rescan = false});
}

class VrpFinderPage extends StatefulWidget {
  final VrpFinderPageArguments _arguments;

  VrpFinderPage(this._arguments);

  @override
  VrpFinderPageState createState() => VrpFinderPageState(this._arguments.rescan);
}

class VrpFinderPageState extends State<VrpFinderPage> {
  static const _sigma = 10.0;

  /// a flag indicating whether the user is rescanning
  final bool _rescan;

  VrpFinderPageState(this._rescan);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (BuildContext context) => VrpFinderBloc(),
      child: BlocListener<VrpFinderBloc, VrpFinderState>(
        listener: (context, VrpFinderState state) {
          if (state is VrpFoundState) {
            if (!_rescan) {
              Navigator.of(context).pushNamed("/found",
                  arguments: VrpPreviewPageArguments(
                      FoundVrpRecord(
                        id: 0,
                        type: state.result.foundVrp.type.index,
                        firstPart: state.result.foundVrp.firstPart,
                        secondPart: state.result.foundVrp.secondPart,
                        latitude: 0,
                        longitude: 0,
                        address: "",
                        note: "",
                        audioNotePath: "",
                        date: state.date,
                        sourceImagePath: state.pathToImage,
                        top: state.result.rect.top.toInt(),
                        left: state.result.rect.left.toInt(),
                        width: state.result.rect.width.toInt(),
                        height: state.result.rect.height.toInt(),
                      ),
                      edit: false));
            } else {
              state.result.srcPath = state.pathToImage;
              Navigator.pop(context, state.result);
            }
          }
        },
        child: BlocBuilder<VrpFinderBloc, VrpFinderState>(builder: (BuildContext context, VrpFinderState state) {
          if (state is CameraInitialState) {
            BlocProvider.of<VrpFinderBloc>(context).add(LoadCamera());
            return Center(child: CircularProgressIndicator());
          } else if (state is CameraLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CameraLoaded) {
            return _buildCameraPreviewStack(state.controller, List<VrpFinderResult>(), null, 0);
          } else if (state is CameraFailure) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  AppLocalizations.of(context).translate(state.errorDescription),
                  textAlign: TextAlign.center,
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(Icons.arrow_back),
                        ),
                        Text(AppLocalizations.of(context).translate("back"), style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Container();
        }),
      ),
    ));
  }

  Widget _buildCameraPreviewStack(CameraController controller, List<VrpFinderResult> results, Size size, int timeTook) {
    return Builder(
      builder: (context) {
        return Stack(alignment: AlignmentDirectional.topCenter, children: <Widget>[
          // fullscreen camera preview
          CameraPreview(controller),

          // blur previous layer
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
              child: Container(color: Colors.blue.withOpacity(0.2))),

          // center another camera preview with correct aspect ratio
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(children: [
                CameraPreview(controller),
              ]),
            ),
          ),
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}
