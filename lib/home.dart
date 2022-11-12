import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ble/ble_scanner.dart';
import 'translations/locale_keys.g.dart';
import 'device_list.dart';
import 'device_detail.dart';
import 'manuals.dart';
import 'news.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<BleStatus?, BleScanner>(
      builder: (_, bleStatus, bleScanner, __) => _Home(
        bleStatus: bleStatus ?? BleStatus.unknown,
        checkPermissions: bleScanner.checkPermissions,
        determineText: bleScanner.determineText,
      ),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({
    required this.bleStatus,
    required this.checkPermissions,
    required this.determineText,
    Key? key,
  }) : super(key: key);
  final BleStatus bleStatus;
  final Function() checkPermissions;
  final Function(BleStatus) determineText;

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  String _appVersion = "0.0.0";
  String? favorite;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => favorite = await hasFavorite());
    getAppVersion();
  }

  void getAppVersion() async {
    var tmp = await PackageInfo.fromPlatform();
    setState(() => _appVersion = tmp.version);
  }

  @override
  Widget build(BuildContext context) {
    List<NameIconFunction> menu = [
      NameIconFunction(LocaleKeys.homeManuals.tr(), LocaleKeys.homeManualsText.tr(), Icons.library_books, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Manuals()))),
      NameIconFunction(LocaleKeys.homeNews.tr(), LocaleKeys.homeNewsText.tr(), Icons.fiber_new, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const News()))),
      NameIconFunction(LocaleKeys.homePrivacy.tr(), LocaleKeys.homePrivacyText.tr(), Icons.privacy_tip, () => launchUrl(Uri.parse("https://sites.google.com/view/noycejoycenixie"))),
    ];
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Material(
              elevation: 3,
              color: const Color(0xFFFCD205),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(padding: const EdgeInsets.only(left: 20, top: 40), child: InkWell(child: Image.asset("assets/logo.png", scale: 8), onTap: () => launchUrl(Uri.parse(LocaleKeys.homeWebLink.tr())))),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 10),
                        child: DropdownButton(
                            icon: const Padding(padding: EdgeInsets.only(left: 15), child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 15)),
                            underline: Container(),
                            elevation: 1,
                            value: context.locale.toString().toUpperCase(),
                            items: ["CS", "EN"].map((value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 20)))).toList(),
                            onChanged: (String? value) => context.setLocale(Locale(value!.toLowerCase()))),
                      ),
                    ],
                  ),
                  Expanded(child: FittedBox(fit: BoxFit.contain, child: Image.asset("assets/home_devices.png", width: 280, height: 180))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            margin: const EdgeInsets.only(left: 20),
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeviceListScreen())).then((value) async {
                                  var tmp = await hasFavorite();
                                  setState(() => favorite = tmp);
                                }),
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(LocaleKeys.homeSearch.tr(), style: const TextStyle(fontSize: 17)),
                                      const Icon(Icons.search, size: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (favorite != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15))),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  if (widget.bleStatus != BleStatus.ready) {
                                    int permissonsResult = await widget.checkPermissions();
                                    if (widget.bleStatus != BleStatus.ready && widget.bleStatus != BleStatus.unknown) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(widget.determineText(widget.bleStatus)), action: permissonsResult == -1 ? SnackBarAction(label: LocaleKeys.listSettings.tr(), onPressed: () => openAppSettings()) : null),
                                      );
                                    }
                                  }
                                  if (widget.bleStatus == BleStatus.ready) {
                                    if (!mounted) return;
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeviceDetailScreen(id: favorite!, name: "Nixie Clock"))).then((value) async {
                                      var tmp = await hasFavorite();
                                      setState(() => favorite = tmp);
                                    });
                                  }
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                child: const SizedBox(height: 50, width: 50, child: Icon(Icons.favorite, size: 30)),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 0),
                const SizedBox(height: 0),
                ...menu.map(
                  (item) => InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => item.function(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(elevation: 2, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.all(8), child: Icon(item.icon, size: 30))),
                        const SizedBox(width: 30),
                        SizedBox(
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(item.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(margin: const EdgeInsets.all(5), alignment: Alignment.center, child: Text("${LocaleKeys.homeVersion.tr()} $_appVersion", textAlign: TextAlign.center)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> hasFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("favorite_device");
  }
}

class NameIconFunction {
  final String name;
  final String description;
  final IconData icon;
  final Function function;
  const NameIconFunction(this.name, this.description, this.icon, this.function);
}
