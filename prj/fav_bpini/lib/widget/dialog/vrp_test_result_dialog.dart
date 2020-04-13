import 'dart:io';

import 'package:favbpini/utils/vrp_finder_tester.dart';
import 'package:favbpini/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';

class VrpFinderTesterResultDialog extends StatelessWidget {
  final VrpFinderTesterResult _result;

  VrpFinderTesterResultDialog(this._result);

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: "Test results",
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "${_result.testCases.length - _result.failure}",
                      style: _greenTextStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "${_result.failure}",
                      style: _redTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            Text(
              "${(_result.testCases.length - _result.failure) / _result.testCases.length * 100}%",
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Text(
              "${_result.timeTook.toInt()} ms ",
            ),
            Text(
              "avg ${(_result.timeTook.toInt() / _result.testCases.length).ceil()} ms",
              style: _yellowTextStyle,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Text(
              "${_result.attempts} attempts ",
            ),
            Text(
              "avg ${(_result.attempts.toInt() / _result.testCases.length).toStringAsFixed(2)}",
              style: _yellowTextStyle,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            for (var result in _result.testCases) _buildTestCaseRow(result, context)
          ],
        ),
      ),
    );
  }

  static const _greenTextStyle = const TextStyle(color: Colors.green);
  static const _redTextStyle = const TextStyle(color: Colors.red);
  static const _yellowTextStyle = const TextStyle(color: Colors.yellow);

  Widget _buildTestCaseRow(VrpFinderTesterTestCaseResult result, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Image.file(File(result.path)))),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${result.expected.firstPart} ${result.expected.secondPart}",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("-"),
            ),
            if (result.found != null)
              Text("${result.found.firstPart} ${result.found.secondPart}",
                  style: result.found == result.expected ? _greenTextStyle : _redTextStyle),
            if (result.found == null)
              Icon(
                Icons.cancel,
                color: Colors.red,
              )
          ],
        ),
      ),
    );
  }
}
