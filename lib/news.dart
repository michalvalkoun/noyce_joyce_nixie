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
