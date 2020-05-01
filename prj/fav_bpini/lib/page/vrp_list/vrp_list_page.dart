import 'dart:io';

import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/database/database.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/page/vrp_preview/vrp_preview_page.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:favbpini/widget/common_scaffold.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:favbpini/widget/dialog/filter_records_dialog.dart';
import 'package:favbpini/widget/vrp/vrp_list_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VrpListPage extends StatefulWidget {
  @override
  VrpListPageState createState() => VrpListPageState();

  VrpListPage();
}

class VrpListPageState extends State<VrpListPage> {
  /// currently selected VRP type by which the records should be filtered
  VRPType _typeFilter;

  /// a flag indicating whether the records should be sorted by the chronologically asc/desc
  var _sortByNewest = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return CommonScaffold(
      rightButtonHint: Icon(_sortByNewest ? Icons.arrow_downward : Icons.arrow_upward, size: 20, color: Colors.white),
      onLeftButtonPressed: _openFilterRecordsDialog,
      onRightButtonPressed: () {
        setState(() {
          _sortByNewest = !_sortByNewest;
        });
      },
      child: Container(
        child: _buildVRPHistory(),
      ),
    );
  }

  Widget _buildVRPHistory() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeadingText(
            AppLocalizations.of(context).translate('vrp_list_page_title'),
          ),
          if (_typeFilter != null)
            HeadingText(
              _typeFilter.getName(context),
              fontSize: SizeConfig.blockSizeHorizontal * 5,
            ),
          _buildVrpList(),
        ],
      ),
    );
  }

  Widget _buildVrpList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: StreamBuilder<List<FoundVrpRecord>>(
          stream: Provider.of<Database>(context).watchAllRecords(type: _typeFilter, sortByNewest: _sortByNewest),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length > 0) {
                return ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => _buildRow(context, snapshot.data[index], snapshot),
                );
              } else {
                return Center(
                    child: Text(AppLocalizations.of(context).translate("vrp_list_page_no_record_found"),
                        style: Theme.of(context).textTheme.subhead));
              }
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, FoundVrpRecord record, AsyncSnapshot<List<FoundVrpRecord>> snapshot) {
    return VrpListRow(
        onTap: () => Navigator.of(context).pushNamed("/found", arguments: VrpPreviewPageArguments(record, edit: true)),
        vrp: VRP(record.firstPart, record.secondPart, VRPType.values[record.type]),
        address: record.address.isNotEmpty
            ? record.address
            : AppLocalizations.of(context).translate("vrp_list_address_unspecified"),
        dateTime: record.date,
        key: Key(record.toString()),
        onDismissed: (direction) async {
          setState(() {
            snapshot.data.remove(record);
          });
          Provider.of<Database>(context, listen: false).deleteEntry(record);

          var sourceImage = File(record.sourceImagePath);
          if (await sourceImage.exists()) {
            sourceImage.delete();
          }
        });
  }

  /// displays a filter dialog
  _openFilterRecordsDialog() async {
    var result = await showDialog<FilterDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FilterRecordsDialog();
      },
    );
    if (result != null && result.type != _typeFilter) {
      setState(() {
        _typeFilter = result.type;
      });
    }
  }
}
