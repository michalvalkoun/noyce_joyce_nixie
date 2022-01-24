import 'package:flutter/material.dart';

import 'package:nixie_app/dfu/my_dfu.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text("UPDATE DEVICE"),
            leading: const Icon(Icons.security_update),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyDFU()));
            },
          ),
        ],
      ),
    );
  }
}
