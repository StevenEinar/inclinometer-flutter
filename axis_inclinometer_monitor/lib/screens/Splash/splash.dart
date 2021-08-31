import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/enums/ErrorEnums.dart';

class SplashScreen extends StatefulWidget {

  final RouteSettings? routeSettings;

  SplashScreen({Key? key, required this.routeSettings}) : super(key: key);

  @override
  _SplashScreenState createState() {
    return _SplashScreenState(payload: {'routeSettings': routeSettings});
  }

}

class _SplashScreenState extends State<SplashScreen> {

  Map payload = {};

  _SplashScreenState({required this.payload});

  void _goHome() async {
    await Future.delayed(Duration(milliseconds: 2000), () {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/Favorites', arguments: {});
    });
  }

  @override
  void initState() {
    super.initState();
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: SizedBox(
          child: Image.asset('assets/images/witness.png'),
          width: 150.0,
        ),
      ),
    );
  }

}