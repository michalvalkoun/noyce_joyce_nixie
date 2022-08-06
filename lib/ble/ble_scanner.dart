import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'reactive_state.dart';
import 'package:meta/meta.dart';
import 'package:noyce_joyce_nixie/constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:noyce_joyce_nixie/translations/locale_keys.g.dart';

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner({required this.ble, required this.logMessage});

  final FlutterReactiveBle ble;
  final void Function(String message) logMessage;
  final StreamController<BleScannerState> _stateStreamController = StreamController();

  final List<DiscoveredDevice> _devices = [];
  StreamSubscription<DiscoveredDevice>? _subscription;
  int _scanTimer = 0;
  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  Future<int> checkPermissions() async {
    var statusScan = await Permission.bluetoothScan.request();
    var statusConnect = await Permission.bluetoothConnect.request();
    var statusLocation = await Permission.location.request();
    if (statusScan.isGranted && statusConnect.isGranted && statusLocation.isGranted) {
      return 1;
    } else if (statusScan.isPermanentlyDenied || statusConnect.isPermanentlyDenied || statusLocation.isPermanentlyDenied) {
      return -1;
    } else {
      return 0;
    }
  }

  bool startScan() {
    if (_scanTimer >= 5) return false;
    Future.delayed(const Duration(seconds: 30), () => _scanTimer--);
    _scanTimer++;
    logMessage('Start ble discovery');
    _devices.clear();
    _subscription?.cancel();
    _subscription = ble.scanForDevices(withServices: [Uuid.parse(infoServiceUuid), Uuid.parse(dfuServiceUuid)]).listen((device) {
      if (device.name.contains("Nixie Clock") || device.name.contains("Nixie Alarm-Clock")) {
        final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          _devices[knownDeviceIndex] = device;
        } else {
          _devices.add(device);
        }
      }
      _pushState();
    }, onError: (Object e) => logMessage('Device scan fails with error: $e'));
    _pushState();
    return true;
  }

  Future<void> stopScan() async {
    logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  String determineText(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return LocaleKeys.listBleStatus1.tr();
      case BleStatus.unauthorized:
        return LocaleKeys.listBleStatus2.tr();
      case BleStatus.poweredOff:
        return LocaleKeys.listBleStatus3.tr();
      case BleStatus.locationServicesDisabled:
        return LocaleKeys.listBleStatus4.tr();
      default:
        return "";
    }
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(discoveredDevices: _devices, scanIsInProgress: _subscription != null),
    );
  }
}

@immutable
class BleScannerState {
  const BleScannerState({this.discoveredDevices = const [], this.scanIsInProgress = false});

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
