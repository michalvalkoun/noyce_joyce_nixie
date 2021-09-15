import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  get preferredSize => Size.fromHeight(50);
  final String title;
  final widget;
  final icon;
  final bool isNavigator;

  const MyAppBar({
    Key? key,
    required this.title,
    this.widget,
    this.icon,
    this.isNavigator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.black,
      actions: [
        if (widget != null)
          IconButton(
            onPressed: isNavigator
                ? () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => widget))
                : widget,
            icon: Icon(icon),
            iconSize: 25,
          ),
      ],
      iconTheme: const IconThemeData(color: Colors.black, size: 25),
      backgroundColor: Colors.amber.shade300,
      title: Text(title,
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          )),
      centerTitle: true,
    );
  }
}
