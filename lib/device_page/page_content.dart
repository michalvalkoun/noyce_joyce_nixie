import 'package:flutter/material.dart';
import 'package:nixie_app/icon_picker.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nixie_app/dfu/just_dfu.dart';

class PageContent extends StatefulWidget {
  final BluetoothDevice device;
  final DeviceProp icon;
  const PageContent({Key? key, required this.device, required this.icon})
      : super(key: key);

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  List<BluetoothService> _services = [];
  bool _connected = false;
  double _currentSliderValue = 0;
  List<String> labels = ['1min', '10min', '30min', '1hod', '3AM'];

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
                  "nixie\n${widget.icon.name}",
                  style:
                      TextStyle(fontFamily: "Abraham", fontSize: 65, height: 1),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, right: 40),
                child: Icon(
                  widget.icon.icon,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          margin: EdgeInsets.only(left: 20),
          child: Text(widget.device.id.id),
        ),
        Container(
          margin: EdgeInsets.only(left: 20, top: 20),
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () async {
              if (_connected) {
                setState(() {
                  _connected = false;
                });
                await widget.device.disconnect();
              } else {
                try {
                  await widget.device.connect();
                } finally {
                  _services = await widget.device.discoverServices();
                  setState(() {
                    _connected = true;
                  });
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Text(_connected ? "Disconnect" : "Connect"),
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
        Container(
          margin: EdgeInsets.only(top: 240),
          child: ElevatedButton(
            onPressed: _connected
                ? () async {
                    _blOn();
                    var mac = _incMac(widget.device.id.id, 15, 17);
                    print(await JustDFU().startDFU(mac));
                  }
                : null,
            child: Container(
              child: Text("Synchronize time BL"),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              primary: Colors.black,
              padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
            ),
          ),
        ),
        // Container(
        //   margin: EdgeInsets.only(top: 270),
        //   child: Slider(
        //     value: _currentSliderValue,
        //     activeColor: Color(0xFFFCD205),
        //     inactiveColor: Colors.black,
        //     max: 4,
        //     divisions: 4,
        //     label: labels[_currentSliderValue.round()],
        //     onChanged: (double value) {
        //       setState(() {
        //         _currentSliderValue = value;
        //       });
        //     },
        //     onChangeEnd: (double value) {
        //       _fallingPeriod(value.round());
        //     },
        //   ),
        // ),
      ],
    );
  }

  _synchronizeTimeDir() async {
    int stamp = (DateTime.now().millisecondsSinceEpoch / 1000 + 3600).round();
    await _services
        .firstWhere((service) => service.uuid.toString().contains('a8ed1400'))
        .characteristics[7]
        .write([
      stamp & 0xFF,
      (stamp >> 8) & 0xFF,
      (stamp >> 16) & 0xFF,
      (stamp >> 24) & 0xFF
    ]);
  }

  _changeTimeFormat() async {
    var tmp = await _services
        .firstWhere((service) => service.uuid.toString().contains('a8ed1400'))
        .characteristics[9]
        .read();
    print(tmp[0]);
    await _services
        .firstWhere((service) => service.uuid.toString().contains('a8ed1400'))
        .characteristics[9]
        .write([tmp[0] == 1 ? 0 : 1]);
  }

  _fallingPeriod(int num) async {
    await _services
        .firstWhere((service) => service.uuid.toString().contains('a8ed1400'))
        .characteristics[8]
        .write([num]);
    var tmp = await _services
        .firstWhere((service) => service.uuid.toString().contains('a8ed1400'))
        .characteristics[8]
        .read();
    print(tmp[0]);
  }

  _blOn() async {
    await _services
        .firstWhere((service) => service.uuid.toString().contains('a8ed1400'))
        .characteristics[6]
        .write([0x99]);
  }

  String _incMac(String mac, int start, int end) {
    if (start < 0 || end < 0) return mac;
    var last = int.parse(mac.substring(start, end), radix: 16);
    if (last != 0xFF) {
      last++;
      mac = mac.replaceRange(start, end, last.toRadixString(16).toUpperCase());
    } else {
      mac = _incMac(mac, start - 3, end - 3);
    }
    return mac;
  }
}
