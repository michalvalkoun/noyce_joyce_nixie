import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

import 'my_app_bar.dart';

class Devices extends StatelessWidget {
  const Devices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        icon: Icons.settings,
        title: 'Devices',
        widget: AppSettings.openBluetoothSettings,
        isNavigator: false,
      ),
    );
  }
}
