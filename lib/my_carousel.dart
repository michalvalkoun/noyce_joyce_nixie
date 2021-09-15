import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'my_icon_button.dart';

class MyCarousel extends StatefulWidget {
  MyCarousel({Key? key}) : super(key: key);

  @override
  _MyCarouselState createState() => _MyCarouselState();
}

class _MyCarouselState extends State<MyCarousel> {
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final buttons = [
      MyButton(0, 'Alarm', Colors.red[400], 'assets/alarm.png', Icons.alarm),
      MyButton(
          1, 'Clock', Colors.teal[200], 'assets/clock.png', Icons.access_time),
      MyButton(2, 'Radio', Colors.green[300], 'assets/radio.png', Icons.radio),
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            enableInfiniteScroll: false,
            height: 250,
          ),
          carouselController: _controller,
          items: buttons
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(item.file, height: 150, width: 250),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buttons
              .map((button) =>
                  MyIconButton(button: button, controller: _controller))
              .toList(),
        ),
      ],
    );
  }
}
