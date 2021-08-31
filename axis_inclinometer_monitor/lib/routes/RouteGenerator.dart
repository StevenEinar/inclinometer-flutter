import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/enums/ErrorEnums.dart';
import 'package:axis_inclinometer_monitor/screens/Splash/splash.dart';
import 'package:axis_inclinometer_monitor/screens/Favorites/favorites.dart';
import 'package:axis_inclinometer_monitor/screens/Devices/devices.dart';
import 'package:axis_inclinometer_monitor/screens/Devices/device.dart';
import 'package:axis_inclinometer_monitor/screens/History/history.dart';
import 'package:axis_inclinometer_monitor/screens/Settings/settings.dart';
import 'package:axis_inclinometer_monitor/screens/Errors/error.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/Splash':
        return safeNamedRoute(settings.name, SplashScreen(routeSettings: settings));
      case '/':
        return safeNamedRoute(settings.name, FavoritesScreen(routeSettings: settings));
      case '/Favorites':
        return safeNamedRoute(settings.name, FavoritesScreen(routeSettings: settings));
      case '/Devices':
        return safeNamedRoute(settings.name, DevicesScreen(routeSettings: settings));
      case '/Device':
        return safeNamedRoute(settings.name, DeviceScreen(payload: (settings.arguments != null) ? settings.arguments as Map : {}));
      case '/History':
        return safeNamedRoute(settings.name, HistoryScreen(routeSettings: settings));
      case '/Settings':
        return safeNamedRoute(settings.name, SettingsScreen(routeSettings: settings));
      default:
        return safeNamedRoute(0, ErrorScreen(routeSettings: settings, seed: ErrorCode.ExRG01.ext));
    }
  }

  // Provide a simple, unauthorized material page route
  static MaterialPageRoute safeNamedRoute(namedRoute, route) {
    if(namedRoute is String) {
      return MaterialPageRoute(
          builder: (context) {
            return route;
          }
      );
    } else {
      return MaterialPageRoute(
          builder: (context) {
            return ErrorScreen(routeSettings: route.routeSettings, seed: ErrorCode.ExRG02.ext);
          }
      );
    }
  }

  // Provide a simple, authorized material page route
  // TODO: Finish the authentication/authorization mechanisms
  static MaterialPageRoute secureNamedRoute(namedRoute, route) {
    if(namedRoute is String) {
      return MaterialPageRoute(
          builder: (context) {
            return route;
          }
      );
    } else {
      return MaterialPageRoute(
          builder: (context) {
            return ErrorScreen(routeSettings: route.routeSettings, seed: ErrorCode.ExRG03.ext);
          }
      );
    }
  }

}