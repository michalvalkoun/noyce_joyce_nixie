import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'ble/ble.dart';
import 'ble/ble_dfu.dart';
import 'translations/codegen_loader.g.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final bleLogger = BleLogger();
  final ble = FlutterReactiveBle();
  final monitor = BleStatusMonitor(ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final connector = BleDeviceConnector(ble: ble, logMessage: bleLogger.addToLog);
  final serviceDiscoverer = BleDeviceInteractor(ble: ble, logMessage: bleLogger.addToLog);
  final dfu = BleDFU(logMessage: bleLogger.addToLog);

  await EasyLocalization.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: monitor),
        Provider.value(value: scanner),
        Provider.value(value: connector),
        Provider.value(value: serviceDiscoverer),
        Provider.value(value: dfu),
        Provider.value(value: bleLogger),
        StreamProvider<BleStatus?>(create: (_) => monitor.state, initialData: BleStatus.unknown),
        StreamProvider<BleScannerState?>(create: (_) => scanner.state, initialData: const BleScannerState()),
        StreamProvider<BleConnectionState>(create: (_) => connector.state, initialData: const BleConnectionState()),
        StreamProvider<BleDFUState?>(create: (_) => dfu.state, initialData: const BleDFUState()),
      ],
      child: EasyLocalization(path: 'assets/translations', supportedLocales: const [Locale('en'), Locale('cs')], fallbackLocale: const Locale('en'), assetLoader: const CodegenLoader(), child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const HomeScreen(),
        builder: (context, child) => ResponsiveWrapper.builder(
          ClampingScrollWrapper.builder(context, child!),
          defaultScale: true,
          defaultScaleFactor: 1.2,
          breakpoints: const [ResponsiveBreakpoint.resize(450, name: PHONE, scaleFactor: 1.2)],
        ),
      );
}
