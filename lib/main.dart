import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:noyce_joyce_nixie/ble/ble_dfu.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'ble/ble.dart';
import 'translations/codegen_loader.g.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final _bleLogger = BleLogger();
  final _ble = FlutterReactiveBle();
  final _monitor = BleStatusMonitor(_ble);
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _connector = BleDeviceConnector(ble: _ble, logMessage: _bleLogger.addToLog);
  final _serviceDiscoverer = BleDeviceInteractor(ble: _ble, logMessage: _bleLogger.addToLog);
  final _dfu = BleDFU(logMessage: _bleLogger.addToLog);

  await EasyLocalization.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _monitor),
        Provider.value(value: _scanner),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _dfu),
        Provider.value(value: _bleLogger),
        StreamProvider<BleStatus?>(create: (_) => _monitor.state, initialData: BleStatus.unknown),
        StreamProvider<BleScannerState?>(create: (_) => _scanner.state, initialData: const BleScannerState()),
        StreamProvider<BleConnectionState>(create: (_) => _connector.state, initialData: const BleConnectionState()),
        StreamProvider<BleDFUState?>(create: (_) => _dfu.state, initialData: const BleDFUState()),
      ],
      child: EasyLocalization(path: 'assets/translations', supportedLocales: const [Locale('en'), Locale('cs')], fallbackLocale: const Locale('en'), assetLoader: const CodegenLoader(), child: const MyApp()),
    ),
  );
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const HomeScreen(),
      builder: (context, child) => ResponsiveWrapper.builder(
        ScrollConfiguration(behavior: MyBehavior(), child: child!),
        defaultScale: true,
        defaultScaleFactor: 1.2,
        breakpoints: const [ResponsiveBreakpoint.resize(450, name: PHONE, scaleFactor: 1.2)],
      ),
    );
  }
}
