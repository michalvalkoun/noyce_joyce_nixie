import 'package:flutter/material.dart';
import 'device.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NixieApp",
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFFF5F5F5)),
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
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                    "ADD NEW DEVICES",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_right_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
          Device(),
        ],
      )),
    );
  }
}
