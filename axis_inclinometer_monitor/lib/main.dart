import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/routes/RouteGenerator.dart';

enum errorSeverity {
  INFO,
  WARNING,
  SEVERE,
}

void main() {
  runApp(AxisInclinometerMonitor());
}

class AxisInclinometerMonitor extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Axis Inclinometer Monitor',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/Splash',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }

}