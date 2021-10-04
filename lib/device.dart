import 'package:flutter/material.dart';

class Device extends StatelessWidget {
  final String name;
  const Device({Key? key, required this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, left: 20),
            child: Text(
              "nixie\n$name",
              style: TextStyle(fontFamily: "Abraham", fontSize: 20, height: 1),
            ),
          ),
          Container(
            child: Image.asset(
              "assets/$name.png",
              width: 200,
              height: 150,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Image.asset(
              "assets/${name}_icon.png",
              scale: 2,
            ),
          ),
        ],
      ),
    );
  }
}
