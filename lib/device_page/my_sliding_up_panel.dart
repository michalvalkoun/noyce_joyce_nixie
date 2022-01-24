import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:nixie_app/icon_picker.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'my_switch.dart';
import 'my_slider.dart';

class MySlidingUpPanel extends StatelessWidget {
  final BluetoothDevice device;
  final DeviceProp icon;
  const MySlidingUpPanel({Key? key, required this.device, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PanelController _pc = PanelController();
    return SlidingUpPanel(
      controller: _pc,
      minHeight: 40,
      maxHeight: 250,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      panel: Column(
        children: [
          InkWell(
            onTap: () {
              if (_pc.isPanelOpen)
                _pc.close();
              else
                _pc.open();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  topLeft: Radius.circular(12.0),
                ),
              ),
              child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MySlider(name: "Pouring effect"),
              MySlider(name: "Night mode"),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MySwitch(name: "Show date"),
                    MySwitch(name: "12h format"),
                  ],
                ),
              ),
            ],
          ),
          if (device.name == "alarm")
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(top: 20, right: 20),
              child: ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 30),
                      child: Text("Set alarm"),
                    ),
                    Icon(Icons.notifications_active),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  primary: Color(0xFFFCD205),
                  onPrimary: Colors.black,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
