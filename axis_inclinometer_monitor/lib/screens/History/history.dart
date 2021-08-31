import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousAppBarTitle.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousBottomNavigationBar.dart';
import 'package:axis_inclinometer_monitor/services/HistoryService.dart';

class HistoryScreen extends StatefulWidget {

  final RouteSettings? routeSettings;

  HistoryScreen({Key? key, required this.routeSettings}) : super(key: key);

  @override
  _HistoryScreenState createState() {
    return _HistoryScreenState(payload: {'routeSettings': routeSettings});
  }

}

class _HistoryScreenState extends State<HistoryScreen> {

  Map? payload = {};

  _HistoryScreenState({required this.payload});

  static int selectedScreenIndex = 2;

  HistoryService historyService = new HistoryService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UbiquitousAppBarTitle(subtitle: 'View historical logs of previous device sessions...'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh available history list',
            onPressed: () {
              setState(() {

              });
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

}
