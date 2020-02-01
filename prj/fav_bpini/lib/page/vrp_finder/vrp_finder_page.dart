// A screen that allows users to take a picture using a given camera
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/bloc/vrp_finder/bloc.dart';
import 'package:favbpini/widget/vrp_highlighter_painter.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VrpFinderPage extends StatefulWidget {
  @override
  VrpFinderPageState createState() => VrpFinderPageState();
}

TextStyle _vrpStyle = TextStyle(fontSize: 60, fontFamily: "SfAtarianSystem");

class VrpFinderPageState extends State<VrpFinderPage> {
  var _sigma = 10.0;

  VrpFinderPageState();

  @override
  void dispose() {
    // Make sure to dispose of the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until
        // the controller has finished initializing
        body: BlocProvider(
      builder: (_) => VrpFinderBloc(),
      child: BlocBuilder<VrpFinderBloc, VrpFinderState>(
          builder: (BuildContext context, VrpFinderState state) {
        if (state is CameraInitialState) {
          BlocProvider.of<VrpFinderBloc>(context).dispatch(LoadCamera());
          return Center(child: CircularProgressIndicator());
        } else if (state is CameraLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CameraLoadedState) {
          return _buildCameraPreviewStack(state);
        } else if (state is VrpFoundState) {
//            Navigator.of(context).pushNamed("/found", arguments: state.textBlock);
          return _getVrpPreview(state, context);
        }
        return Center(child: Text("No state found"));
      }),
    ));
  }

  Container _getVrpPreview(VrpFoundState state, BuildContext context) {
    TextElement te1 = state.textLine.elements[0];
    TextElement te2 = state.textLine.elements[1];

    double widthRatio = te1.boundingBox.width / te2.boundingBox.width;
    double spaceBetweenElements = state.textLine.boundingBox.width - (te1.boundingBox.width + te2.boundingBox.width);
    double spaceToLineRatio = spaceBetweenElements / state.textLine.boundingBox.width;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$widthRatio\n$spaceBetweenElements\n$spaceToLineRatio"),
          ),
          _buildVrp(state.textLine.text.split(" ")[0],
              state.textLine.text.split(" ")[1]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                    child: Icon(Icons.replay),
                    onPressed: () => BlocProvider.of<VrpFinderBloc>(context)
                        .dispatch(LoadCamera())),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCameraPreviewStack(CameraLoadedState state) {
    return Builder(
      builder: (context) {
        return Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              // fullscreen camera preview
              CameraPreview(state.controller),

              // blur previous layer
              BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
                  child: Container(color: Colors.blue.withOpacity(0.2))),

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

              // center another camera preview with correct aspect ratio
              Center(
                child: AspectRatio(
                  aspectRatio: state.controller.value.aspectRatio,
                  child: Stack(children: <Widget>[
                    CameraPreview(state.controller),
                    Center(
                        child: Text("\$" + state.ocrText,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16))),
                  ]),
                ),
              ),
              if (state.detectedTextBlocks.length > 0)
                Center(
                  child: AspectRatio(
                    aspectRatio: state.controller.value.aspectRatio,
                    child: CustomPaint(
                      painter: VrpHighlighterPainter(
                          state.detectedTextBlocks, state.imageSize),
                    ),
                  ),
                ),
              if (state.detectedTextBlocks.length > 0)
                Center(child: Text("Hehehehehehehehe")),
            ]);
      },
    );
  }

  Widget _buildVrp(String firstPart, String secondPart) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(6)),
      child: Padding(
          padding: EdgeInsets.all(4),
          child: _buildVrpInner(firstPart, secondPart)),
    );
  }

  Widget _buildVrpContentRow(String firstPart, String secondPart) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
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
}
