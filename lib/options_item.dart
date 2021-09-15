import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptionsItem extends StatefulWidget {
  final String name;
  const OptionsItem({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  _OptionsItemState createState() => _OptionsItemState();
}

class _OptionsItemState extends State<OptionsItem> {
  bool isOn = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 250,
      child: SwitchListTile(
        title: Text(
          widget.name,
          style: TextStyle(fontSize: 18),
        ),
        value: isOn,
        onChanged: (value) => setState(() => isOn = value),
        activeColor: Colors.amber.shade300,
        //tileColor: Colors.grey.shade200,
      ),
    );
  }
}
