import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'search_result.dart';

class NewDevices extends StatelessWidget {
  const NewDevices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "ADDING NEW DEVICES",
        ),
      ),
      body: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SearchResult()));
        },
        child: Container(
          alignment: Alignment.center,
          child: Image.asset(
            "assets/bluetooth_black.png",
          ),
        ),
      ),
    );
  }
}
