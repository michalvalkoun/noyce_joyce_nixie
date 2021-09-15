import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'my_app_bar.dart';

class Devices extends StatefulWidget {
  Devices({Key? key}) : super(key: key);

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List.empty();

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  ListView _buildListViewOfDevices() {
    List<Container> containers = new List.empty();
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              TextButton(
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        icon: Icons.settings,
        title: 'Devices',
        widget: AppSettings.openBluetoothSettings,
      ),
      body: _buildListViewOfDevices(),
    );
  }
}
