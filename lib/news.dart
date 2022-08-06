import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'translations/locale_keys.g.dart';
import 'package:http/http.dart' as http;

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  late Future<ReleaseTabs> releaseTabs;

  @override
  void initState() {
    super.initState();
    releaseTabs = fetchGitHubReleases();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReleaseTabs>(
      future: releaseTabs,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DefaultTabController(
            initialIndex: snapshot.data!.length - 1,
            length: snapshot.data!.length,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios), color: Colors.black, onPressed: () => Navigator.pop(context)),
                title: Text(LocaleKeys.homeNews.tr(), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                actions: [IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const License())), icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black, size: 25))],
                backgroundColor: Colors.transparent,
                centerTitle: true,
                elevation: 0,
                bottom: TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  isScrollable: true,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontSize: 17),
                  tabs: snapshot.data?.names.map((item) => Tab(text: item)).toList() ?? [],
                ),
              ),
              body: TabBarView(
                children: snapshot.data?.notes.map((item) {
                      return Padding(padding: const EdgeInsets.only(top: 20, left: 30, right: 30), child: ListView(children: [Center(child: Text(item, style: const TextStyle(fontSize: 15)))]));
                    }).toList() ??
                    [],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), color: Colors.black, onPressed: () => Navigator.pop(context)),
              title: Text(LocaleKeys.homeNews.tr(), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              actions: [IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const License())), icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black, size: 25))],
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
            ),
            body: Center(
              child: SizedBox(
                width: 300,
                child: Text(
                  snapshot.error.toString().split(": ")[0] == "SocketException" ? LocaleKeys.newsWIFI.tr() : LocaleKeys.newsServer.tr(),
                  style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios), color: Colors.black, onPressed: () => Navigator.pop(context)),
            title: Text(LocaleKeys.homeNews.tr(), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            actions: [IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const License())), icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black, size: 25))],
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
          body: const Center(child: CircularProgressIndicator(color: Colors.black)),
        );
      },
    );
  }

  Future<ReleaseTabs> fetchGitHubReleases() async {
    final response = await http.get(Uri.parse('https://api.github.com/repos/michalvalkoun/noyce_joyce_nixie/releases'));
    if (response.statusCode == 200) {
      return ReleaseTabs.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('');
    }
  }
}

class ReleaseTabs {
  final int length;
  final List<String> names;
  final List<String> notes;
  const ReleaseTabs(this.length, this.names, this.notes);
  factory ReleaseTabs.fromJson(json) {
    List<String> nameList = [];
    List<String> notesList = [];
    for (var release in json) {
      nameList.add(release["tag_name"]);
      notesList.add(release["body"]);
    }
    nameList.removeLast();
    nameList.removeLast();
    notesList.removeLast();
    notesList.removeLast();

    return ReleaseTabs(json.length - 2, nameList.reversed.toList(), notesList.reversed.toList());
  }
}

class License extends StatelessWidget {
  const License({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(LocaleKeys.newsLicense.tr(), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios), color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0),
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
    Text('This EULA agreement governs your acquisition and use of our Noyce Joyce Nixie software ("Software") directly from Noyce Joyce Nixie or indirectly through a Noyce Joyce Nixie authorized reseller or distributor (a "Reseller").',
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
    Text('Noyce Joyce Nixie hereby grants you a personal, non-transferable, non-exclusive licence to use the Noyce Joyce Nixie software on your devices in accordance with the terms of this EULA agreement.', style: pStyle),
    SizedBox(height: 15),
    Text('You are permitted to load the Noyce Joyce Nixie software (for example a PC, laptop, mobile or tablet) under your control. You are responsible for ensuring your device meets the minimum requirements of the Noyce Joyce Nixie software.',
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
