import 'package:flutter/material.dart';

class UbiquitousBottomNavigationBar extends StatelessWidget {

  final int selectedIndex;

  UbiquitousBottomNavigationBar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: this.selectedIndex,
      fixedColor: Colors.teal,
      backgroundColor: Colors.white70,
      elevation: 9.0,
      iconSize: 24.0,
      selectedFontSize: 16.0,
      unselectedFontSize: 12.0,
      items: [
        BottomNavigationBarItem(
          label: "Favorites",
          icon: Icon(Icons.favorite),
        ),
        BottomNavigationBarItem(
          label: "Find",
          icon: Icon(Icons.devices),
        ),
        BottomNavigationBarItem(
          label: "History",
          icon: Icon(Icons.history),
        ),
        BottomNavigationBarItem(
          label: "Settings",
          icon: Icon(Icons.settings),
        ),
      ],
      onTap: (int index) {
        switch (index) {
          case 0:
            print('Going to Favorites');
            Navigator.popAndPushNamed(context, '/Favorites');
            break;
          case 1:
            print('Going to Find');
            Navigator.popAndPushNamed(context, '/Devices');
            break;
          case 2:
            print('Going to History');
            Navigator.popAndPushNamed(context, '/History');
            break;
          case 3:
            print('Going to Settings');
            Navigator.popAndPushNamed(context, '/Settings');
            break;
          default:
            print('Going to Initial');
            Navigator.popAndPushNamed(context, '/');
            break;
        }
      },
    );
  }

}