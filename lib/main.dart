import 'package:flutter/material.dart';
import 'my_carousel.dart';

import 'main/add_new_devices.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF12345)), // 0xFFF5F5F5
      home: Scaffold(
          body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: 20, top: 40),
            child: Image.asset(
              "assets/logo_horizontal.png",
              height: 60,
            ),
          ),
          AddNewDevices(),
          MyCarousel(),
        ],
      )),
    );
  }
}
