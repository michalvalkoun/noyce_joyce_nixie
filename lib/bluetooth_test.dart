import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nixie_app/dfu/just_dfu.dart';

class BluetoothTest extends StatefulWidget {
  const BluetoothTest({Key? key}) : super(key: key);
  @override
  State<BluetoothTest> createState() => _BluetoothTestState();
}

class _BluetoothTestState extends State<BluetoothTest> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubscription;
  List<ScanResult> scanResults = <ScanResult>[];
  @override
  Widget build(BuildContext context) {
    final isScan = scanSubscription != null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: IconButton(
          icon: Icon(isScan ? Icons.pause_circle : Icons.play_arrow),
          onPressed: isScan ? stopScan : startScan,
          iconSize: 50,
        ),
      ),
      body: scanResults.length <= 0
          ? const Center(child: const Text('No Device'))
          : ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, int index) {
                return InkWell(
                  onTap: () async {
                    await JustDFU().startDFU(scanResults[index].device.id.id);
                  },
                  child: Card(
                      child: Column(
                    children: [
                      Text(scanResults[index].device.name == ''
                          ? 'Unknown'
                          : scanResults[index].device.name),
                      Text(scanResults[index].rssi.toString())
                    ],
                  )),
                );
              }),
    );
  }

  void startScan() async {
    scanSubscription?.cancel();
    await flutterBlue.stopScan();
    setState(
      () {
        scanResults.clear();
        scanSubscription = flutterBlue.scan().listen(
              (scanResult) => setState(
                () => scanResults.add(scanResult),
              ),
            );
      },
    );
  }

  void stopScan() {
    scanSubscription?.cancel();
    setState(() => scanSubscription = null);
  }
}
