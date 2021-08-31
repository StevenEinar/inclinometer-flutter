import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousAppBarTitle.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousBottomNavigationBar.dart';
import 'package:axis_inclinometer_monitor/services/SettingsService.dart';

class SettingsScreen extends StatefulWidget {

  final RouteSettings? routeSettings;

  SettingsScreen({Key? key, required this.routeSettings}) : super(key: key);

  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState(payload: {'routeSettings': routeSettings});
  }

}

class _SettingsScreenState extends State<SettingsScreen> {

  Map? payload = {};

  _SettingsScreenState({required this.payload});

  static int selectedScreenIndex = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: UbiquitousAppBarTitle(subtitle: 'Manage the app settings...'),
          backgroundColor: Colors.teal,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh available device list',
              onPressed: () {
                // handle the press
              },
            ),
          ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: getSettingsList(),
      ),
      bottomNavigationBar: UbiquitousBottomNavigationBar(selectedIndex: selectedScreenIndex),
    );
  }

  List<Widget> getSettingsList() {
    return <Widget>[
      Placeholder(color: Colors.purple,)
    ];
  }

}
