import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:nixie_app/device_page/device_page.dart';
import 'package:nixie_app/icon_picker.dart';

class MyCarousel extends StatefulWidget {
  const MyCarousel({Key? key}) : super(key: key);

  @override
  _MyCarouselState createState() => _MyCarouselState();
}

class _MyCarouselState extends State<MyCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CarouselSlider(
          items: IconPicker.devices
              .map(
                (device) => Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DevicePage(device: device)));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 15, left: 15),
                              child: Text(
                                "nixie\n${device.name}",
                                style: TextStyle(
                                    fontFamily: "Abraham",
                                    fontSize: 45,
                                    height: 1),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFCD205),
                              ),
                              child: Icon(
                                device.icon,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 270,
                          child: Image.asset(
                            "assets/${device.name}.png",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
          carouselController: _controller,
          options: CarouselOptions(
            onPageChanged: (index, reason) => setState(() => _current = index),
            enableInfiniteScroll: false,
            height: 450,
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: IconPicker.devices.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: _current == entry.key ? 12.0 : 8,
                  height: _current == entry.key ? 12.0 : 8,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black
                          .withOpacity(_current == entry.key ? 1 : 0.8)),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
