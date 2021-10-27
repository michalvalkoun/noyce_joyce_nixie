import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothTest extends StatefulWidget {
  const BluetoothTest({Key? key}) : super(key: key);
  @override
  State<BluetoothTest> createState() => _BluetoothTestState();
}

class _BluetoothTestState extends State<BluetoothTest> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = <ScanResult>[];
  bool isScan = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: IconButton(
          icon: Icon(isScan ? Icons.pause_circle : Icons.play_arrow),
          onPressed: () {
            isScan
                ? flutterBlue.stopScan()
                : flutterBlue.startScan(timeout: Duration(seconds: 4));
            setState(() {
              isScan = !isScan;
            });
          },
          iconSize: 50,
        ),
      ),
      body: scanResults.length <= 0
          ? const Center(child: const Text('No Device'))
          : ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, int index) {
                return Card(child: Text(scanResults[index].device.name));
              }),
    );

// // Listen to scan results
//     var subscription = flutterBlue.scanResults.listen((results) {
//       // do something with scan results
//       for (ScanResult r in results) {
//         print('${r.device.name} found! rssi: ${r.rssi}');
//       }
//     });
  }
}
