import 'package:flutter/material.dart';
import 'device.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devices = ["clock", "radio", "alarm"];
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: 20, top: 40),
            child: Image.asset(
              "assets/logo_horizontal.png",
              height: 40,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 40, bottom: 20, left: 20),
            child: Text(
              "SEARCH RESULTS:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                ...devices.map((name) => Device(name: name)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
