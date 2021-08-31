import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/services/HistoryService.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousAppBarTitle.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousBottomNavigationBar.dart';
import 'package:axis_inclinometer_monitor/services/SettingsService.dart';

class FavoritesScreen extends StatefulWidget {

  final RouteSettings? routeSettings;

  FavoritesScreen({Key? key, required this.routeSettings}) : super(key: key);

  @override
  _FavoritesScreenState createState() {
    return _FavoritesScreenState(payload: {'routeSettings': routeSettings});
  }

}

class _FavoritesScreenState extends State<FavoritesScreen> {

  Map payload = {};

  _FavoritesScreenState({required this.payload});

  static int selectedScreenIndex = 0;

  HistoryService historyService = new HistoryService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: UbiquitousAppBarTitle(subtitle: 'A list of your previously connected devices...'),
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
        children: historyService.getHistoryList(),
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
