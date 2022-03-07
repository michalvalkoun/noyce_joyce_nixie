import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:nixie_app/search_result/my_app_bar.dart';

class MyDFU extends StatefulWidget {
  const MyDFU({Key? key}) : super(key: key);

  @override
  _MyDFUState createState() => _MyDFUState();
}

class _MyDFUState extends State<MyDFU> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubscription;
  List<ScanResult> scanResults = <ScanResult>[];
  bool dfuRunning = false;
  int? dfuRunningInx;

  @override
  Widget build(BuildContext context) {
    final isScan = scanSubscription != null;

    return MaterialApp(
      home: Scaffold(
        appBar: MyAppBar(),
        body: Column(
          children: [
            IconButton(
              icon: Icon(isScan ? Icons.pause_circle : Icons.play_arrow),
              onPressed: dfuRunning ? null : (isScan ? stopScan : startScan),
              iconSize: 50,
            ),
            Expanded(
              child: scanResults.length <= 0
                  ? const Center(child: const Text('No Device'))
                  : ListView.builder(
                      itemCount: scanResults.length,
                      itemBuilder: (context, int index) {
                        return DeviceItem(
                          isRunningItem: dfuRunningInx == null ? false : dfuRunningInx == index,
                          scanResult: scanResults[index],
                          onPress: dfuRunning
                              ? () async {
                                  await NordicDfu.abortDfu();
                                  setState(() {
                                    dfuRunningInx = null;
                                  });
                                }
                              : () async {
                                  setState(() => dfuRunningInx = index);
                                  await this.doDfu(scanResults[index].device.id.id);
                                  setState(() => dfuRunningInx = null);
                                },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> doDfu(String deviceId) async {
    stopScan();
    dfuRunning = true;
    try {
      await NordicDfu.startDfu(deviceId, 'assets/file.zip', fileInAsset: true);
      dfuRunning = false;
    } catch (e) {
      dfuRunning = false;
    }
  }

  void startScan() async {
    scanSubscription?.cancel();
    await flutterBlue.stopScan();
    setState(
      () {
        scanResults.clear();
        scanSubscription = flutterBlue.scan().listen(
              (result) => setState(
                () {
                  if (result.device.name == 'Nixie Clock BL' || result.device.name == 'Nixie Alarm-Clock BL' || result.device.name == 'Nixie Radio BL') {
                    scanResults.add(result);
                    scanResults.sort((a, b) => b.rssi.compareTo(a.rssi));
                  }
                },
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

class DeviceItem extends StatelessWidget {
  final ScanResult scanResult;

  final VoidCallback? onPress;

  final bool isRunningItem;

  DeviceItem({
    required this.scanResult,
    this.onPress,
    required this.isRunningItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scanResult.device.name.length > 0 ? scanResult.device.name : "Unknown"),
              Text(scanResult.device.id.id),
              Text("RSSI: ${scanResult.rssi}"),
            ],
          ),
          TextButton(onPressed: onPress, child: isRunningItem ? Text("Abort DFU") : Text("Start DFU"))
        ],
      ),
    );
  }
}
