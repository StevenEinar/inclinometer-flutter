import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousAppBarTitle.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousBottomNavigationBar.dart';
import 'package:axis_inclinometer_monitor/services/DeviceService.dart';
import 'package:axis_inclinometer_monitor/objects/PeripheralDevice.dart';
import 'package:axis_inclinometer_monitor/objects/Device.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DevicesScreen extends StatefulWidget {

  final RouteSettings? routeSettings;

  DevicesScreen({Key? key, required this.routeSettings}) : super(key: key);

  @override
  _DevicesScreenState createState() {
    return _DevicesScreenState(payload: {'routeSettings': routeSettings});
  }

}

class _DevicesScreenState extends State<DevicesScreen> {

  Map? payload = {};

  _DevicesScreenState({required this.payload});

  static int selectedScreenIndex = 1;
  static int scanDuration = 3;
  static String broadcastName = 'Axis Inclinometer';
  static bool displayAllDevices = true;

  DeviceService deviceService = DeviceService();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<PeripheralDevice> peripheralDevices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    scanForDevices(duration: scanDuration);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UbiquitousAppBarTitle(subtitle: 'Scan for and view available compatible devices...'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: 32,
              ),
              onPressed: (isScanning)
                ? null
                : () {
                  scanForDevices(duration: scanDuration);
                }
            ),
          ),
        ]
      ),
      body: (isScanning)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator()),
              Center(child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Scanning...'),
              )),
            ],
        )
        : RefreshIndicator(
            onRefresh: () {
              scanForDevices(duration: scanDuration);
              return Future.delayed(Duration(milliseconds: 1));
            },
            child: ListView.builder(
              itemCount: peripheralDevices.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/Device', arguments: {
                          'peripheralDevice': peripheralDevices[index],
                        });
                      },
                      title: Text(peripheralDevices[index].localName),
                      subtitle: Row(
                        children: [
                          Text('${peripheralDevices[index].id} | ${peripheralDevices[index].getConnectability()}'),
                        ],
                      ),
                      leading: Icon(Icons.aod, size: 48),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (peripheralDevices[index].rssi < -65)
                          ? Icon(
                              Icons.signal_wifi_0_bar,
                              size: 24,
                            )
                          : Icon(
                              Icons.signal_wifi_4_bar,
                              size: 24,
                            ),
                          (peripheralDevices[index].rssi < -65)
                          ? Text(
                              '${peripheralDevices[index].rssi}',
                              style: TextStyle(
                                fontSize: 10.0,
                                  fontWeight: FontWeight.normal
                              )
                            )
                          : Text(
                              '${peripheralDevices[index].rssi}',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold
                              )
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ),
      bottomNavigationBar: UbiquitousBottomNavigationBar(selectedIndex: selectedScreenIndex),
    );
  }

  // TODO: Move this functionality to a service.
  void scanForDevices({required int duration}) async {
    await Future(() {
      setState(() {
        peripheralDevices.clear();
        isScanning = true;
      });
    });
    await Future.delayed(Duration(seconds: 1));
    // Start scanning
    flutterBlue.setLogLevel(LogLevel.emergency);
    Future bleScan = flutterBlue.startScan(timeout: Duration(seconds: duration));
    bleScan.then((value) {
      setState(() {
        isScanning = false;
      });
    });
    // Listen to scan results
    flutterBlue.scanResults.listen((scanResults) {
      for(ScanResult scanResult in scanResults) {
        PeripheralDevice peripheralDevice = PeripheralDevice(
          id: (scanResult.device.id != null) ? scanResult.device.id.toString() : '00:00:00:00:00:00',
          localName: (!(scanResult.device.name == '')) ? scanResult.device.name : 'Unknown BLE Device',
          rssi: scanResult.rssi,
          connectable: scanResult.advertisementData.connectable,
          txPowerLevel: scanResult.advertisementData.txPowerLevel,
          bluetoothDevice: scanResult.device,
        );
        if(displayAllDevices) {
          if(!peripheralDevices.any((element) => element.id == peripheralDevice.id)) {
            peripheralDevices.add(peripheralDevice);
          }
        } else {
          if(
            scanResult.advertisementData.connectable == true &&
            scanResult.device.name == broadcastName &&
            !peripheralDevices.any((element) => element.id == peripheralDevice.id)
          ) {
            peripheralDevices.add(peripheralDevice);
          }
        }
        
      }
    });
  }

}
