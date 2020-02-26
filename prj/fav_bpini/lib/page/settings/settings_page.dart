import 'package:favbpini/utils/preferences.dart';
import 'package:favbpini/widget/common_texts.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();

  SettingsPage();
}

class SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {

    var darkTheme = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      body: Padding(
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
                      Navigator.pop(context);
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
                            HeadingText("Nastavení"),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: CheckboxListTile(
                                secondary: Icon(Icons.color_lens),
                                title: Text('Tmavé téma'),
                                value: darkTheme.darkTheme,
                                activeColor: Colors.blueAccent,
                                onChanged: (checked) => darkTheme.darkTheme = checked,
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.language),
                              title: Text('Jazyk'),
                              trailing: DropdownButton<String>(
                                value: "Čeština",
                                items: <String>["Čeština", "Angličtina"].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (_) {},
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: Text(""));
                            } else {
                              return Center(child: Text("${snapshot.data.version}+${snapshot.data.buildNumber}", style: Theme.of(context).textTheme.caption,),);
                            }
                          }),
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
}
