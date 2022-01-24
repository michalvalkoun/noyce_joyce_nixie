import 'package:flutter/material.dart';

class MySlider extends StatefulWidget {
  final String name;
  const MySlider({Key? key, required this.name}) : super(key: key);

  @override
  _MySliderState createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  double _currentSliderValue = 0;
  List<String> labels = ['1min', '10min', '30min', '1hod', '3AM'];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Slider(
            value: _currentSliderValue,
            activeColor: Color(0xFFFCD205),
            inactiveColor: Colors.black,
            max: 4,
            divisions: 4,
            label: labels[_currentSliderValue.round()],
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
