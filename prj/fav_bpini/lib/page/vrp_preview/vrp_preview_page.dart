import 'dart:io';

import 'package:favbpini/bloc/vrp_preview/bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_event.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_state.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/page/vrp_finder/vrp_finder_page.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:favbpini/widget/vrp_source_detail_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final FoundVrpRecord _record;
  final bool _edit;

  VrpPreviewPageState(this._record, this._edit) {
    debugPrint("VrpPreviewPageState constructor");
    _addressController.text = _record.address;
    _noteController.text = _record.note;
  }

  static const TextStyle _vrpStyle = TextStyle(fontSize: 60, fontWeight: FontWeight.w600, color: Colors.black);

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.red, //                   <--- border color
        width: 5.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var database = Provider.of<Database>(context);
    return Scaffold(
        body: BlocProvider(
      create: (BuildContext context) =>
          VrpPreviewBloc(VRP(_record.firstPart, _record.secondPart), _addressController, _noteController, database),
      child: Builder(
        builder: (context) => BlocListener(
          bloc: BlocProvider.of<VrpPreviewBloc>(context),
          listener: (context, state) {
            if (state is VrpSubmitted) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Záznam uložen"),
              ));
              Navigator.pushNamed(context, "/");
            } else if (state is PositionFailed) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Nelze získat pozici"),
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
                          BlocProvider.of<VrpPreviewBloc>(context).add(DiscardVRP(_record.sourceImagePath));
                          Navigator.of(context).pushNamed(
                            '/',
                          );
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
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              "Naskenováno ${DateFormat('dd.MM.yyyy HH:mm').format(_record.date)},",
                                              style: TextStyles.monserratStyle,
                                            )),
                                        Center(child: _buildVrp(_record.firstPart, _record.secondPart)),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                            shape: new RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(18.0),
                                            ),
                                            onPressed: () {
                                              BlocProvider.of<VrpPreviewBloc>(context)
                                                  .add(DiscardVRP(_record.sourceImagePath));
                                              Navigator.of(context).pushNamed(
                                                '/finder', arguments: VrpFinderPageArguments(edit: _edit, record: _record)
                                              );
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                HeadingText(
                                  "Adresa",
                                  fontSize: 22,
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
                                      IconButton(icon: Icon(Icons.mic),onPressed: (){})
                                    ],
                                  ),
                                ),
                                HeadingText(
                                  "Zdroj",
                                  fontSize: 22,
                                ),
                                _buildSourcePreview()
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
                                  BlocProvider.of<VrpPreviewBloc>(context).add(DiscardVRP(_record.sourceImagePath));
                                  Navigator.of(context).pushNamed(
                                    '/',
                                  );
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
                                  var bloc = BlocProvider.of<VrpPreviewBloc>(context);
                                  bloc.add(SubmitVRP(_record, edit: _edit));
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
      ),
    ));
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
                  File image = new File(_record.sourceImagePath); // Or any other way to get a File instance.
                  var decodedImage = await decodeImageFromList(image.readAsBytesSync());
                  BlocProvider.of<VrpSourceDetailBloc>(context).add(OnHighlight(
                      Rect.fromLTWH(_record.left.toDouble(), _record.top.toDouble(), _record.width.toDouble(),
                          _record.height.toDouble()),
                      Size(decodedImage.width.toDouble(), decodedImage.height.toDouble())));
                },
                onTapUp: (_) => BlocProvider.of<VrpSourceDetailBloc>(context).add(OnHideHighlight()),
                onTapCancel: () => BlocProvider.of<VrpSourceDetailBloc>(context).add(OnHideHighlight()),
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
}
