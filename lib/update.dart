import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

import 'my_app_bar.dart';

class Update extends StatelessWidget {
  const Update({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        icon: Icons.settings,
        title: 'Update',
        widget: AppSettings.openBluetoothSettings,
        isNavigator: false,
      ),
    );
  }
}
