import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_controller.dart';

class MyButton {
  final int pos;
  final String name;
  final Color? color;
  final String file;
  final IconData icon;
  const MyButton(this.pos, this.name, this.color, this.file, this.icon);
}

class MyIconButton extends StatelessWidget {
  final MyButton button;
  final CarouselController controller;

  const MyIconButton({
    Key? key,
    required this.button,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: button.color,
      child: IconButton(
        splashColor: Colors.transparent,
        alignment: Alignment.center,
        icon: Icon(button.icon),
        iconSize: 40,
        onPressed: () => controller.animateToPage(button.pos),
      ),
    );
  }
}
