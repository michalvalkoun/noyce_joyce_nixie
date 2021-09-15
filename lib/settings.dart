import 'package:flutter/material.dart';

import 'my_app_bar.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Settings',
      ),
    );
  }
}
