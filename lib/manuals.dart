import 'package:flutter/material.dart';

import 'my_app_bar.dart';

class Manuals extends StatelessWidget {
  const Manuals({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Manuals',
      ),
    );
  }
}
