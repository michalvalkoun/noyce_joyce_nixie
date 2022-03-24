import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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

  Future<void> nightModeTime(TimeOfDay start, TimeOfDay end) async {
    var startTimeStamp = start.hour * 3600 + start.minute * 60;
    var endTimeStamp = end.hour * 3600 + end.minute * 60;
    await writeCharacteristic(
      _nightModeStartCharacteristic,
      [startTimeStamp & 0xFF, (startTimeStamp >> 8) & 0xFF, (startTimeStamp >> 16) & 0xFF, (startTimeStamp >> 24) & 0xFF],
    );
    await writeCharacteristic(
      _nightModeEndCharacteristic,
      [endTimeStamp & 0xFF, (endTimeStamp >> 8) & 0xFF, (endTimeStamp >> 16) & 0xFF, (endTimeStamp >> 24) & 0xFF],
    );
  }

  Future<List> readNightMode() async {
    var data = await readCharacteristic(_nightModeOnOffCharacteristic) + await readCharacteristic(_nightModeStartCharacteristic) + await readCharacteristic(_nightModeEndCharacteristic);
    var tmpStartDate = DateTime.fromMillisecondsSinceEpoch((data[1] + (data[2] << 8) + (data[3] << 16) + (data[4] << 24)) * 1000);
    var tmpEndDate = DateTime.fromMillisecondsSinceEpoch((data[5] + (data[6] << 8) + (data[7] << 16) + (data[8] << 24)) * 1000);
    return [data[0] > 0 ? true : false, TimeOfDay(hour: tmpStartDate.hour - 1, minute: tmpStartDate.minute), TimeOfDay(hour: tmpEndDate.hour - 1, minute: tmpEndDate.minute)];
  }

  Future<int> readHourGlass() async {
    var data = await readCharacteristic(_hourGlassCharacteristic);
    return data[0];
  }

  Future<bool> readTimeFormat() async {
    var data = await readCharacteristic(_timeFormatCharacteristic);
    return data[0] > 0 ? true : false;
  }

  Future<void> hourglass(int value) async {
    await writeCharacteristic(_hourGlassCharacteristic, [value]);
  }

  Future<void> nightModeOnOff(bool value) async {
    await writeCharacteristic(_nightModeOnOffCharacteristic, [value == true ? 1 : 0]);
  }

  Future<void> timeFormat(int value) async {
    await writeCharacteristic(_timeFormatCharacteristic, [value]);
  }

  Future<void> blOn() async {
    await writeCharacteristic(_blOnCharacteristic, [0x99]);
  }

  Future<String> readFwRev() async {
    var data = utf8.decode(await readCharacteristic(_firmwareRevisionCharacteristic));
    return data.split(' ')[2];
  }

  Future<void> syncTime(DateTime _now) async {
    var sendStamp = ((_now.millisecondsSinceEpoch + _now.timeZoneOffset.inMilliseconds) / 1000).round();
    await writeCharacteristic(
      _dateTimeCharacteristic,
      [sendStamp & 0xFF, (sendStamp >> 8) & 0xFF, (sendStamp >> 16) & 0xFF, (sendStamp >> 24) & 0xFF],
    );
  }
}
