import 'package:flutter/material.dart';
import 'package:nixie_app/custom_icons/alarm_icon.dart';

class DeviceProp {
  String name;
  IconData icon;
  DeviceProp(this.name, this.icon);
}

class IconPicker {
  static final devices = [
    DeviceProp("clock", Icons.access_time),
    DeviceProp("radio", Icons.radio),
    DeviceProp("alarm", AlarmIcon.alarm_icon)
  ];
}
