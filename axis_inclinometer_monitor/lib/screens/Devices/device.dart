import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousAppBarTitle.dart';
import 'package:axis_inclinometer_monitor/services/DeviceService.dart';
import 'package:axis_inclinometer_monitor/objects/PeripheralDevice.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:location/location.dart';

class DeviceScreen extends StatefulWidget {

  final Map? payload;

  DeviceScreen({Key? key, required this.payload}) : super(key: key);

  @override
  _DeviceScreenState createState() {
    return _DeviceScreenState(payload: payload);
  }

}

class _DeviceScreenState extends State<DeviceScreen> {

  Map? payload = {};

  _DeviceScreenState({required this.payload});

  String serviceUUID = 'A337F33D-96B4-4FDD-86D1-1237AF8C59A9';

  Timer periodicLoggingTimer = Timer.periodic(Duration(days: 1), (Timer timer) {});
  Timer periodicReconnectTimer = Timer.periodic(Duration(days: 1), (Timer timer) {});

  Location locationService = Location();
  LocationData currentLocation = LocationData.fromMap({'lat': 0.0, 'long': 0.0});

  // TODO: Pull out methods into the DeviceService service.
  DeviceService deviceService = DeviceService();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isBluetoothAware = false;
  bool isBluetoothConnected = false;
  bool wasConnectedPrior = false;
  bool hasSeenBluetoothUnavailableAlert = false;
  PeripheralDevice? peripheralDevice;
  BluetoothService? peripheralService;
  BluetoothCharacteristic? peripheralPitchCharacteristic;
  BluetoothCharacteristic? peripheralRollCharacteristic;
  BluetoothCharacteristic? peripheralYawCharacteristic;
  BluetoothCharacteristic? peripheralResetCharacteristic;
  bool isConnecting = true;
  bool isLoadingPitchValue = true;
  bool isLoadingRollValue = true;
  bool isLoadingYawValue = true;
  bool isLoadingResetValue = true;
  int pitchValue = 0;
  int rollValue = 0;
  int yawValue = 0;
  int pitchRecordCount = 0;
  int rollRecordCount = 0;
  List<FlSpot> pitchSpots = [FlSpot(0.0, 0.0)];
  List<FlSpot> rollSpots = [FlSpot(0.0, 0.0)];
  List<FlSpot> yawSpots = [FlSpot(0.0, 0.0)];
  bool doPrecache = true;
  Image pitchMeterImage = Image.asset(
    'assets/images/pitch_meter.png',
    width: 150,
    height: 150,
  );
  Image rollMeterImage = Image.asset(
    'assets/images/roll_meter.png',
    width: 150,
    height: 150,
  );
  List<Image> positivePitchMeterImages = [
    Image.asset(
      'assets/images/pitch_meter_bar+8.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+7.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+6.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+5.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+4.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+3.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+2.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar+1.png',
      width: 150,
      height: 150,
    )
  ];
  List<Image> negativePitchMeterImages = [
    Image.asset(
      'assets/images/pitch_meter_bar-1.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-2.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-3.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-4.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-5.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-6.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-7.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/pitch_meter_bar-8.png',
      width: 150,
      height: 150,
    )
  ];
  List<Image> positiveRollMeterImages = [
    Image.asset(
      'assets/images/roll_meter_bar+8.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+7.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+6.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+5.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+4.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+3.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+2.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar+1.png',
      width: 150,
      height: 150,
    )
  ];
  List<Image> negativeRollMeterImages = [
    Image.asset(
      'assets/images/roll_meter_bar-1.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-2.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-3.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-4.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-5.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-6.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-7.png',
      width: 150,
      height: 150,
    ),
    Image.asset(
      'assets/images/roll_meter_bar-8.png',
      width: 150,
      height: 150,
    )
  ];

  @override
  void initState() {
    peripheralDevice = payload!['peripheralDevice'];
    bootstrapBluetooth();
    bootstrapLocationAwareness();
    bootstrapPeriodicLoggingActions();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(doPrecache) {
      positivePitchMeterImages.forEach((positivePitchMeterImage) {
        precacheImage(positivePitchMeterImage.image, context);
      });
      negativePitchMeterImages.forEach((negativePitchMeterImage) {
        precacheImage(negativePitchMeterImage.image, context);
      });
      positiveRollMeterImages.forEach((positiveRollMeterImage) {
        precacheImage(positiveRollMeterImage.image, context);
      });
      negativeRollMeterImages.forEach((negativeRollMeterImage) {
        precacheImage(negativeRollMeterImage.image, context);
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cleanUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: navigateBack,
      child: Scaffold(
        appBar: AppBar(
          elevation: 20,
          bottomOpacity: 0.1,
          title: UbiquitousAppBarTitle(isTopLevel: false, title: peripheralDevice?.localName ?? 'N/A', subtitle: peripheralDevice?.id ?? 'N/A'),
          backgroundColor: Colors.teal[90],
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rssi Column
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      child: Image.asset('assets/images/ble.png'),
                                      width: 76.0,
                                    ),
                                  ),
                                  (peripheralDevice!.rssi < -65)
                                      ? Icon(
                                    Icons.signal_wifi_0_bar,
                                    size: 24,
                                  )
                                      : Icon(
                                    Icons.signal_wifi_4_bar,
                                    size: 24,
                                  ),
                                  (peripheralDevice!.rssi < -65)
                                      ? Text(
                                      '${peripheralDevice!.rssi}',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.normal
                                      )
                                  )
                                      : Text(
                                      '${peripheralDevice!.rssi}',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Localname Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          peripheralDevice?.localName ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // ID Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 20.0),
                                            child: Text(
                                              peripheralDevice?.id ?? 'N/A',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.teal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Status Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            'Status: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: (isBluetoothAware)
                                            ? (isConnecting)
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        'Connecting...',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.orange
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(left: 10),
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.orange,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    'Connected',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.green
                                                    ),
                                                  )
                                            : Text(
                                                'Disconnected',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                )
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Divider Row
                          Visibility(
                            visible: !isConnecting,
                            child: Divider(
                              height: 50,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                            ),
                          ),
                          // Gauges Row
                          Visibility(
                            visible: !isConnecting,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Pitch: ',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal
                                          ),
                                        ),
                                        Text(
                                          ' ${pitchValue}',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                    pitchMeterImage,
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Roll: ',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal
                                          ),
                                        ),
                                        Text(
                                          ' ${rollValue}',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                    rollMeterImage,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Diver Row
                          Visibility(
                            visible: !isConnecting,
                            child: Divider(
                              height: 50,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                            ),
                          ),
                          // Charts Row
                          Visibility(
                            visible: !isConnecting,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    'Pitch / Time: ',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 350,
                                  height: 70,
                                  child: LineChart(
                                    LineChartData(
                                      titlesData: FlTitlesData(show: false),
                                        borderData: FlBorderData(show: false),
                                        gridData: FlGridData(show: false),
                                        extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 0, color: Colors.black12, strokeWidth: 1)]),
                                        minX: pitchSpots.first.x,
                                        maxX: pitchSpots.last.x,
                                        minY: -75,
                                        maxY: 75,
                                        lineBarsData: [
                                          LineChartBarData(
                                            barWidth: 1.0,
                                            dotData: FlDotData(show: false),
                                            spots: pitchSpots      ,
                                          ),
                                        ]
                                    ),
                                    swapAnimationDuration: Duration(milliseconds: 150), // Optional
                                    swapAnimationCurve: Curves.linear, // Optional
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    'Roll / Time: ',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 350,
                                  height: 70,
                                  child: LineChart(
                                    LineChartData(
                                        titlesData: FlTitlesData(show: false),
                                        borderData: FlBorderData(show: false),
                                        gridData: FlGridData(show: false),
                                        extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 0, color: Colors.black12, strokeWidth: 1)]),
                                        minX: pitchSpots.first.x,
                                        maxX: pitchSpots.last.x,
                                        minY: -60,
                                        maxY: 60,
                                        lineBarsData: [
                                          LineChartBarData(
                                            barWidth: 1.0,
                                            dotData: FlDotData(show: false),
                                            spots: rollSpots,
                                          ),
                                        ]
                                    ),
                                    swapAnimationDuration: Duration(milliseconds: 150), // Optional
                                    swapAnimationCurve: Curves.linear, // Optional
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* Logic */

  // TODO: Move this functionality to a service.
  Future<void> bootstrapBluetooth() async {
    print('Entered \'bootstrapBluetooth\' function ++++++++++++++++++++++++++++++++++++++++++++++++++++');
    await Future(() {
      setState(() {
        isConnecting = true;
        isBluetoothAware = true;
        isBluetoothConnected = false;
        periodicReconnectTimer.cancel();
      });
    });
    bool isBluetoothAvailable = await flutterBlue.isAvailable;
    bool isBluetoothOn = await flutterBlue.isOn;
    if(isBluetoothAvailable && isBluetoothOn) {
      setState(() {
        isBluetoothAware = true;
      });
      connectToDevice(bluetoothDevice: peripheralDevice!.bluetoothDevice!);
    } else {
      setState(() {
        isBluetoothAware = false;
      });
      // TODO: Handle no bluetooth situation.
      if(!hasSeenBluetoothUnavailableAlert) {
        setState(() {
          hasSeenBluetoothUnavailableAlert = true;
        });
        showBluetoothUnavailable();
      }
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    }
  }

  // TODO: Move this functionality to a service.
  Future<void> connectToDevice({required BluetoothDevice bluetoothDevice}) async {
    print('Entered \'connectToDevice\' function ++++++++++++++++++++++++++++++++++++++++++++++++++++');
    await bluetoothDevice.connect().then((value) {
      print('Successful connection to bluetooth device !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothConnected = true;
      });
      peripheralDevice?.bluetoothDevice?.state.listen((event) async {
        print('Bluetooth state event = ${event} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2@');
        if(event == BluetoothDeviceState.disconnecting || event == BluetoothDeviceState.disconnected) {
          periodicLoggingTimer.cancel();
          setState(() {
            wasConnectedPrior = true;
            isBluetoothAware = false;
            isBluetoothConnected = false;
            isConnecting = true;
            /*isLoadingPitchValue = true;
            isLoadingRollValue = true;
            isLoadingYawValue = true;
            isLoadingResetValue = true;
            peripheralService = null;
            peripheralPitchCharacteristic = null;
            peripheralRollCharacteristic = null;
            peripheralYawCharacteristic = null;
            peripheralResetCharacteristic = null;*/
          });
        } else if(event == BluetoothDeviceState.connecting || event == BluetoothDeviceState.connected) {
          bootstrapPeriodicLoggingActions();
          discoverServices(bluetoothDevice: bluetoothDevice);
        }
      });
      return value;
    }).onError((error, stackTrace) {
      print('Failed connection to bluetooth device !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      // TODO: Handle error condition
    }).timeout(Duration(seconds: 5), onTimeout: () {
      print('Connection to bluetooth device timed out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    });
  }

  // TODO: Move this functionality to a service.
  Future<void> discoverServices({required BluetoothDevice bluetoothDevice}) async {
    print('Entered \'discoverServices\' function ++++++++++++++++++++++++++++++++++++++++++++++++++++');
    List<BluetoothService> bluetoothServices = await bluetoothDevice.discoverServices().then((value) {
      print('Successful service discovery !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      return value;
    }).onError((error, stackTrace) {
      print('Failed services discovery !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      return List.empty();
      // TODO: Handle error condition
    }).timeout(Duration(seconds: 5), onTimeout: () {
      print('Services discovery timed out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      return List.empty();
    });
    if(bluetoothServices.isNotEmpty) {
      print('Found characteristics !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      bluetoothServices.forEach((bluetoothService) {
        if(bluetoothService.uuid.toString().toUpperCase() == serviceUUID.toUpperCase()) {
          peripheralService = bluetoothService;
          for(BluetoothCharacteristic blueToothCharacteristic in peripheralService!.characteristics) {
            print('${blueToothCharacteristic.uuid.toString().toUpperCase()} !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            switch(blueToothCharacteristic.uuid.toString().toUpperCase()) {
              case 'C4F3FDAF-EAB5-42DE-8F17-2C84503F4AF0':
                setState(() {
                  peripheralPitchCharacteristic = blueToothCharacteristic;
                });
                break;
              case 'A8425BD8-0271-47BB-BF52-63F950AC9E3F':
                setState(() {
                  peripheralRollCharacteristic = blueToothCharacteristic;
                });
                break;
              case '4FAF0DFA-CDCA-4826-8091-88F53ACC1763':
                setState(() {
                  peripheralYawCharacteristic = blueToothCharacteristic;
                });
                break;
              case 'FC98DA0E-EEDB-4814-9215-0C05E3FB5389':
                setState(() {
                  peripheralResetCharacteristic = blueToothCharacteristic;
                });
                break;
            }
          }
        }
      });
      subscribeToCharacteristics();
    } else {
      print('Did not find characteristics !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      // TODO: Handle no characteristics
    }
  }

  Future<void> subscribeToCharacteristics() async {
    print('Entered \'subscribeToCharacteristics\' function ++++++++++++++++++++++++++++++++++++++++++++++++++++');
    await peripheralPitchCharacteristic!.setNotifyValue(true).then((value) {
      print('Successful pitch characteristic subscription !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isLoadingPitchValue = false;
      });
      peripheralPitchCharacteristic!.value.listen((newValuesList) async {
        print('Received list of pitch values ++++++++++++++++++++++++++++++++++++++++++++++++++++');
        if(newValuesList.isNotEmpty) {
          await Future(() {
            if(this.mounted) {
              setState(() {
                isLoadingPitchValue = false;
                pitchRecordCount++;
                Int8List intList = Int8List.fromList(newValuesList);
                pitchValue = ByteData.sublistView(intList).getInt32(0, Endian.little);
                pitchSpots.add(FlSpot(pitchRecordCount.toDouble(), pitchValue.toDouble()));
                if (pitchSpots.length > 90) {
                  pitchSpots.removeAt(0);
                }
                if (pitchValue == 0) {
                  pitchMeterImage = Image.asset(
                    'assets/images/pitch_meter.png',
                    width: 150,
                    height: 150,
                  );
                } else if (pitchValue > 0 && pitchValue < 7) {
                  pitchMeterImage = positivePitchMeterImages[7];
                } else if (pitchValue >= 7 && pitchValue < 15) {
                  pitchMeterImage = positivePitchMeterImages[6];
                } else if (pitchValue >= 15 && pitchValue < 23) {
                  pitchMeterImage = positivePitchMeterImages[5];
                } else if (pitchValue >= 23 && pitchValue < 33) {
                  pitchMeterImage = positivePitchMeterImages[4];
                } else if (pitchValue >= 33 && pitchValue < 43) {
                  pitchMeterImage = positivePitchMeterImages[3];
                } else if (pitchValue >= 43 && pitchValue < 50) {
                  pitchMeterImage = positivePitchMeterImages[2];
                } else if (pitchValue >= 50 && pitchValue < 60) {
                  pitchMeterImage = positivePitchMeterImages[1];
                } else if (pitchValue >= 60) {
                  pitchMeterImage = positivePitchMeterImages[0];
                } else if (pitchValue < 0 && pitchValue > -7) {
                  pitchMeterImage = negativePitchMeterImages[0];
                } else if (pitchValue < -7 && pitchValue > -15) {
                  pitchMeterImage = negativePitchMeterImages[1];
                } else if (pitchValue < -15 && pitchValue > -23) {
                  pitchMeterImage = negativePitchMeterImages[2];
                } else if (pitchValue < -23 && pitchValue > -33) {
                  pitchMeterImage = negativePitchMeterImages[3];
                } else if (pitchValue < -33 && pitchValue > -43) {
                  pitchMeterImage = negativePitchMeterImages[4];
                } else if (pitchValue < -43 && pitchValue > -50) {
                  pitchMeterImage = negativePitchMeterImages[5];
                } else if (pitchValue < -50 && pitchValue > -60) {
                  pitchMeterImage = negativePitchMeterImages[6];
                } else if (pitchValue < -60) {
                  pitchMeterImage = negativePitchMeterImages[7];
                } else {
                  pitchMeterImage = Image.asset(
                    'assets/images/pitch_meter.png',
                    width: 150,
                    height: 150,
                  );
                }
              });
            }
          });
        }
      });
    }).onError((error, stackTrace) {
      print('Failed pitch characteristic subscription !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      // TODO: Handle error condition
    }).timeout(Duration(seconds: 5), onTimeout: () {
      print('Pitch characteristic subscription timed out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    });
    await peripheralRollCharacteristic!.setNotifyValue(true).then((value) {
      print('Successful roll characteristic subscription !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isLoadingRollValue = false;
      });
      peripheralRollCharacteristic!.value.listen((newValuesList) async {
        print('Received list of roll values ++++++++++++++++++++++++++++++++++++++++++++++++++++');
        if(newValuesList.isNotEmpty) {
          await Future(() {
            if(this.mounted) {
              setState(() {
                isLoadingRollValue = false;
                rollRecordCount++;
                Int8List intList = Int8List.fromList(newValuesList);
                rollValue = ByteData.sublistView(intList).getInt32(0, Endian.little);
                rollSpots.add(FlSpot(rollRecordCount.toDouble(), rollValue.toDouble()));
                if (rollSpots.length > 90) {
                  rollSpots.removeAt(0);
                }
                if (rollValue == 0) {
                  rollMeterImage = Image.asset(
                    'assets/images/roll_meter.png',
                    width: 150,
                    height: 150,
                  );
                } else if (rollValue > 0 && rollValue < 5) {
                  rollMeterImage = positiveRollMeterImages[7];
                } else if (rollValue >= 5 && rollValue < 11) {
                  rollMeterImage = positiveRollMeterImages[6];
                } else if (rollValue >= 11 && rollValue < 18) {
                  rollMeterImage = positiveRollMeterImages[5];
                } else if (rollValue >= 18 && rollValue < 26) {
                  rollMeterImage = positiveRollMeterImages[4];
                } else if (rollValue >= 26 && rollValue < 34) {
                  rollMeterImage = positiveRollMeterImages[3];
                } else if (rollValue >= 34 && rollValue < 40) {
                  rollMeterImage = positiveRollMeterImages[2];
                } else if (rollValue >= 40 && rollValue < 45) {
                  rollMeterImage = positiveRollMeterImages[1];
                } else if (rollValue >= 45) {
                  rollMeterImage = positiveRollMeterImages[0];
                } else if (rollValue < 0 && rollValue > -5) {
                  rollMeterImage = negativeRollMeterImages[0];
                } else if (rollValue < -5 && rollValue > -11) {
                  rollMeterImage = negativeRollMeterImages[1];
                } else if (rollValue < -11 && rollValue > -18) {
                  rollMeterImage = negativeRollMeterImages[2];
                } else if (rollValue < -18 && rollValue > -26) {
                  rollMeterImage = negativeRollMeterImages[3];
                } else if (rollValue < -26 && rollValue > -34) {
                  rollMeterImage = negativeRollMeterImages[4];
                } else if (rollValue < -34 && rollValue > -40) {
                  rollMeterImage = negativeRollMeterImages[5];
                } else if (rollValue < -40 && rollValue > -45) {
                  rollMeterImage = negativeRollMeterImages[6];
                } else if (rollValue < -45) {
                  rollMeterImage = negativeRollMeterImages[7];
                } else {
                  rollMeterImage = Image.asset(
                    'assets/images/roll_meter.png',
                    width: 150,
                    height: 150,
                  );
                }
              });
            }
          });
        }
      });
    }).onError((error, stackTrace) {
      print('Failed roll characteristic subscription !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      // TODO: Handle error condition
    }).timeout(Duration(seconds: 5), onTimeout: () {
      print('Roll characteristic subscription timed out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    });
    await peripheralYawCharacteristic!.setNotifyValue(true).then((value) {
      print('Successful yaw characteristic subscription !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isLoadingYawValue = false;
      });
      peripheralYawCharacteristic!.value.listen((newValuesList) async {
        print('Received list of yaw values ++++++++++++++++++++++++++++++++++++++++++++++++++++');
        if(newValuesList.isNotEmpty) {
          await Future(() {
            if(this.mounted) {
              setState(() {
                isLoadingYawValue = false;
              });
            }
          });
        }
      });
    }).onError((error, stackTrace) {
      print('Failed yaw characteristic subscription !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
      // TODO: Handle error condition
    }).timeout(Duration(seconds: 5), onTimeout: () {
      print('Yaw characteristic subscription timed out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    });
    print('Is pitch loading? ${isLoadingPitchValue}');
    print('Is roll loading? ${isLoadingRollValue}');
    print('Is yaw loading? ${isLoadingYawValue}');
    if(!isLoadingPitchValue && !isLoadingRollValue && !isLoadingYawValue) {
      revealUI();
    } else {
      print('Still not ready !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      setState(() {
        isBluetoothAware = false;
        isBluetoothConnected = false;
      });
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    }
    revealUI();
  }

  void revealUI() {
    isBluetoothAware = true;
    isBluetoothConnected = true;
    isConnecting = false;
  }

  Future<void> bootstrapLocationAwareness() async {
    currentLocation = await locationService.getLocation();
    locationService.onLocationChanged.listen((LocationData newLocation) {
      currentLocation = newLocation;
    });
  }

  // TODO: Log data to storage.
  void bootstrapPeriodicLoggingActions() {
    periodicLoggingTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if(!isConnecting && isBluetoothAware && isBluetoothConnected) {
        Map logEntry = {
          'pitch': pitchValue,
          'roll': rollValue,
          'yaw': yawValue,
          'lat': currentLocation.latitude,
          'long': currentLocation.longitude,
          'altitude': currentLocation.altitude,
          'speed': currentLocation.speed,
          'heading': currentLocation.heading,
          'time': currentLocation.time,
        };
        print(logEntry);
      }
    });
  }

  // TODO: Log data to storage.
  void bootstrapPeriodicReconnectActions() {
    periodicReconnectTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      Timer(Duration(seconds: 3), () {
        bootstrapBluetooth();
      });
    });
  }

  Future<void> showBluetoothUnavailable() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth LE Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This app requires Bluetooth LE services to be available and to be turned on.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go To Settings'),
              onPressed: () {
                Navigator.pop(context, 'Go To Settings');
                AppSettings.openBluetoothSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showBluetoothConnectionError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth LE Connection Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This app is unable to connect successfully to the desired device. Check that the remote device is turned on and is available.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context, 'Ok');
                AppSettings.openBluetoothSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> cleanUp() async {
    await peripheralPitchCharacteristic?.setNotifyValue(false);
    await peripheralRollCharacteristic?.setNotifyValue(false);
    await peripheralYawCharacteristic?.setNotifyValue(false);
    await peripheralResetCharacteristic?.setNotifyValue(false);
    peripheralDevice?.bluetoothDevice?.disconnect();
    locationService = Location();
    periodicLoggingTimer.cancel();
  }

  Future<bool> navigateBack() {
    Navigator.pop(context, '/Devices');
    return Future.value(true);
  }

}
