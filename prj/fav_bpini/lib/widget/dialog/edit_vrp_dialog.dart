import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/model/vrp.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';

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
