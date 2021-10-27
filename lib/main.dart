import 'package:flutter/material.dart';

//import 'main_page/main_page.dart';
import 'package:nixie_app/dfu/just_dfu.dart';
import 'bluetooth_test.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF5F5F5)),
        home: BluetoothTest());
  }
}

class TestDFU extends StatefulWidget {
  const TestDFU({Key? key}) : super(key: key);

  @override
  State<TestDFU> createState() => _TestDFUState();
}

class _TestDFUState extends State<TestDFU> {
  String text = "DFU";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.red),
          child: Text(text),
          onPressed: JustDFU().getRunningDFU()
              ? null
              : () async {
                  var text2 = await JustDFU().startDFU('F3:6A:91:FD:D6:94')
                      ? 'Success'
                      : 'Fail';
                  setState(() => text = text2);
                },
        ),
      ),
    );
  }
}
