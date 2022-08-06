import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:noyce_joyce_nixie/ble/ble_dfu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

import 'translations/locale_keys.g.dart';
import 'ble/ble_scanner.dart';
import 'ble/ble_dfu.dart';
import 'device_detail.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer5<BleStatus?, BleScanner, BleScannerState?, BleDFU, BleDFUState?>(
      builder: (_, bleStatus, bleScanner, bleScannerState, bleDFU, bleDFUState, __) => _Devicelist(
        bleStatus: bleStatus ?? BleStatus.unknown,
        scannerState: bleScannerState ?? const BleScannerState(),
        startScan: bleScanner.startScan,
        stopScan: bleScanner.stopScan,
        checkPermissions: bleScanner.checkPermissions,
        determineText: bleScanner.determineText,
        dfuState: bleDFUState ?? const BleDFUState(),
        startDFU: bleDFU.startDFU,
        stopDFU: bleDFU.stopDFU,
      ),
    );
  }
}

class _Devicelist extends StatefulWidget {
  const _Devicelist({
    required this.bleStatus,
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.checkPermissions,
    required this.determineText,
    required this.dfuState,
    required this.startDFU,
    required this.stopDFU,
    Key? key,
  }) : super(key: key);

  final BleStatus bleStatus;
  final BleScannerState scannerState;
  final Function() startScan;
  final VoidCallback stopScan;
  final Function() checkPermissions;
  final Function(BleStatus) determineText;
  final BleDFUState dfuState;
  final Function(String, bool, StateSetter) startDFU;
  final Function(StateSetter) stopDFU;

  @override
  State<_Devicelist> createState() => _DevicelistState();
}

class _DevicelistState extends State<_Devicelist> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(const Duration(milliseconds: 500), startScan));
  }

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }

  Future<void> startScan() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (widget.bleStatus != BleStatus.ready) {
      int permissonsResult = await widget.checkPermissions();
      if (widget.bleStatus != BleStatus.ready && widget.bleStatus != BleStatus.unknown) {
        final snackBar = SnackBar(content: Text(widget.determineText(widget.bleStatus)), action: permissonsResult == -1 ? SnackBarAction(label: LocaleKeys.listSettings.tr(), onPressed: () => openAppSettings()) : null);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    if (widget.bleStatus == BleStatus.ready) {
      if (!widget.startScan()) {
        final snackBar = SnackBar(content: Text(LocaleKeys.listBleWarning.tr(), textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.dfuState.dfuIsInProgress,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios), color: Colors.black, onPressed: !widget.dfuState.dfuIsInProgress ? () => Navigator.pop(context) : () {}),
          title: Text(LocaleKeys.listTitle.tr(), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: widget.scannerState.discoveredDevices.isNotEmpty || !widget.scannerState.scanIsInProgress
                  ? ListView(
                      padding: const EdgeInsets.only(top: 10),
                      children: widget.scannerState.discoveredDevices
                          .map(
                            (device) => Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                              color: device.name.contains("BL") ? const Color.fromARGB(255, 252, 218, 95) : Colors.white,
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: InkWell(
                                borderRadius: const BorderRadius.all(Radius.circular(7)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(width: 165, child: Text(device.name.contains("Alarm") ? "Nixie Alarm" : device.name, style: const TextStyle(fontFamily: "Abraham", fontSize: 32, height: 1))),
                                              Text(device.id),
                                              const SizedBox(height: 20),
                                              SignalStrengthIndicator.sector(value: device.rssi, barCount: 4, minValue: -90, maxValue: -50, size: 25, activeColor: Colors.black, inactiveColor: Colors.black12),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 130,
                                            child: Hero(tag: device.id, child: Image.asset(device.name.contains("Alarm") ? "assets/alarm.png" : "assets/clock.png", fit: BoxFit.contain, width: 130)),
                                          ),
                                        ],
                                      ),
                                      if (widget.dfuState.adress == device.id && widget.dfuState.dfuIsInProgress)
                                        LinearProgressIndicator(backgroundColor: Colors.grey, color: Colors.black, value: widget.dfuState.dfuPercent > 0 ? widget.dfuState.dfuPercent : null, minHeight: 7)
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  widget.stopScan();
                                  if (device.name.contains("BL") && !widget.dfuState.dfuIsInProgress) {
                                    await widget.startDFU(device.id, false, setState);
                                    widget.startScan();
                                  } else if (!widget.dfuState.dfuIsInProgress) {
                                    if (device.name.contains("Alarm")) {
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      final snackBar = SnackBar(content: Text(LocaleKeys.listAlarmSupport.tr(), textAlign: TextAlign.center));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDetailScreen(id: device.id, name: device.name))).then((value) => widget.startScan());
                                    }
                                  }
                                },
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.black)),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text(LocaleKeys.listSearch.tr()),
                  style: ElevatedButton.styleFrom(primary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: !widget.scannerState.scanIsInProgress && !widget.dfuState.dfuIsInProgress ? () => startScan() : null,
                ),
                ElevatedButton(
                  child: Text(LocaleKeys.listStop.tr()),
                  style: ElevatedButton.styleFrom(primary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: widget.scannerState.scanIsInProgress && !widget.dfuState.dfuIsInProgress ? () => widget.stopScan() : null,
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
