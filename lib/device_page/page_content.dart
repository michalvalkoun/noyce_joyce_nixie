import 'package:flutter/material.dart';

class PageContent extends StatelessWidget {
  final device;
  const PageContent({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.bottomLeft,
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "nixie\n${device.key}",
                  style:
                      TextStyle(fontFamily: "Abraham", fontSize: 60, height: 1),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, right: 40),
                child: Icon(
                  device.value,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 20, top: 20),
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Text("Connect"),
                  margin: EdgeInsets.only(left: 10, right: 10),
                ),
                Icon(Icons.bluetooth_searching),
              ],
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              primary: Colors.black,
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            ),
          ),
        ),
        Image.asset("assets/${device.key}.png", width: 250),
        ElevatedButton(
          onPressed: () {},
          child: Container(
            child: Text("Synchronize time"),
          ),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: Colors.black,
            padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
          ),
        ),
      ],
    );
  }
}
