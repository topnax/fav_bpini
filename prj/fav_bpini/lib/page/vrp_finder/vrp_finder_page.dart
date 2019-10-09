// A screen that allows users to take a picture using a given camera
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:favbpini/bloc/vrp_finder/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VrpFinderPage extends StatefulWidget {
  @override
  VrpFinderPageState createState() => VrpFinderPageState();
}

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
        }
        return Center(child: Text("No state found"));
      }),
    ));
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
                    Center(child: Text("\$" + state.ocrText, style: TextStyle(color: Colors.white,fontSize: 16))),
                  ]),
                ),
              ),
            ]);
      },
    );
  }
}
