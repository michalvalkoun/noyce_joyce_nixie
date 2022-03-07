import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

import 'translations/locale_keys.g.dart';
import 'constant.dart';
import 'device_page.dart';
import 'dfu.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({Key? key}) : super(key: key);
  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final _ble = FlutterReactiveBle();
  final _dfu = DFU();
  StreamSubscription<DiscoveredDevice>? _scanStream;
  StreamSubscription<BleStatus>? _statusStream;
  final List<DiscoveredDevice> _scanResults = [];
  double _dfuPercent = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => _startScan());
  }

  @override
  void dispose() {
    _statusStream?.cancel();
    _scanStream?.cancel();
    super.dispose();
  }

  void _startScan() async {
    var sortWait = 0;
    var statusScan = await Permission.bluetoothScan.request();
    var statusConnect = await Permission.bluetoothConnect.request();
    var statusLocation = await Permission.location.request();

    if (statusScan.isGranted && statusConnect.isGranted && statusLocation.isGranted) {
      await _scanStream?.cancel();
      _statusStream = _ble.statusStream.listen(
        (status) async {
          switch (status) {
            case BleStatus.poweredOff:
              _statusStream?.cancel();
              _scanStream?.cancel();
              await showDialog<String>(context: context, builder: (_) => AlertDialog(title: Text(LocaleKeys.bluetoothOff.tr()), content: Text(LocaleKeys.bluetoothText.tr())));
              break;
            case BleStatus.ready:
              await _scanStream?.cancel();
              _scanResults.clear();
              _scanStream = _ble.scanForDevices(withServices: [Uuid.parse(infoServiceUuid), Uuid.parse(dfuServiceUuid)]).listen(
                (device) {
                  if (device.name.contains("Nixie Clock") && device.rssi > -80) {
                    setState(() {
                      var index = _scanResults.indexWhere((element) => element.id == device.id);
                      if (index > 0) _scanResults[index] = device;
                      if (index == -1) _scanResults.add(device);
                      if (sortWait++ > 10) {
                        _scanResults.sort((a, b) => b.rssi.compareTo(a.rssi));
                        sortWait = 0;
                      }
                    });
                  }
                },
              );
              break;
            default:
              break;
          }
        },
      );
    }
    if (statusScan.isPermanentlyDenied || statusConnect.isPermanentlyDenied || statusLocation.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(LocaleKeys.permission.tr()),
          content: Text(LocaleKeys.permissionText.tr()),
          actions: [
            ElevatedButton(
              child: Text(LocaleKeys.deny.tr()),
              style: ElevatedButton.styleFrom(primary: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(LocaleKeys.settings.tr(), style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(primary: const Color(0xFFFCD205)),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios), color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.click.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Expanded(
            child: _scanResults.isNotEmpty
                ? ListView(
                    children: _scanResults
                        .map(
                          (device) => InkWell(
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _statusStream?.cancel();
                              _scanStream?.cancel();

                              if (device.name.contains("BL") && !_dfu.getRunningDFU()) {
                                await _dfu.startDFU(
                                    device.id,
                                    latestFwVer,
                                    DefaultDfuProgressListenerAdapter(
                                      onProgressChangedHandle: (deviceAddress, percent, speed, avgSpeed, currentPart, partsTotal) => setState(() => _dfuPercent = percent! / 100),
                                    ),
                                    false);
                                setState(() => _dfuPercent = 0);
                                _statusStream?.cancel();
                                _scanStream?.cancel();
                                _startScan();
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DevicePage(device: device))).then((value) => _startScan());
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: device.name.contains("BL") ? const Color.fromARGB(255, 252, 218, 95) : Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 2))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 165, child: Text(device.name, style: const TextStyle(fontFamily: "Abraham", fontSize: 32, height: 1))),
                                          Text(device.id),
                                          Text("RSSI: ${device.rssi.toString()}"),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const SizedBox(height: 15),
                                          Hero(tag: device.id, child: Image.asset("assets/clock.png", fit: BoxFit.fitWidth, width: 130, height: 80)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (_dfu.getAdress() == device.id && _dfu.getRunningDFU())
                                    LinearProgressIndicator(backgroundColor: Colors.grey, color: Colors.black, value: _dfuPercent > 0 ? _dfuPercent : null, minHeight: 7)
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
            child: MaterialButton(child: Text(LocaleKeys.search_again.tr(), style: const TextStyle(color: Colors.white)), onPressed: _startScan),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
