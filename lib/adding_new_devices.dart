import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'search_result/search_result.dart';

class AddingNewDevices extends StatelessWidget {
  const AddingNewDevices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 80,
        title: Container(
          height: 80,
          alignment: Alignment.bottomCenter,
          child: Text("ADDING NEW DEVICES"),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: Icon(Icons.bluetooth_searching, size: 70),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            primary: Colors.black,
          ),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SearchResult())),
        ),
      ),
    );
  }
}
