import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:easy_localization/easy_localization.dart';

import 'translations/locale_keys.g.dart';
import 'constant.dart';
import 'dfu.dart';

class DevicePage extends StatefulWidget {
  final DiscoveredDevice device;
  const DevicePage({Key? key, required this.device}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final _ble = FlutterReactiveBle();
  StreamSubscription<ConnectionStateUpdate>? _connectionStream;

  DateTime _now = DateTime.now();
  late Timer _timer;
  late StateSetter _setState;

  bool _functionOpen = false;
  bool _connected = false;
  bool _updateDialog = false;
  bool _fwCheck = false;

  String _fwVer = "";

  int _functionNum = 0;

  double _dfuPercent = 0.0;
  double _sliderValue = 0.0;

  TimeOfDay _pickedStartTime = TimeOfDay.now();
  TimeOfDay _pickedEndTime = TimeOfDay.now();
  TimeOfDay _pickedAlarmTime = TimeOfDay.now();

  final List<String> hourGlassLabels = ['1min', '10min', '30min', '1hod', '3AM'];
  final _functionOn = {"Alarm": false, "Time Format": false, "Night Mode": false, "Hourglass effect": false};

  late QualifiedCharacteristic _firmwareRevisionCharacteristic;
  late QualifiedCharacteristic _dateTimeCharacteristic;
  late QualifiedCharacteristic _timeFormatCharacteristic;
  late QualifiedCharacteristic _nightModeOnOffCharacteristic;
  late QualifiedCharacteristic _nightModeStartCharacteristic;
  late QualifiedCharacteristic _nightModeEndCharacteristic;
  late QualifiedCharacteristic _hourGlassCharacteristic;
  late QualifiedCharacteristic _blOnCharacteristic;

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
    WidgetsBinding.instance?.addPostFrameCallback((_) => _connect());
  }

  @override
  void dispose() {
    _timer.cancel();
    _connectionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Function> _functionsInit = [
      if (widget.device.name == "alarm") () async {},
      () async {
        var data = await _ble.readCharacteristic(_timeFormatCharacteristic);
        setState(() => _functionOn["Time Format"] = data[0] > 0 ? true : false);
      },
      () async {
        var data = await _ble.readCharacteristic(_nightModeOnOffCharacteristic) + await _ble.readCharacteristic(_nightModeStartCharacteristic) + await _ble.readCharacteristic(_nightModeEndCharacteristic);
        var tmpStartDate = DateTime.fromMillisecondsSinceEpoch((data[1] + (data[2] << 8) + (data[3] << 16) + (data[4] << 24)) * 1000);
        var tmpEndDate = DateTime.fromMillisecondsSinceEpoch((data[5] + (data[6] << 8) + (data[7] << 16) + (data[8] << 24)) * 1000);
        setState(() {
          _functionOn["Night Mode"] = data[0] > 0 ? true : false;
          _pickedStartTime = TimeOfDay(hour: tmpStartDate.hour - 1, minute: tmpStartDate.minute);
          _pickedEndTime = TimeOfDay(hour: tmpEndDate.hour - 1, minute: tmpEndDate.minute);
        });
      },
      () async {
        var data = await _ble.readCharacteristic(_hourGlassCharacteristic);
        setState(() => _sliderValue = data[0].toDouble());
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
        LocaleKeys.time_format.tr(),
        Icons.timelapse,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.time_format_text.tr()),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await _ble.writeCharacteristicWithoutResponse(_timeFormatCharacteristic, value: [0]);
                    setState(() => _functionOn["Time Format"] = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: _functionOn["Time Format"]! ? const Color(0xFFFCE9A7) : Colors.black,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                    ),
                    child: Column(children: [Text("24 h", style: TextStyle(color: _functionOn["Time Format"]! ? Colors.black : Colors.white, fontSize: 25, fontWeight: FontWeight.bold))]),
                  ),
                ),
                const SizedBox(width: 30),
                InkWell(
                  onTap: () async {
                    await _ble.writeCharacteristicWithoutResponse(_timeFormatCharacteristic, value: [1]);
                    setState(() => _functionOn["Time Format"] = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: _functionOn["Time Format"]! ? Colors.black : const Color(0xFFFCE9A7),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 3, offset: Offset(0, 2))],
                    ),
                    child: Column(children: [Text("12 h", style: TextStyle(color: _functionOn["Time Format"]! ? Colors.white : Colors.black, fontSize: 25, fontWeight: FontWeight.bold))]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      NameIconWidget(
        LocaleKeys.night_mode.tr(),
        Icons.mode_night,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.night_mode_text.tr()),
            Transform.scale(
              scale: 1.5,
              child: Switch(
                value: _functionOn["Night Mode"]!,
                onChanged: (value) async {
                  await _ble.writeCharacteristicWithoutResponse(_nightModeOnOffCharacteristic, value: [value == true ? 1 : 0]);
                  setState(() => _functionOn["Night Mode"] = value);
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            if (_functionOn["Night Mode"]!)
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
                          Text(LocaleKeys.start.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                          Text(LocaleKeys.end.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("${_pickedEndTime.hour.toString().padLeft(2, '0')}:${_pickedEndTime.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            if (_functionOn["Night Mode"]!)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 45,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: MaterialButton(
                    child: Text(LocaleKeys.set.tr(), style: const TextStyle(color: Colors.white)),
                    onPressed: () async {
                      var startTimeStamp = _pickedStartTime.hour * 3600 + _pickedStartTime.minute * 60;
                      var endTimeStamp = _pickedEndTime.hour * 3600 + _pickedEndTime.minute * 60;
                      await _ble.writeCharacteristicWithoutResponse(
                        _nightModeStartCharacteristic,
                        value: [startTimeStamp & 0xFF, (startTimeStamp >> 8) & 0xFF, (startTimeStamp >> 16) & 0xFF, (startTimeStamp >> 24) & 0xFF],
                      );
                      await _ble.writeCharacteristicWithoutResponse(
                        _nightModeEndCharacteristic,
                        value: [endTimeStamp & 0xFF, (endTimeStamp >> 8) & 0xFF, (endTimeStamp >> 16) & 0xFF, (endTimeStamp >> 24) & 0xFF],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      NameIconWidget(
        LocaleKeys.hourglass.tr(),
        Icons.hourglass_empty,
        Column(
          children: [
            Text(LocaleKeys.hourglass_text.tr()),
            const SizedBox(height: 30),
            Slider(
              value: _sliderValue,
              activeColor: Colors.grey,
              inactiveColor: Colors.grey,
              thumbColor: Colors.white,
              max: 4,
              divisions: 4,
              onChangeEnd: (value) async => await _ble.writeCharacteristicWithoutResponse(_hourGlassCharacteristic, value: [value.toInt()]),
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
      onWillPop: () async => _fwCheck && !_updateDialog,
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
                  if (_connected && _fwCheck)
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: MaterialButton(
                        child: Text(LocaleKeys.sync.tr(), style: const TextStyle(color: Colors.white)),
                        onPressed: () async {
                          var sendStamp = ((_now.millisecondsSinceEpoch + _now.timeZoneOffset.inMilliseconds) / 1000).round();
                          await _ble.writeCharacteristicWithoutResponse(
                            _dateTimeCharacteristic,
                            value: [sendStamp & 0xFF, (sendStamp >> 8) & 0xFF, (sendStamp >> 16) & 0xFF, (sendStamp >> 24) & 0xFF],
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.all(Radius.circular(5))),
                    ),
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
                Container(margin: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.more_func.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _functionItems
                        .map(
                          (fce) => _connected && _fwCheck
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

  Future<void> _connect() async {
    _connectionStream =
        _ble.connectToAdvertisingDevice(id: widget.device.id, withServices: [Uuid.parse(infoServiceUuid)], prescanDuration: const Duration(seconds: 5), connectionTimeout: const Duration(seconds: 2)).listen(
      (status) async {
        switch (status.connectionState) {
          case DeviceConnectionState.connected:
            var discoveredServices = await _ble.discoverServices(status.deviceId);

            if (discoveredServices[2].characteristicIds.contains(Uuid.parse("00002A26-0000-1000-8000-00805F9B34FB"))) {
              _firmwareRevisionCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(infoServiceUuid), characteristicId: Uuid.parse("00002A26-0000-1000-8000-00805F9B34FB"), deviceId: status.deviceId);
              _blOnCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED14FF-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);
              var data = utf8.decode(await _ble.readCharacteristic(_firmwareRevisionCharacteristic));
              _fwVer = data.split(' ')[2];
              if (_fwVer != latestFwVer) await _showUpdateAlert(context);
            } else {
              _fwVer = "1.0";
              await _showOldFirmwareAlert(context);
            }
            _fwCheck = true;

            _timeFormatCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1420-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);
            _dateTimeCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1410-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);
            _hourGlassCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1421-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);
            _nightModeOnOffCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1423-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);
            _nightModeStartCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1425-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);
            _nightModeEndCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1424-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: status.deviceId);

            _connected = true;
            break;
          case DeviceConnectionState.disconnected:
            _connected = false;
            if (!_updateDialog) Navigator.pop(context);
            break;
          default:
            break;
        }
      },
    );
  }

  Future<void> _showOldFirmwareAlert(BuildContext context) async {
    _updateDialog = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(LocaleKeys.update.tr()),
          content: Text(LocaleKeys.legacyFwText1.tr() + "\n" + LocaleKeys.legacyFwText2.tr() + "\n" + LocaleKeys.legacyFwText3.tr() + "\n" + LocaleKeys.legacyFwText4.tr()),
          actions: [
            Container(
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
              child: MaterialButton(
                child: const Text("OK", style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  {
                    _updateDialog = false;
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

  Future<void> _showUpdateAlert(BuildContext context) async {
    _updateDialog = true;
    DFU dfu = DFU();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(LocaleKeys.update.tr()),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _setState = setState;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocaleKeys.updateText.tr(args: [_fwVer, latestFwVer])),
                  const SizedBox(height: 20),
                  if (_dfuPercent > 0) LinearProgressIndicator(backgroundColor: Colors.grey, color: Colors.black, value: _dfuPercent, semanticsLabel: "Progress", semanticsValue: "Value", minHeight: 7)
                ],
              );
            },
          ),
          actions: [
            Container(
              height: 40,
              decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(5))),
              child: MaterialButton(
                child: Text(LocaleKeys.cancel.tr(), style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  if (dfu.getRunningDFU()) {
                    NordicDfu.abortDfu();
                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            Container(
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
              child: MaterialButton(
                child: Text(LocaleKeys.updateButton.tr(), style: const TextStyle(color: Colors.black)),
                onPressed: () async {
                  {
                    if (!dfu.getRunningDFU()) {
                      await _ble.writeCharacteristicWithoutResponse(_blOnCharacteristic, value: [0x99]);
                      bool success = await dfu.startDFU(
                        widget.device.id,
                        latestFwVer,
                        DefaultDfuProgressListenerAdapter(onProgressChangedHandle: (deviceAddress, percent, speed, avgSpeed, currentPart, partsTotal) => _setState(() => _dfuPercent = percent! / 100)),
                        true,
                      );
                      _dfuPercent = 0;
                      Navigator.pop(context);
                      if (!success) Navigator.pop(context);
                      _updateDialog = false;
                      await _connect();
                    }
                  }
                },
              ),
            ),
          ],
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
