import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'translations/locale_keys.g.dart';
import 'device_list.dart';
import 'manuals.dart';
import 'news.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _appVersion = "0.0.0";
  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  void getAppVersion() async {
    var tmp = await PackageInfo.fromPlatform();
    setState(() => _appVersion = tmp.version);
  }

  @override
  Widget build(BuildContext context) {
    List<NameIconFunction> _menu = [
      NameIconFunction(LocaleKeys.homeManuals.tr(), LocaleKeys.homeManualsText.tr(), Icons.library_books, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Manuals()))),
      NameIconFunction(LocaleKeys.homeShop.tr(), LocaleKeys.homeShopText.tr(), Icons.shopping_cart, () => launch(LocaleKeys.homeShopLink.tr())),
      NameIconFunction(LocaleKeys.homeNews.tr(), LocaleKeys.homeNewsText.tr(), Icons.fiber_new, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const News()))),
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
                      Padding(padding: const EdgeInsets.only(left: 20, top: 40), child: InkWell(child: Image.asset("assets/logo.png", scale: 8), onTap: () => launch(LocaleKeys.homeWebLink.tr()))),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 10),
                        child: DropdownButton(
                            icon: const Padding(padding: EdgeInsets.only(left: 15), child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 15)),
                            underline: Container(),
                            elevation: 1,
                            value: context.locale.toString().toUpperCase(),
                            items: ["CS", "EN"].map((value) => DropdownMenuItem(child: Text(value, style: const TextStyle(fontSize: 20)), value: value)).toList(),
                            onChanged: (String? value) => context.setLocale(Locale(value!.toLowerCase()))),
                      ),
                    ],
                  ),
                  Expanded(child: FittedBox(fit: BoxFit.contain, child: Image.asset("assets/home_devices.png", width: 280, height: 180))),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeviceListScreen())),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(LocaleKeys.homeSearch.tr(), style: const TextStyle(fontSize: 20)),
                                const Icon(Icons.search, size: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
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
                ..._menu.map(
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
}

class NameIconFunction {
  final String name;
  final String description;
  final IconData icon;
  final Function function;
  const NameIconFunction(this.name, this.description, this.icon, this.function);
}
