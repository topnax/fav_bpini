import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:favbpini/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';

class FilterRecordsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        title: AppLocalizations.of(context).translate("vrp_filter_dialog_title"),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilterDialogRow(context, null, label: AppLocalizations.of(context).translate("vrp_type_all")),
              for (var type in VRPType.values) _buildFilterDialogRow(context, type),
            ],
          ),
        ));
  }

  Padding _buildFilterDialogRow(BuildContext context, VRPType type, {String label}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: type != null ? Colors.blueAccent : Colors.orange,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.of(context).pop(FilterDialogResult(type)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  type != null ? type.getName(context) : label,
                  style: TextStyles.monserratStyle.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterDialogResult {
  final VRPType type;

  FilterDialogResult(this.type);
}
