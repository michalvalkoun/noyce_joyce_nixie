import 'package:flutter/material.dart';
import 'package:nixie_app/device_page/device_page.dart';
import 'package:nixie_app/icon_picker.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Device extends StatelessWidget {
  final BluetoothDevice device;
  final int rssi;
  late DeviceProp icon;
  Device({
    Key? key,
    required this.device,
    required this.rssi,
  }) : super(key: key) {
    icon = IconPicker.devices.firstWhere((e) {
      print(e.blName);
      print(device.name);
      return e.blName == device.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DevicePage(icon: icon, device: device)));
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20, top: 20),
                        child: Text(
                          "nixie\n${icon.name}",
                          style: TextStyle(
                              fontFamily: "Abraham", fontSize: 30, height: 1),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        child: Text(
                          device.id.toString(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        child: Text(
                          rssi.toString(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 40),
              alignment: Alignment.topRight,
              child: Image.asset(
                "assets/${icon.name}.png",
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
                  icon.icon,
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
