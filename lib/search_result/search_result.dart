import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

import 'device.dart';
import 'my_app_bar.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubscription;
  List<ScanResult> scanResults = <ScanResult>[];
  bool _buttonEnabled = true;

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isScan = scanSubscription != null;
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 30, bottom: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SEARCH RESULTS:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
                IconButton(
                  icon: Icon(isScan ? Icons.pause_circle : Icons.play_arrow),
                  onPressed: _buttonEnabled
                      ? () async {
                          if (isScan) {
                            stopScan();
                            _buttonEnabled = false;
                            Timer(Duration(seconds: 5), () {
                              setState(() {
                                _buttonEnabled = true;
                              });
                            });
                          } else {
                            startScan();
                          }
                        }
                      : null,
                  iconSize: 50,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...scanResults.map(
                  (result) => Device(
                    device: result.device,
                    rssi: result.rssi,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  if (result.device.name == 'Nixie Clock' ||
                      result.device.name == 'Nixie Alarm-Clock' ||
                      result.device.name == 'Nixie Radio') {
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
