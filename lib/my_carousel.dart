import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';

class MyCarousel extends StatefulWidget {
  const MyCarousel({Key? key}) : super(key: key);

  @override
  _MyCarouselState createState() => _MyCarouselState();
}

class _MyCarouselState extends State<MyCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final devices = ["clock", "radio", "alarm"];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: devices
            .map(
              (name) => Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 20, left: 20),
                          child: Text(
                            "nixie\n$name",
                            style: TextStyle(
                                fontFamily: "Abraham", fontSize: 50, height: 1),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Image.asset("assets/${name}_icon.png"),
                        ),
                      ],
                    ),
                    Container(
                      child: Image.asset(
                        "assets/$name.png",
                        width: 300,
                        height: 250,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        carouselController: _controller,
        options: CarouselOptions(
          onPageChanged: (index, reason) {
            setState(
              () {
                _current = index;
              },
            );
          },
          enableInfiniteScroll: false,
          height: 450,
        ),
      ),
      Container(
        margin: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: devices.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}
