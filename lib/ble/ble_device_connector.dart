import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'reactive_state.dart';
import 'package:meta/meta.dart';

class BleDeviceConnector implements ReactiveState<BleConnectionState> {
  BleDeviceConnector({required this.ble, required this.logMessage});

  final FlutterReactiveBle ble;
  final void Function(String message) logMessage;
  final StreamController<BleConnectionState> _stateStreamController = StreamController<BleConnectionState>();

  String _deviceId = "";
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  @override
  Stream<BleConnectionState> get state => _stateStreamController.stream;

  Future<void> connect(String deviceId, Function connected, Function disconnected) async {
    _deviceId = deviceId;
    logMessage('Start connecting to $deviceId');
    _connection = ble.connectToDevice(id: deviceId, connectionTimeout: const Duration(seconds: 30)).listen(
      (status) async {
        print("Connect: ${status.connectionState}");
        logMessage('ConnectionState for device $deviceId : ${status.connectionState}');
        _connectionState = status.connectionState;
        _pushState();
        if (status.connectionState == DeviceConnectionState.connected) connected();
        if (status.connectionState == DeviceConnectionState.disconnected) disconnected();
      },
      onError: (Object e) => logMessage('Connecting to device $deviceId resulted in error $e'),
    );
  }

  Future<void> disconnect(String deviceId) async {
    try {
      logMessage('disconnecting to device: $deviceId');
      await _connection.cancel();
    } on Exception catch (e) {
      logMessage("Error disconnecting from a device: $e");
    } finally {
      _connectionState = DeviceConnectionState.disconnected;
      _pushState();
    }
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  void _pushState() {
    _stateStreamController.add(BleConnectionState(deviceId: _deviceId, connectionState: _connectionState, connected: _connectionState == DeviceConnectionState.connected));
  }
}

@immutable
class BleConnectionState {
  const BleConnectionState({this.deviceId = "", this.connectionState = DeviceConnectionState.disconnected, this.connected = false});

  final String deviceId;
  final DeviceConnectionState connectionState;
  final bool connected;
}
