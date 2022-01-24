import 'package:flutter/material.dart';
import 'package:nixie_app/custom_icons/alarm_icon.dart';

class DeviceProp {
  String name;
  String blName;
  IconData icon;
  DeviceProp(this.name, this.blName, this.icon);
}

class IconPicker {
  static final devices = [
    DeviceProp("clock", "Nixie Clock", Icons.access_time),
    DeviceProp("radio", "Nixie Radio", Icons.radio),
    DeviceProp("alarm", "Nixie Alarm-Clock", AlarmIcon.alarm_icon)
  ];
}
