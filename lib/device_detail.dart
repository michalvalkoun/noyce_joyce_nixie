import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations/locale_keys.g.dart';
import 'ble/ble_device_connector.dart';
import 'ble/ble_device_interactor.dart';
import 'ble/ble_dfu.dart';
import 'constant.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String id;
  final String name;

  const DeviceDetailScreen({required this.id, required this.name, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer5<BleDeviceConnector, BleConnectionState, BleDeviceInteractor, BleDFU, BleDFUState?>(
        builder: (_, deviceConnector, bleConnectionState, bleDeviceInteractor, bleDFU, bleDFUState, __) => _DeviceDetail(
          id: id,
          name: name,
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
    required this.id,
    required this.name,
    required this.connectionStatus,
    required this.connect,
    required this.disconnect,
    required this.deviceInteractor,
    required this.dfuState,
    required this.startDFU,
    required this.stopDFU,
  }) : super(key: key);

  final String id;
  final String name;
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
  final ScrollController _scrollController = ScrollController();

  DateTime _now = DateTime.now();
  late Timer _timer;

  bool favorite = false;
  bool _functionOpen = false;
  bool _functionReading = false;
  bool _showingDialog = false;
  bool _fwCheck = false;

  int _functionNum = 0;

  double _sliderValue = 0.0;

  DateTime _pickedStartTime = DateTime.now();
  DateTime _pickedEndTime = DateTime.now();
  DateTime _pickedAlarmTime = DateTime.now();

  DateTime _pickedDateTime = DateTime.now();

  final List<String> hourGlassLabels = ['1min', '10min', '30min', '60min', '3am'];
  final _functionOn = {"Alarm": false, "TimeFormat": false, "NightMode": false, "NixieDots": false};

  @override
  void initState() {
    super.initState();
    if (mounted) _timer = Timer.periodic(const Duration(milliseconds: 300), (Timer t) => setState(() => _now = DateTime.now()));

    WidgetsBinding.instance.addPostFrameCallback((_) async => favorite = await isFavorite(widget.id));
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.connect(widget.id, _connectionReaction, _disconnectionReaction));
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.disconnect(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Function> _functionsInit = [
      if (widget.name == "alarm") () async {},
      () async {
        bool value = await widget.deviceInteractor.getTimeFormat();
        setState(() => _functionOn["TimeFormat"] = value);
      },
      () async {
        var data = await widget.deviceInteractor.getNightMode();
        setState(() {
          _functionOn["NightMode"] = data[0];
          _pickedStartTime = data[1];
          _pickedEndTime = data[2];
        });
      },
      () async {
        int value = await widget.deviceInteractor.getHourGlass();
        setState(() => _sliderValue = value.toDouble());
      },
      () async {
        var time = await widget.deviceInteractor.getTime();
        setState(() => _pickedDateTime = time);
      },
      () async {
        bool value = await widget.deviceInteractor.getNixieDots();
        setState(() => _functionOn["NixieDots"] = value);
      },
    ];

    List _functionItems = [
      if (widget.name == "alarm")
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
                    var time = await DatePicker.showTimePicker(context, currentTime: _pickedAlarmTime);
                    if (time != null) setState(() => _pickedAlarmTime = time);
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.detailTimeFormatText.tr()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: _functionOn["TimeFormat"]! ? const Color(0xFFFCE9A7) : Colors.black,
                      onPrimary: _functionOn["TimeFormat"]! ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: const Text("24 h", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await widget.deviceInteractor.setTimeFormat(0);
                      setState(() => _functionOn["TimeFormat"] = false);
                    },
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: !_functionOn["TimeFormat"]! ? const Color(0xFFFCE9A7) : Colors.black,
                      onPrimary: !_functionOn["TimeFormat"]! ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: const Text("12 h", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await widget.deviceInteractor.setTimeFormat(1);
                      setState(() => _functionOn["TimeFormat"] = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
      NameIconWidget(
        LocaleKeys.detailNightMode.tr(),
        Icons.mode_night,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocaleKeys.detailNightModeText.tr()),
                  Transform.scale(
                    scale: 1.5,
                    child: Switch(
                      value: _functionOn["NightMode"]!,
                      onChanged: (value) async {
                        await widget.deviceInteractor.setNightModeOnOff(value);
                        setState(() => _functionOn["NightMode"] = value);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.black,
                    ),
                  ),
                ],
              ),
              if (_functionOn["NightMode"]!)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                      child: Column(
                        children: [
                          Text(LocaleKeys.detailNighModeStart.tr(), style: const TextStyle(fontSize: 15)),
                          Text(
                            "${_pickedStartTime.hour.toString().padLeft(2, '0')}:${_pickedStartTime.minute.toString().padLeft(2, '0')}:${_pickedStartTime.second.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      onPressed: () async => await DatePicker.showTimePicker(context, currentTime: _pickedStartTime, showTitleActions: false, onChanged: (time) => setState(() => _pickedStartTime = time)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                      child: Column(
                        children: [
                          Text(LocaleKeys.detailNighModeEnd.tr(), style: const TextStyle(fontSize: 15)),
                          Text(
                            "${_pickedEndTime.hour.toString().padLeft(2, '0')}:${_pickedEndTime.minute.toString().padLeft(2, '0')}:${_pickedEndTime.second.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      onPressed: () async => await DatePicker.showTimePicker(context, currentTime: _pickedEndTime, showTitleActions: false, onChanged: (time) => setState(() => _pickedEndTime = time)),
                    ),
                  ],
                ),
              if (_functionOn["NightMode"]!)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    child: Text(LocaleKeys.detailNighModeSet.tr(), style: const TextStyle(fontSize: 17, color: Colors.white)),
                    onPressed: () async => await widget.deviceInteractor.setNightModeTime(_pickedStartTime, _pickedEndTime),
                  ),
                ),
            ],
          ),
        ),
      ),
      NameIconWidget(
        LocaleKeys.detailHourglass.tr(),
        Icons.hourglass_empty,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.detailHourglassText.tr()),
              Column(
                children: [
                  Slider(
                    value: _sliderValue,
                    activeColor: Colors.grey,
                    inactiveColor: Colors.grey,
                    thumbColor: Colors.white,
                    max: 4,
                    divisions: 4,
                    onChangeEnd: (value) async => await widget.deviceInteractor.setHourglass(value.toInt()),
                    onChanged: (value) => setState(() => _sliderValue = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: hourGlassLabels.map((name) => Text(name, style: hourGlassLabels.indexOf(name) == _sliderValue ? const TextStyle(fontSize: 15, fontWeight: FontWeight.bold) : null)).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
      NameIconWidget(
        LocaleKeys.detailCustomTime.tr(),
        Icons.timer,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocaleKeys.detailCustomTimeText.tr()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                    child: Column(
                      children: [
                        Text(LocaleKeys.detailCustomTimeDate.tr(), style: const TextStyle(fontSize: 15)),
                        Text(
                          "${_pickedDateTime.year.toString()}-${_pickedDateTime.month.toString().padLeft(2, '0')}-${_pickedDateTime.day.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      await DatePicker.showDatePicker(context, currentTime: _pickedDateTime, showTitleActions: false, maxTime: DateTime(2037, 12, 31), onChanged: (date) {
                        setState(() => _pickedDateTime = DateTime(date.year, date.month, date.day, _pickedDateTime.hour, _pickedDateTime.minute, _pickedDateTime.second));
                      }, locale: context.locale == const Locale("cs") ? LocaleType.cs : LocaleType.en);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5)),
                    child: Column(
                      children: [
                        Text(LocaleKeys.detailCustomTimeTime.tr(), style: const TextStyle(fontSize: 15)),
                        Text(
                          "${_pickedDateTime.hour.toString().padLeft(2, '0')}:${_pickedDateTime.minute.toString().padLeft(2, '0')}:${_pickedDateTime.second.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onPressed: () async => await DatePicker.showTimePicker(
                      context,
                      currentTime: _pickedDateTime,
                      showTitleActions: false,
                      onChanged: (time) => setState(() => _pickedDateTime = DateTime(_pickedDateTime.year, _pickedDateTime.month, _pickedDateTime.day, time.hour, time.minute, time.second)),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: Text(LocaleKeys.detailNighModeSet.tr(), style: const TextStyle(fontSize: 17, color: Colors.white)),
                  onPressed: () async => await widget.deviceInteractor.setTime(_pickedDateTime),
                ),
              ),
            ],
          ),
        ),
      ),
      NameIconWidget(
        LocaleKeys.detailNixieDots.tr(),
        Icons.bubble_chart,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.detailNixieDotsText.tr()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: _functionOn["NixieDots"]! ? const Color(0xFFFCE9A7) : Colors.black,
                      onPrimary: _functionOn["NixieDots"]! ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: Text(LocaleKeys.detailNixieDotsOff.tr(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await widget.deviceInteractor.setNixieDots(0);
                      setState(() => _functionOn["NixieDots"] = false);
                    },
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: !_functionOn["NixieDots"]! ? const Color(0xFFFCE9A7) : Colors.black,
                      onPrimary: !_functionOn["NixieDots"]! ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: Text(LocaleKeys.detailNixieDotsOn.tr(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await widget.deviceInteractor.setNixieDots(1);
                      setState(() => _functionOn["NixieDots"] = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 0),
            ],
          ),
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
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    Flexible(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 135, child: Text(widget.name, style: const TextStyle(fontFamily: "Abraham", fontSize: 50, height: 1))),
                                    Text(widget.id),
                                  ],
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(primary: Colors.black),
                                  child: Icon(favorite ? Icons.favorite : Icons.favorite_border, size: 40, color: Colors.black),
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    if (favorite) {
                                      prefs.remove("favorite_device");
                                    } else {
                                      prefs.setString("favorite_device", widget.id.toString());
                                    }
                                    var tmp = await isFavorite(widget.id);
                                    setState(() => favorite = tmp);
                                  },
                                ),
                              ],
                            ),
                            Expanded(child: Center(child: SizedBox(width: 280, child: Hero(tag: widget.id, child: Image.asset("assets/clock.png", fit: BoxFit.contain))))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      flex: 1,
                      child: (widget.connectionStatus.connected && _fwCheck)
                          ? Container(
                              width: double.infinity,
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: MaterialButton(
                                child: Text(LocaleKeys.detailSyncTime.tr(), style: const TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  bool result = await widget.deviceInteractor.setTime(_now);
                                  if (!result) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LocaleKeys.detailUnpairWarning.tr())));
                                  }
                                },
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.all(Radius.circular(10))),
                            ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        CircularProgressIndicator(color: (!widget.connectionStatus.connected || !_fwCheck) ? Colors.black : Colors.transparent),
                      ],
                    ),
                  ],
                ),
              )
            else
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 20, top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 135, child: Text(widget.name, style: const TextStyle(fontFamily: "Abraham", fontSize: 50, height: 1))),
                              Text(widget.id),
                              const SizedBox(height: 15),
                            ],
                          ),
                          SizedBox(width: 170, child: Image.asset("assets/clock.png", fit: BoxFit.contain)),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_functionItems[_functionNum].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                SizedBox(height: _functionReading ? 90 : 5),
                                _functionReading ? const Center(child: CircularProgressIndicator(color: Colors.black)) : _functionItems[_functionNum].widget,
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
                    ),
                    const Flexible(child: SizedBox()),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(margin: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.detailMore.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _scrollController.animateTo(_scrollController.position.pixels - 110, duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 35), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ListView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          children: _functionItems
                              .map(
                                (fce) => widget.connectionStatus.connected && _fwCheck
                                    ? Card(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                        margin: EdgeInsets.only(top: 5, bottom: 5, right: _functionItems.indexOf(fce) == _functionItems.length - 1 ? 0 : 10),
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(Radius.circular(7)),
                                          onTap: () async {
                                            if (_functionNum == _functionItems.indexOf(fce)) {
                                              if (_functionOpen) {
                                                setState(() => _functionOpen = false);
                                              } else {
                                                setState(() {
                                                  _functionOpen = true;

                                                  _functionReading = true;
                                                });
                                                await _functionsInit[_functionNum]();
                                                setState(() => _functionReading = false);
                                              }
                                            } else {
                                              setState(() {
                                                _functionOpen = true;
                                                _functionNum = _functionItems.indexOf(fce);

                                                _functionReading = true;
                                              });
                                              await _functionsInit[_functionNum]();
                                              setState(() => _functionReading = false);
                                            }
                                          },
                                          child: SizedBox(
                                            width: 100,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(fce.icon, size: 30, color: _functionOpen && _functionItems.indexOf(fce) == _functionNum ? const Color(0xFFFCD205) : Colors.black),
                                                const SizedBox(height: 10),
                                                Text(
                                                  fce.name,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 12, color: _functionOpen && _functionItems.indexOf(fce) == _functionNum ? const Color(0xFFFCD205) : Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Card(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                        margin: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
                                        child: const SizedBox(width: 100),
                                      ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _scrollController.animateTo(_scrollController.position.pixels + 110, duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 35), child: const Icon(Icons.arrow_forward_ios_rounded, size: 20)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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

  int versionCompare(String v1, String v2) {
    int vnum1 = 0, vnum2 = 0;
    for (int i = 0, j = 0; i < v1.length || j < v2.length;) {
      while (i < v1.length && v1[i] != '.') {
        vnum1 = vnum1 * 10 + int.parse(v1[i++]);
      }
      while (j < v2.length && v2[j] != '.') {
        vnum2 = vnum2 * 10 + int.parse(v2[j++]);
      }
      if (vnum1 > vnum2) {
        return 1;
      } else if (vnum2 > vnum1) {
        return -1;
      } else {
        vnum1 = vnum2 = 0;
        i++;
        j++;
      }
    }
    return 0;
  }

  Future<void> _connectionReaction() async {
    var discoveredServices = await widget.deviceInteractor.discoverServices(widget.id);
    if (discoveredServices[2].characteristicIds.contains(Uuid.parse("00002A26-0000-1000-8000-00805F9B34FB"))) {
      widget.deviceInteractor.discoverCharacteristics(true, widget.id);
      var fwVer = await widget.deviceInteractor.readFwRev();

      if (versionCompare(fwVer, latestFwVer) == -1) await _showUpdateAlert(context, fwVer);
      if (versionCompare(fwVer, latestFwVer) == 1) await _showNewFirmwareAlert(context, fwVer);
    } else {
      await _showOldFirmwareAlert(context);
    }
    widget.deviceInteractor.discoverCharacteristics(false, widget.id);
    _fwCheck = true;
  }

  Future<void> _showNewFirmwareAlert(BuildContext context, String fwVer) async {
    _showingDialog = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(LocaleKeys.detailFwAlertNewer.tr()),
        content: Text(LocaleKeys.detailFwAlertNewerText.tr(args: [fwVer, latestFwVer])),
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
                }
              },
            ),
          ),
        ],
      ),
    );
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
          title: Text(LocaleKeys.detailFwAlertUpdate.tr()),
          content: Text(LocaleKeys.detailFwAlertLegacyText.tr()),
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
              title: Text(LocaleKeys.detailFwAlertUpdate.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocaleKeys.detailFwAlertUpdateText.tr(args: [fwVer, latestFwVer])),
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
                          await widget.startDFU(widget.id, true, setState);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _showingDialog = false;
                        }
                      : null,
                  child: Text(LocaleKeys.detailFwAlertUpdateButton.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<bool> isFavorite(String id) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("favorite_device") == id;
}

class NameIconWidget {
  final String name;
  final IconData icon;
  final Widget widget;
  const NameIconWidget(this.name, this.icon, this.widget);
}
