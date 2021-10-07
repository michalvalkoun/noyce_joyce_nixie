import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  get preferredSize => Size.fromHeight(70);
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.format_list_bulleted,
          size: 30,
          color: Colors.black,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Container(
        height: 60,
        margin: EdgeInsets.only(right: 20),
        alignment: Alignment.bottomRight,
        child: Image.asset(
          "assets/logo_horizontal.png",
          alignment: Alignment.bottomRight,
          height: 40,
        ),
      ),
    );
  }
}
