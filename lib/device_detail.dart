import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'translations/locale_keys.g.dart';
import 'ble/ble_device_connector.dart';
import 'ble/ble_device_interactor.dart';
import 'ble/ble_dfu.dart';
import 'constant.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer5<BleDeviceConnector, BleConnectionState, BleDeviceInteractor, BleDFU, BleDFUState?>(
        builder: (_, deviceConnector, bleConnectionState, bleDeviceInteractor, bleDFU, bleDFUState, __) => _DeviceDetail(
          device: device,
          connectionStatus: bleConnectionState,
          connect: deviceConnector.connect,
          disconnect: deviceConnector.disconnect,
          deviceInteractor: bleDeviceInteractor,
          dfuState: bleDFUState ?? const BleDFUState(),
          startDFU: bleDFU.startDFU,
          stopDFU: bleDFU.stopDFU,
        ),
      );
}

class _DeviceDetail extends StatefulWidget {
  const _DeviceDetail({
    Key? key,
    required this.device,
    required this.connectionStatus,
    required this.connect,
    required this.disconnect,
    required this.deviceInteractor,
    required this.dfuState,
    required this.startDFU,
    required this.stopDFU,
  }) : super(key: key);

  final DiscoveredDevice device;
  final BleConnectionState connectionStatus;
  final void Function(String deviceId, Function connected, Function disconnected) connect;
  final void Function(String deviceId) disconnect;
  final BleDeviceInteractor deviceInteractor;
  final BleDFUState dfuState;
  final Function(String, bool, StateSetter) startDFU;
  final Function(StateSetter) stopDFU;

  @override
  State<_DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<_DeviceDetail> {
  DateTime _now = DateTime.now();
  late Timer _timer;

  bool _functionOpen = false;
  bool _showingDialog = false;
  bool _fwCheck = false;

  int _functionNum = 0;

  double _sliderValue = 0.0;

  TimeOfDay _pickedStartTime = TimeOfDay.now();
  TimeOfDay _pickedEndTime = TimeOfDay.now();
  TimeOfDay _pickedAlarmTime = TimeOfDay.now();

  final List<String> hourGlassLabels = ['1min', '10min', '30min', '60min', '3am'];
  final _functionOn = {"Alarm": false, "TimeFormat": false, "NightMode": false, "HourglassEffect": false};

  final _theme = ThemeData.light().copyWith(
    timePickerTheme: TimePickerThemeData(
      hourMinuteColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.black : Colors.white),
      hourMinuteTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black),
      dialHandColor: Colors.black,
      dialBackgroundColor: Colors.grey.shade200,
      dialTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Colors.black), overlayColor: MaterialStateColor.resolveWith((states) => Colors.grey)),
    ),
  );

  @override
  void initState() {
    super.initState();
    if (mounted) _timer = Timer.periodic(const Duration(milliseconds: 300), (Timer t) => setState(() => _now = DateTime.now()));
    WidgetsBinding.instance?.addPostFrameCallback((_) => widget.connect(widget.device.id, _connectionReaction, _disconnectionReaction));
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.disconnect(widget.device.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Function> _functionsInit = [
      if (widget.device.name == "alarm") () async {},
      () async {
        bool value = await widget.deviceInteractor.readTimeFormat();
        setState(() => _functionOn["TimeFormat"] = value);
      },
      () async {
        var data = await widget.deviceInteractor.readNightMode();
        setState(() {
          _functionOn["NightMode"] = data[0];
          _pickedStartTime = data[1];
          _pickedEndTime = data[2];
        });
      },
      () async {
        int value = await widget.deviceInteractor.readHourGlass();
        setState(() => _sliderValue = value.toDouble());
      }
    ];

    List _functionItems = [
      if (widget.device.name == "alarm")
        NameIconWidget(
          "Alarm",
          Icons.alarm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Set time of the alarm."),
              Transform.scale(
                scale: 1.5,
                child: Switch(value: _functionOn["Alarm"]!, onChanged: (bool value) => setState(() => _functionOn["Alarm"] = value), activeColor: Colors.white, activeTrackColor: Colors.black),
              ),
              const SizedBox(height: 30),
              if (_functionOn["Alarm"]!)
                InkWell(
                  onTap: () async {
                    var tmpTime = await showTimePicker(context: context, initialTime: TimeOfDay.now(), builder: (context, child) => Theme(data: _theme, child: child!)) ?? _pickedAlarmTime;
                    setState(() => _pickedAlarmTime = tmpTime);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                    ),
                    child: Text("${_pickedAlarmTime.hour.toString().padLeft(2, '0')}:${_pickedAlarmTime.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                )
            ],
          ),
        ),
      NameIconWidget(
        LocaleKeys.detailTimeFormat.tr(),
        Icons.timelapse,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.detailTimeFormatText.tr()),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await widget.deviceInteractor.timeFormat(0);
                    setState(() => _functionOn["TimeFormat"] = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: _functionOn["TimeFormat"]! ? const Color(0xFFFCE9A7) : Colors.black,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                    ),
                    child: Column(children: [Text("24 h", style: TextStyle(color: _functionOn["TimeFormat"]! ? Colors.black : Colors.white, fontSize: 25, fontWeight: FontWeight.bold))]),
                  ),
                ),
                const SizedBox(width: 30),
                InkWell(
                  onTap: () async {
                    await widget.deviceInteractor.timeFormat(1);
                    setState(() => _functionOn["TimeFormat"] = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: _functionOn["TimeFormat"]! ? Colors.black : const Color(0xFFFCE9A7),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                    ),
                    child: Column(children: [Text("12 h", style: TextStyle(color: _functionOn["TimeFormat"]! ? Colors.white : Colors.black, fontSize: 25, fontWeight: FontWeight.bold))]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      NameIconWidget(
        LocaleKeys.detailNightMode.tr(),
        Icons.mode_night,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.detailNightModeText.tr()),
            Transform.scale(
              scale: 1.5,
              child: Switch(
                value: _functionOn["NightMode"]!,
                onChanged: (value) async {
                  await widget.deviceInteractor.nightModeOnOff(value);

                  setState(() => _functionOn["NightMode"] = value);
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            if (_functionOn["NightMode"]!)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      var tmpTime = await showTimePicker(context: context, initialTime: _pickedStartTime, builder: (context, child) => Theme(data: _theme, child: child!)) ?? _pickedStartTime;
                      setState(() => _pickedStartTime = tmpTime);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Text(LocaleKeys.detailNighModeStart.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("${_pickedStartTime.hour.toString().padLeft(2, '0')}:${_pickedStartTime.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  InkWell(
                    onTap: () async {
                      var tmpTime = await showTimePicker(context: context, initialTime: _pickedEndTime, builder: (context, child) => Theme(data: _theme, child: child!)) ?? _pickedEndTime;
                      setState(() => _pickedEndTime = tmpTime);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Text(LocaleKeys.detailNighModeEnd.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("${_pickedEndTime.hour.toString().padLeft(2, '0')}:${_pickedEndTime.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            if (_functionOn["NightMode"]!)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 45,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: MaterialButton(
                    child: Text(LocaleKeys.detailNighModeSet.tr(), style: const TextStyle(color: Colors.white)),
                    onPressed: () async => await widget.deviceInteractor.nightModeTime(_pickedStartTime, _pickedEndTime),
                  ),
                ),
              ),
          ],
        ),
      ),
      NameIconWidget(
        LocaleKeys.detailHourglass.tr(),
        Icons.hourglass_empty,
        Column(
          children: [
            Text(LocaleKeys.detailHourglassText.tr()),
            const SizedBox(height: 30),
            Slider(
              value: _sliderValue,
              activeColor: Colors.grey,
              inactiveColor: Colors.grey,
              thumbColor: Colors.white,
              max: 4,
              divisions: 4,
              onChangeEnd: (value) async => await widget.deviceInteractor.hourglass(value.toInt()),
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: hourGlassLabels.map((name) => Text(name, style: hourGlassLabels.indexOf(name) == _sliderValue ? const TextStyle(fontSize: 15, fontWeight: FontWeight.bold) : null)).toList(),
            ),
          ],
        ),
      ),
    ];

    return WillPopScope(
      onWillPop: () async => _fwCheck && !_showingDialog,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (_functionOpen) {
                setState(() => _functionOpen = false);
              } else if (_fwCheck) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${_now.year.toString()}-${_now.month.toString().padLeft(2, '0')}-${_now.day.toString().padLeft(2, '0')} ${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!_functionOpen)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.device.name, style: const TextStyle(fontFamily: "Abraham", fontSize: 50, height: 1)),
                            Text(widget.device.id),
                            Text("RSSI: ${widget.device.rssi.toString()}"),
                            const SizedBox(height: 10),
                          ],
                        ),
                        Center(child: Hero(tag: widget.device.id, child: Image.asset("assets/clock.png", width: 290, height: 180, fit: BoxFit.fitWidth))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.connectionStatus.connected && _fwCheck)
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: MaterialButton(child: Text(LocaleKeys.detailSyncTime.tr(), style: const TextStyle(color: Colors.white)), onPressed: () => widget.deviceInteractor.syncTime(_now)),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.all(Radius.circular(5))),
                    ),
                  const SizedBox(height: 40),
                  if (!widget.connectionStatus.connected || !_fwCheck) const CircularProgressIndicator(color: Colors.black),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 35, right: 20, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 135, child: Text(widget.device.name, style: const TextStyle(fontFamily: "Abraham", fontSize: 50, height: 1))),
                            Text(widget.device.id),
                            Text(widget.device.rssi.toString()),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 30),
                            Center(child: Hero(tag: widget.device.id, child: Image.asset("assets/clock.png", width: 170, height: 100, fit: BoxFit.fitWidth))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 280,
                        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_functionItems[_functionNum].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 5),
                            _functionItems[_functionNum].widget,
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 30),
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                          ),
                          child: Icon(_functionItems[_functionNum].icon, size: 30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.detailMore.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _functionItems
                        .map(
                          (fce) => widget.connectionStatus.connected && _fwCheck
                              ? InkWell(
                                  splashFactory: NoSplash.splashFactory,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    setState(
                                      () {
                                        if (_functionNum == _functionItems.indexOf(fce)) {
                                          if (_functionOpen) {
                                            _functionOpen = false;
                                          } else {
                                            _functionOpen = true;
                                          }
                                        } else {
                                          _functionOpen = true;
                                          _functionNum = _functionItems.indexOf(fce);
                                        }
                                      },
                                    );
                                    _functionsInit[_functionNum]();
                                  },
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 2))],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(fce.icon, size: 30, color: _functionOpen && _functionItems.indexOf(fce) == _functionNum ? const Color(0xFFFCD205) : Colors.black),
                                        const SizedBox(height: 10),
                                        Text(
                                          fce.name,
                                          style: TextStyle(fontSize: 13, color: _functionOpen && _functionItems.indexOf(fce) == _functionNum ? const Color(0xFFFCD205) : Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 120,
                                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 2))],
                                  ),
                                ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _disconnectionReaction() async {
    if (!_showingDialog) Navigator.pop(context);
  }

  Future<void> _connectionReaction() async {
    var discoveredServices = await widget.deviceInteractor.discoverServices(widget.device.id);
    if (discoveredServices[2].characteristicIds.contains(Uuid.parse("00002A26-0000-1000-8000-00805F9B34FB"))) {
      widget.deviceInteractor.discoverCharacteristics(true, widget.device.id);
      var fwVer = await widget.deviceInteractor.readFwRev();
      if (fwVer != latestFwVer) await _showUpdateAlert(context, fwVer);
    } else {
      await _showOldFirmwareAlert(context);
    }
    widget.deviceInteractor.discoverCharacteristics(false, widget.device.id);
    _fwCheck = true;
  }

  Future<void> _showOldFirmwareAlert(BuildContext context) async {
    _showingDialog = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.pop(context);
          return true;
        },
        child: AlertDialog(
          title: Text(LocaleKeys.detailUpdate.tr()),
          content: Text(LocaleKeys.detailUpdateLegacyText.tr()),
          actions: [
            Container(
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
              child: MaterialButton(
                child: const Text("OK", style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  {
                    _showingDialog = false;
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateAlert(BuildContext context, String fwVer) async {
    _showingDialog = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async {
          if (!widget.dfuState.dfuIsInProgress) {
            Navigator.pop(context);
            Navigator.pop(context);
            return true;
          }
          return false;
        },
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(LocaleKeys.detailUpdate.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocaleKeys.detailUpdateText.tr(args: [fwVer, latestFwVer])),
                  const SizedBox(height: 20),
                  if (widget.dfuState.dfuIsInProgress) LinearProgressIndicator(backgroundColor: Colors.grey, color: Colors.black, value: widget.dfuState.dfuPercent > 0 ? widget.dfuState.dfuPercent : null, minHeight: 7)
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: const Color(0xFFFCD205), onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  onPressed: !widget.dfuState.dfuIsInProgress
                      ? () async {
                          await widget.deviceInteractor.blOn();
                          await widget.startDFU(widget.device.id, true, setState);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _showingDialog = false;
                        }
                      : null,
                  child: Text(LocaleKeys.detailUpdateButton.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NameIconWidget {
  final String name;
  final IconData icon;
  final Widget widget;
  const NameIconWidget(this.name, this.icon, this.widget);
}
