import 'dart:io';

import 'package:favbpini/app_localizations.dart';
import 'package:favbpini/utils/preferences.dart';
import 'package:favbpini/utils/size_config.dart';
import 'package:favbpini/utils/vrp_finder_tester.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:favbpini/widget/dialog/vrp_test_result_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();

  SettingsPage();
}

class SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  var _loading = false;
  var _versionTappedCounter = 0;
  static const _versionTappedLimit = 3;

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesProvider>(context);

    return Scaffold(
      body: Padding(
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
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HeadingText(AppLocalizations.of(context).translate('settings_page_title')),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: CheckboxListTile(
                                secondary: Icon(Icons.color_lens),
                                title: Text(AppLocalizations.of(context).translate("settings_page_dark_theme")),
                                value: preferences.darkTheme,
                                activeColor: Colors.blueAccent,
                                onChanged: (checked) => preferences.darkTheme = checked,
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.language),
                              title: Text(AppLocalizations.of(context).translate("settings_page_language")),
                              trailing: DropdownButton<String>(
                                value: preferences.appLanguageCode,
                                items: AppLocalizations.SUPPORTED_LANGUAGES.keys.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(AppLocalizations.SUPPORTED_LANGUAGES[value]),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  preferences.appLanguageCode = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: CheckboxListTile(
                                secondary: Icon(Icons.location_on),
                                title: Text(AppLocalizations.of(context).translate("settings_page_automatic_location")),
                                value: preferences.autoPositionLookup,
                                activeColor: Colors.blueAccent,
                                onChanged: (checked) => preferences.autoPositionLookup = checked,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onVersionTapped,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: Text(""));
                              } else {
                                return Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "${snapshot.data.version}+${snapshot.data.buildNumber}",
                                        style: Theme.of(context).textTheme.caption,
                                      ),
                                      if (_loading)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "performing test...",
                                            style: Theme.of(context).textTheme.caption,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                            }),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onVersionTapped() async {
    _versionTappedCounter++;
    if (_versionTappedCounter >= _versionTappedLimit) {
      _versionTappedCounter = 0;
      List<File> files = await FilePicker.getMultiFile(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );

      if (files.length > 0) {
        setState(() {
          _loading = true;
        });
        var results = await VrpFinderTester().startTestInFolder(files);
        setState(() {
          _loading = false;
        });

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return VrpFinderTesterResultDialog(results);
          },
        );
      }
    }
  }
}
