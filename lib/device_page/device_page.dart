import 'package:flutter/material.dart';

import 'my_app_bar.dart';
import 'page_content.dart';
import 'my_sliding_up_panel.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DevicePage extends StatelessWidget {
  final BluetoothDevice device;
  final icon;

  const DevicePage({
    Key? key,
    required this.device,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: Image.asset("assets/background.png", fit: BoxFit.fill),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 100),
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            "assets/${icon.name}.png",
            width: 350,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MyAppBar(),
          body: Stack(
            children: [
              PageContent(icon: icon, device: device),
              MySlidingUpPanel(icon: icon, device: device),
            ],
          ),
        ),
      ],
    );
  }
}
