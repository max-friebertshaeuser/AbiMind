import 'dart:convert';

import 'package:Abimind/presentation/screens/start/components/streak_settings_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/constants.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late Future<Map<String, dynamic>> sidebarData;

  @override
  void initState() {
    super.initState();
    sidebarData = loadSidebarData();
  }

  Future<Map<String, dynamic>> loadSidebarData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/sidebar.json',
    );
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: sidebarData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available.'));
        }

        final data = snapshot.data!;
        final corrected = data['corrected'] as List<dynamic>;
        final inProgress = data['in_progress'] as List<dynamic>;

        return Drawer(
          child: Container(
            color: const Color(0xFFF9F4FC),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              children: [
                Image.asset('assets/logo.png', height: 30),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Streak Challenge"),
                  onTap: () {
                    print("Profile was clicked");
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const StreakSettingScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                      "Continue",
                      style: sideBarTextStyle
                  ),
                ),

                ...inProgress.map(
                      (item) => ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(item['name']),
                    onTap: () {
                      print("${item['name']} (in progress) was clicked");
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                      "Correction",
                      style: sideBarTextStyle
                  ),
                ),
                ...corrected.map(
                      (item) => ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(item['name']),
                    onTap: () {
                      print("${item['name']} (corrected) was clicked");
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    print("Settings was clicked");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
