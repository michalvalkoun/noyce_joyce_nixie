import 'dart:async';
import 'package:nordic_dfu/nordic_dfu.dart';

class DFU {
  bool _runningDFU = false;
  String _adress = "";
  bool getRunningDFU() => _runningDFU;
  String getAdress() => _adress;

  Future<bool> startDFU(deviceId, file, progressListener, incMac) async {
    _adress = deviceId;
    _runningDFU = true;
    try {
      await NordicDfu.startDfu(incMac ? _incMac(deviceId, 15, 17) : deviceId, 'assets/$file.zip', fileInAsset: true, progressListener: progressListener);
      _runningDFU = false;
      return true;
    } catch (error) {
      _runningDFU = false;
      return false;
    }
  }

  Future<void> stopDFU(deviceId) async => await NordicDfu.abortDfu();

  String _incMac(String mac, int start, int end) {
    if (start < 0 || end < 0) return mac;
    var last = int.parse(mac.substring(start, end), radix: 16);
    if (last != 0xFF) {
      last++;
      mac = mac.replaceRange(start, end, last.toRadixString(16).toUpperCase());
    } else {
      mac = _incMac(mac, start - 3, end - 3);
    }
    return mac;
  }
}
