import 'package:flutter/material.dart';
import 'package:nixie_app/device_page/device_page.dart';

class Device extends StatelessWidget {
  final device;
  const Device({Key? key, required this.device}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DevicePage(device: device)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "nixie\n${device.key}",
                      style: TextStyle(
                          fontFamily: "Abraham", fontSize: 30, height: 1),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      "assets/${device.key}.png",
                      width: 200,
                      height: 150,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFCD205),
              ),
              child: Icon(
                device.value,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
