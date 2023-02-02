import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import 'translations/locale_keys.g.dart';

class Manual {
  final String name;
  final String link;
  const Manual(this.name, this.link);
}

class Manuals extends StatelessWidget {
  const Manuals({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List manuals = [
      Manual("NIXIE CLOCK", LocaleKeys.homeClockLink.tr()),
      Manual("NIXIE ALARM", LocaleKeys.homeAlarmLink.tr()),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), color: Colors.black, onPressed: () => Navigator.pop(context)),
        title: Text(LocaleKeys.homeManuals.tr(), style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: manuals
            .map(
              (item) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                  onTap: () => launchUrl(Uri.parse(item.link), mode: LaunchMode.externalApplication),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.library_books, size: 35),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(context.locale.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        Text(item.name, style: const TextStyle(color: Colors.black, fontFamily: "Abraham", fontSize: 30)),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
