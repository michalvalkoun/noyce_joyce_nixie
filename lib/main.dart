import 'package:flutter/material.dart';

import 'my_app_bar.dart';
import 'devices.dart';
import 'my_drawer.dart';
import 'my_carousel.dart';
import 'options_item.dart';
import 'format.dart';
import 'bottom_button.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const buttons = ['Night Mode', 'Hourglass', 'Show Date'];
    return MaterialApp(
      home: Scaffold(
        appBar: MyAppBar(
          icon: Icons.bluetooth,
          title: 'Nixie',
          widget: const Devices(),
          isNavigator: true,
        ),
        drawer: const MyDrawer(),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyCarousel(),
              ...buttons.map((name) => OptionsItem(name: name)),
              const Format(),
              const BottomButton(),
            ]),
      ),
    );
  }
}
