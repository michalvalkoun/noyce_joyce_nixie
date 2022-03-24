import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'translations/locale_keys.g.dart';
import 'device_list.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    List _manuals = [
      Manual(LocaleKeys.clock.tr(), LocaleKeys.clockLink.tr()),
      Manual(LocaleKeys.alarm.tr(), LocaleKeys.alarmLink.tr()),
    ];
    List _other = [
      NameIconFunction(LocaleKeys.shop.tr(), Icons.shopping_cart, () => launch(LocaleKeys.eshopLink.tr())),
      NameIconFunction("Credits", Icons.people, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Credits()))),
    ];
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.only(left: 20, top: 40), child: InkWell(child: Image.asset("assets/logo.png", scale: 7), onTap: () => launch(LocaleKeys.noyceLink.tr()))),
              Padding(
                padding: const EdgeInsets.only(right: 30, top: 30),
                child: DropdownButton(
                    value: context.locale.toString().toUpperCase(),
                    elevation: 1,
                    items: ["CS", "EN"].map((value) => DropdownMenuItem(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), value: value)).toList(),
                    onChanged: (String? value) => context.setLocale(Locale(value!.toLowerCase()))),
              ),
            ],
          ),
          const SizedBox(height: 55),
          Padding(padding: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.search_1.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: const Color(0xFFFCD205), onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
              child: Text(LocaleKeys.search_2.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeviceListScreen())),
            ),
          ),
          const SizedBox(height: 40),
          Padding(padding: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.manuals.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _manuals
                  .map(
                    (item) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.name, style: const TextStyle(color: Colors.black, fontFamily: "Abraham", fontSize: 25)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: const Color(0xFFFCD205), onPrimary: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                              child: Text(LocaleKeys.download.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              onPressed: () => launch(item.link),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.only(left: 20), child: Text(LocaleKeys.other_things.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _other
                  .map(
                    (item) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(7)),
                        onTap: item.function,
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item.icon, size: 30, color: Colors.black),
                              const SizedBox(height: 10),
                              Text(item.name, style: const TextStyle(fontSize: 13, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class NameIconFunction {
  final String name;
  final IconData icon;
  final Function function;

  const NameIconFunction(this.name, this.icon, this.function);
}

class Manual {
  final String name;
  final String link;
  const Manual(this.name, this.link);
}

class CreditsName {
  final String title1;
  final String title2;
  const CreditsName(this.title1, this.title2);
}

class Credits extends StatelessWidget {
  const Credits({Key? key}) : super(key: key);
  final List _credits = const [
    CreditsName("Developed by", "Michal Valkoun"),
    CreditsName("Designed by", "Aneta Kalousková"),
    CreditsName("Firmware by", "Ondřej Nentvich"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios), color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _credits
              .map(
                (item) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Stack(
                    children: [
                      Text(
                        item.title1,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 25),
                        child: Text(
                          item.title2,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
