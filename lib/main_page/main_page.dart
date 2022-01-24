import 'package:flutter/material.dart';

import 'my_app_bar.dart';
import 'add_new_devices.dart';
import 'my_carousel.dart';
import 'my_drawer.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const MyDrawer(),
        appBar: const MyAppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AddNewDevices(),
            const MyCarousel(),
          ],
        ));
  }
}
