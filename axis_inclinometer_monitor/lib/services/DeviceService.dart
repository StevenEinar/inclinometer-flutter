import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/objects/Device.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceService {

  DeviceService();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<Widget> _deviceList = [];
  List<Device> _devices = [];

  List<Widget> getDeviceList() {
    // TODO Get list of available BT devices
    scanForDevices();
    _deviceList.clear();
    _devices.clear();
    for(int counter=0; counter<5; counter++) {
      _devices.add(new Device(productName: 'Axis Inclinometer', uuid: '00:AA:F0:33:FF:9B', supportsBLE: true));
    }
    for(int counter=0; counter<_devices.length; counter++) {
      Device device = _devices[counter];
      _deviceList.add(
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
              border: Border.all(
                width: 1,
                color: Colors.black38,
              ),
              //color: Colors.teal,
            ),
            margin: EdgeInsets.fromLTRB(0, 10, 1, 10),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Icon(Icons.aod, size: 48),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.productName),
                    Text(device.uuid, style: TextStyle(fontSize: 11)),
                    Text('Supports BLE: ' + device.supportsBLE.toString(), style: TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            print('Tapped on $device.uuid');
          },
        ),
      );
    }
    return _deviceList;
  }

  void scanForDevices() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 15), allowDuplicates: false);
    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
    //subscription.cancel();
    // Stop scanning
    flutterBlue.stopScan();
  }

}