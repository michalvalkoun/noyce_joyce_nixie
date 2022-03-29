import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:noyce_joyce_nixie/constant.dart';

class BleDeviceInteractor {
  BleDeviceInteractor({required this.ble, required this.logMessage});

  final FlutterReactiveBle ble;
  final void Function(String message) logMessage;

  late QualifiedCharacteristic _firmwareRevisionCharacteristic;
  late QualifiedCharacteristic _dateTimeCharacteristic;
  late QualifiedCharacteristic _timeFormatCharacteristic;
  late QualifiedCharacteristic _nightModeOnOffCharacteristic;
  late QualifiedCharacteristic _nightModeStartCharacteristic;
  late QualifiedCharacteristic _nightModeEndCharacteristic;
  late QualifiedCharacteristic _hourGlassCharacteristic;
  late QualifiedCharacteristic _blOnCharacteristic;

  void discoverCharacteristics(bool initial, String deviceId) {
    if (initial) {
      _firmwareRevisionCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(infoServiceUuid), characteristicId: Uuid.parse("00002A26-0000-1000-8000-00805F9B34FB"), deviceId: deviceId);
      _blOnCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED14FF-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
    } else {
      _timeFormatCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1420-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
      _dateTimeCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1410-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
      _hourGlassCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1421-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
      _nightModeOnOffCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1423-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
      _nightModeStartCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1425-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
      _nightModeEndCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse(interfaceServiceUuid), characteristicId: Uuid.parse("A8ED1424-130A-4D4B-ACBA-5DE7E77E9B47"), deviceId: deviceId);
    }
  }

  Future<List<DiscoveredService>> discoverServices(String deviceId) async {
    try {
      logMessage('Start discovering services for: $deviceId');
      final result = await ble.discoverServices(deviceId);
      logMessage('Discovering services finished');
      return result;
    } on Exception catch (e) {
      logMessage('Error occured when discovering services: $e');
      rethrow;
    }
  }

  Future<List<int>> readCharacteristic(QualifiedCharacteristic characteristic) async {
    try {
      final result = await ble.readCharacteristic(characteristic);

      logMessage('Read ${characteristic.characteristicId}: value = $result');
      return result;
    } on Exception catch (e, s) {
      logMessage(
        'Error occured when reading ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacteristic(QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await ble.writeCharacteristicWithoutResponse(characteristic, value: value);
      logMessage('Write without response value: $value to ${characteristic.characteristicId}');
    } on Exception catch (e, s) {
      logMessage(
        'Error occured when writing ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> setNightModeOnOff(bool value) async {
    await writeCharacteristic(_nightModeOnOffCharacteristic, [value == true ? 1 : 0]);
  }

  Future<void> setNightModeTime(DateTime start, DateTime end) async {
    var startTimeStamp = ((start.millisecondsSinceEpoch + start.timeZoneOffset.inMilliseconds) / 1000).round();
    var endTimeStamp = ((end.millisecondsSinceEpoch + end.timeZoneOffset.inMilliseconds) / 1000).round();
    await writeCharacteristic(_nightModeStartCharacteristic, _intToList(startTimeStamp));
    await writeCharacteristic(_nightModeEndCharacteristic, _intToList(endTimeStamp));
  }

  Future<List> getNightMode() async {
    var state = await readCharacteristic(_nightModeOnOffCharacteristic);
    var start = await readCharacteristic(_nightModeStartCharacteristic);
    var end = await readCharacteristic(_nightModeEndCharacteristic);
    return [
      state[0] > 0 ? true : false,
      DateTime.fromMillisecondsSinceEpoch((_listToInt(start) - 3600) * 1000),
      DateTime.fromMillisecondsSinceEpoch((_listToInt(end) - 3600) * 1000),
    ];
  }

  Future<void> setHourglass(int value) async {
    await writeCharacteristic(_hourGlassCharacteristic, [value]);
  }

  Future<int> getHourGlass() async {
    var data = await readCharacteristic(_hourGlassCharacteristic);
    return data[0];
  }

  Future<void> setTimeFormat(int value) async {
    await writeCharacteristic(_timeFormatCharacteristic, [value]);
  }

  Future<bool> getTimeFormat() async {
    var data = await readCharacteristic(_timeFormatCharacteristic);
    return data[0] > 0 ? true : false;
  }

  Future<void> blOn() async {
    await writeCharacteristic(_blOnCharacteristic, [0x99]);
  }

  Future<String> readFwRev() async {
    var data = utf8.decode(await readCharacteristic(_firmwareRevisionCharacteristic));
    return data.split(' ')[2];
  }

  Future<void> setTime(DateTime time) async {
    var sendStamp = ((time.millisecondsSinceEpoch + time.timeZoneOffset.inMilliseconds) / 1000).round();
    await writeCharacteristic(_dateTimeCharacteristic, _intToList(sendStamp));
  }

  Future<DateTime> getTime() async {
    var data = await readCharacteristic(_dateTimeCharacteristic);
    return DateTime.fromMillisecondsSinceEpoch(_listToInt(data) * 1000 - DateTime.now().timeZoneOffset.inMilliseconds);
  }

  List<int> _intToList(int value) {
    return [value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF];
  }

  int _listToInt(List<int> data) {
    return data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24);
  }
}
