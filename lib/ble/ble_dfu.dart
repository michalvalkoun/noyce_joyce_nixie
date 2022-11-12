import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'reactive_state.dart';
import 'package:noyce_joyce_nixie/constant.dart';

class BleDFU implements ReactiveState<BleDFUState> {
  BleDFU({required this.logMessage});

  final void Function(String message) logMessage;
  final StreamController<BleDFUState> _stateStreamController = StreamController();

  String _adress = "";
  bool _dfuIsInProgress = false;
  double _dfuPercent = 0.0;

  @override
  Stream<BleDFUState> get state => _stateStreamController.stream;

  Future<void> startDFU(String deviceId, bool incMac, StateSetter setState) async {
    _adress = deviceId;
    _dfuIsInProgress = true;
    print(deviceId.length);
    _pushState(setState);

    try {
      await NordicDfu().startDfu(
        incMac ? _incMac(mac: deviceId) : deviceId,
        "assets/$latestFwVer.zip",
        fileInAsset: true,
        onProgressChanged: (deviceAddress, percent, speed, avgSpeed, currentPart, partsTotal) {
          _dfuPercent = percent / 100;
          _pushState(setState);
        },
      );
    } catch (error) {
      logMessage('DFU fails with error: $error');
    }
    _dfuIsInProgress = false;
    _dfuPercent = 0.0;
    _adress = "";
    _pushState(setState);
  }

  Future<void> stopDFU(setState) async {
    await NordicDfu().abortDfu();
    _dfuIsInProgress = false;
    _dfuPercent = 0.0;
    _adress = "";
    _pushState(setState);
  }

  String _incMac({required String mac, int start = 15, int end = 17}) {
    if (start < 0 || end < 0) return mac;
    var last = int.parse(mac.substring(start, end), radix: 16);
    if (last != 0xFF) {
      last++;
      mac = mac.replaceRange(start, end, last.toRadixString(16).toUpperCase());
    } else {
      mac = _incMac(mac: mac, start: start - 3, end: end - 3);
    }
    return mac;
  }

  void _pushState(StateSetter setState) {
    setState(() => _stateStreamController.add(BleDFUState(adress: _adress, dfuPercent: _dfuPercent, dfuIsInProgress: _dfuIsInProgress)));
  }
}

@immutable
class BleDFUState {
  const BleDFUState({this.adress = "", this.dfuPercent = 0.0, this.dfuIsInProgress = false});

  final String adress;
  final double dfuPercent;
  final bool dfuIsInProgress;
}
