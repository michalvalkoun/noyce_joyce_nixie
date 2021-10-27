import 'package:flutter/material.dart';
import 'device.dart';
import 'package:nixie_app/icon_picker.dart';
import 'my_app_bar.dart';
import 'package:nixie_app/dfu/my_dfu.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devices = ["clock", "radio", "clock", "radio", "alarm"];
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 30, bottom: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SEARCH RESULTS:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
                IconButton(
                  padding: EdgeInsets.only(right: 60),
                  icon: Icon(Icons.play_arrow, size: 40),
                  onPressed: null,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                ...devices.map((device) => Device(
                    device: IconPicker.devices
                        .firstWhere((element) => element.name == device))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
