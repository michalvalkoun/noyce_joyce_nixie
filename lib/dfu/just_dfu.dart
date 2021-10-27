import 'dart:async';
import 'package:flutter_nordic_dfu/flutter_nordic_dfu.dart';

class JustDFU {
  bool _runningDFU = false;
  bool getRunningDFU() {
    return _runningDFU;
  }

  Future<bool> startDFU(deviceId) async {
    _runningDFU = true;
    try {
      await FlutterNordicDfu.startDfu(
        deviceId,
        'assets/file.zip',
        fileInAsset: true,
      );
      _runningDFU = false;
      return true;
    } catch (error) {
      _runningDFU = false;
      return false;
    }
  }

  Future<void> stopDFU(deviceId) async {
    await FlutterNordicDfu.abortDfu();
  }
}
