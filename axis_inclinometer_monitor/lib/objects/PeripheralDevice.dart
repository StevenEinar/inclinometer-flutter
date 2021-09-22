import 'package:flutter_blue/flutter_blue.dart';

class PeripheralDevice extends Object {

  final String id;
  final String localName;
  int rssi;
  final bool connectable;
  final int? txPowerLevel;
  final BluetoothDevice? bluetoothDevice;

  PeripheralDevice({
    required this.id,
    required this.localName,
    required this.rssi,
    required this.connectable,
    this.txPowerLevel,
    this.bluetoothDevice,
  });

  Map getProxy() {
    return {
      'id': this.id,
      'localName': this.localName,
      'rssi': this.rssi,
      'connectable': this.connectable,
      'txPowerLevel': this.txPowerLevel,
      'bluetoothDevice': this.bluetoothDevice,
    };
  }

  String getConnectability() {
    if (this.connectable) {
      return 'Avail.';
    } else
      return 'Unavail.';
  }

}