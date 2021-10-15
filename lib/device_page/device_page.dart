import 'package:flutter/material.dart';

import 'my_app_bar.dart';
import 'page_content.dart';
import 'my_sliding_up_panel.dart';

class DevicePage extends StatelessWidget {
  final device;
  const DevicePage({Key? key, required this.device}) : super(key: key);

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
            "assets/${device.name}.png",
            width: 350,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MyAppBar(),
          body: Stack(
            children: [
              PageContent(device: device),
              MySlidingUpPanel(device: device),
            ],
          ),
        ),
      ],
    );
  }
}
