import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class MySwitch extends StatefulWidget {
  final String name;
  const MySwitch({Key? key, required this.name}) : super(key: key);

  @override
  _MySwitchState createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch> {
  bool _status = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: FlutterSwitch(
            width: 47.0,
            height: 22.0,
            toggleSize: 17.0,
            padding: 2.5,
            value: _status,
            onToggle: (val) {
              setState(() {
                _status = val;
              });
            },
            activeColor: Color(0xFFFCD205),
            inactiveColor: Colors.black,
          ),
        )
      ],
    );
  }
}
