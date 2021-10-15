import 'package:flutter/material.dart';
import 'package:nixie_app/device_page/device_page.dart';
import 'package:nixie_app/icon_picker.dart';

class Device extends StatelessWidget {
  final DeviceProp device;
  const Device({Key? key, required this.device}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DevicePage(device: device)));
      },
      child: Container(
        child: Stack(
          children: [
            Container(
              height: 170,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "nixie\n${device.name}",
                      style: TextStyle(
                          fontFamily: "Abraham", fontSize: 30, height: 1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 40),
              alignment: Alignment.topRight,
              child: Image.asset(
                "assets/${device.name}.png",
                scale: 5.5,
              ),
            ),
            Positioned(
              right: 20,
              child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFCD205),
                ),
                child: Icon(
                  device.icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
