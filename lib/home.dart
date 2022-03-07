import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'translations/locale_keys.g.dart';
import 'search_results.dart';

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
      NameIconFunction(LocaleKeys.license.tr(), Icons.assignment, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const License()))),
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
            decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
            child: MaterialButton(
              child: Text(LocaleKeys.search_2.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchResult())),
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
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name, style: const TextStyle(color: Colors.black, fontFamily: "Abraham", fontSize: 25)),
                          Container(
                            height: 45,
                            decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
                            child: MaterialButton(
                              child: Text(LocaleKeys.download.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              onPressed: () => launch(item.link),
                            ),
                          ),
                        ],
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
                    (item) => InkWell(
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      onTap: item.function,
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 2))],
                        ),
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

class Credits extends StatelessWidget {
  const Credits({Key? key}) : super(key: key);

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
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Stack(
                children: const [
                  Text(
                    "Created by",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, top: 25),
                    child: Text(
                      "Michal Valkoun",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Stack(
                children: const [
                  Text(
                    "Design by",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, top: 25),
                    child: Text(
                      "Aneta Kalousková",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFFCD205), borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Stack(
                children: const [
                  Text(
                    "Firmware by",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, top: 25),
                    child: Text(
                      "Ondřej Nentvich",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class License extends StatelessWidget {
  const License({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios), color: Colors.black), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(child: Container(margin: const EdgeInsets.symmetric(horizontal: 20), child: licence)),
    );
  }
}

const TextStyle h2Style = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
const TextStyle h3Style = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
const TextStyle pStyle = TextStyle(fontSize: 17);

Widget licence = Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: const [
    Text('End-User License Agreement (EULA) of Noyce Joyce Nixie', style: h2Style),
    SizedBox(height: 15),
    Text('This End-User License Agreement ("EULA") is a legal agreement between you and Noyce Joyce Nixie', style: pStyle),
    SizedBox(height: 15),
    Text(
        'This EULA agreement governs your acquisition and use of our Noyce Joyce Nixie software ("Software") directly from Noyce Joyce Nixie or indirectly through a Noyce Joyce Nixie authorized reseller or distributor (a "Reseller").',
        style: pStyle),
    SizedBox(height: 15),
    Text(
        'Please read this EULA agreement carefully before completing the installation process and using the Noyce Joyce Nixie software. It provides a license to use the Noyce Joyce Nixie software and contains warranty information and liability disclaimers.',
        style: pStyle),
    SizedBox(height: 15),
    Text(
        'If you register for a free trial of the Noyce Joyce Nixie software, this EULA agreement will also govern that trial. By clicking "accept" or installing and/or using the Noyce Joyce Nixie software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement.',
        style: pStyle),
    SizedBox(height: 15),
    Text(
        'If you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.',
        style: pStyle),
    SizedBox(height: 15),
    Text(
        'This EULA agreement shall apply only to the Software supplied by Noyce Joyce Nixie herewith regardless of whether other software is referred to or described herein. The terms also apply to any Noyce Joyce Nixie updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply.',
        style: pStyle),
    SizedBox(height: 20),
    Text('License Grant', style: h3Style),
    SizedBox(height: 15),
    Text('Noyce Joyce Nixie hereby grants you a personal, non-transferable, non-exclusive licence to use the Noyce Joyce Nixie software on your devices in accordance with the terms of this EULA agreement.',
        style: pStyle),
    SizedBox(height: 15),
    Text(
        'You are permitted to load the Noyce Joyce Nixie software (for example a PC, laptop, mobile or tablet) under your control. You are responsible for ensuring your device meets the minimum requirements of the Noyce Joyce Nixie software.',
        style: pStyle),
    SizedBox(height: 15),
    Text('You are not permitted to:', style: pStyle),
    SizedBox(height: 15),
    Text(
        '\u2022 Edit, alter, modify, adapt, translate or otherwise change the whole or any part of the Software nor permit the whole or any part of the Software to be combined with or become incorporated in any other software, nor decompile, disassemble or reverse engineer the Software or attempt to do any such things',
        style: pStyle),
    Text('\u2022 Reproduce, copy, distribute, resell or otherwise use the Software for any commercial purpose', style: pStyle),
    Text('\u2022 Allow any third party to use the Software on behalf of or for the benefit of any third party', style: pStyle),
    Text('\u2022 Use the Software in any way which breaches any applicable local, national or international law', style: pStyle),
    Text('\u2022 use the Software for any purpose that Noyce Joyce Nixie considers is a breach of this EULA agreement', style: pStyle),
    SizedBox(height: 20),
    Text('Intellectual Property and Ownership', style: h3Style),
    SizedBox(height: 15),
    Text(
        'Noyce Joyce Nixie shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Noyce Joyce Nixie.',
        style: pStyle),
    SizedBox(height: 15),
    Text('Noyce Joyce Nixie reserves the right to grant licences to use the Software to third parties.', style: pStyle),
    SizedBox(height: 20),
    Text('Termination', style: h3Style),
    SizedBox(height: 15),
    Text('This EULA agreement is effective from the date you first use the Software and shall continue until terminated. You may terminate it at any time upon written notice to Noyce Joyce Nixie.', style: pStyle),
    Text(
        'It will also terminate immediately if you fail to comply with any term of this EULA agreement. Upon such termination, the licenses granted by this EULA agreement will immediately terminate and you agree to stop all access and use of the Software. The provisions that by their nature continue and survive will survive any termination of this EULA agreement.',
        style: pStyle),
    SizedBox(height: 20),
    Text('Governing Law', style: h3Style),
    SizedBox(height: 15),
    Text('This EULA agreement, and any dispute arising out of or in connection with this EULA agreement, shall be governed by and construed in accordance with the laws of Czechia.', style: pStyle),
    SizedBox(height: 20),
  ],
);
