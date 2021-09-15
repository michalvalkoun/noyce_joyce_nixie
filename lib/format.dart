// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Format extends StatelessWidget {
  const Format({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      totalSwitches: 2,
      minWidth: 100,
      labels: ['Format 12', 'Format 24'],
      inactiveBgColor: Colors.grey.shade200,
      activeBgColor: [Colors.amber.shade300],
      inactiveFgColor: Colors.grey.shade700,
      cornerRadius: 15,
    );
  }
}
