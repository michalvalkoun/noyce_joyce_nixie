import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings.dart';
import 'manuals.dart';
import 'update.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.amber[300]),
            child: Image.asset('assets/logo.png', height: 150, width: 250),
          ),
          ListTile(
              title: const Text('SETTINGS'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Settings()));
              }),
          ListTile(
              title: const Text('MANUALS'),
              leading: const Icon(Icons.auto_stories),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Manuals()));
              }),
          ListTile(
              title: const Text('UPDATE DEVICE'),
              leading: const Icon(Icons.security_update),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Update()));
              }),
          ListTile(
            title: const Text('SUPPORT'),
            leading: const Icon(Icons.people),
            onTap: () {
              Navigator.of(context).pop();
              launch('https://noycejoyce.com/support');
            },
          ),
          ListTile(
            title: const Text('PRIVACY POLICY'),
            leading: const Icon(Icons.error),
            onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                            '3Dsimo s.r.o. built the Nixie app as a Free app. This SERVICE is provided by 3Dsimo s.r.o. at no cost and is intended for use as is.This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Nixie unless otherwise defined in this Privacy Policy.'),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
