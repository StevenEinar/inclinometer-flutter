import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:axis_inclinometer_monitor/fragments/UbiquitousAppBarTitle.dart';
import 'package:axis_inclinometer_monitor/services/DeviceService.dart';
import 'package:axis_inclinometer_monitor/objects/PeripheralDevice.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:byte_util/byte_util.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as PathProvider;
import 'package:path/path.dart' as Path;

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

  Timer periodicLoggingTimer = Timer.periodic(Duration(days: 999), (Timer timer) {});
  Timer periodicChartingTimer = Timer.periodic(Duration(days: 999), (Timer timer) {});
  Timer periodicReconnectTimer = Timer.periodic(Duration(days: 999), (Timer timer) {});

  Location locationService = Location();
  LocationData currentLocation = LocationData.fromMap({'lat': 0.0, 'long': 0.0});

  // TODO: Pull out methods into the DeviceService service.
  DeviceService deviceService = DeviceService();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isBluetoothOn = true;
  bool isConnected = false;
  bool isOperational = false;
  PeripheralDevice? peripheralDevice;
  BluetoothService? peripheralService;
  BluetoothCharacteristic? peripheralPitchCharacteristic;
  BluetoothCharacteristic? peripheralRollCharacteristic;
  BluetoothCharacteristic? peripheralYawCharacteristic;
  BluetoothCharacteristic? peripheralRssiCharacteristic;
  BluetoothCharacteristic? peripheralResetCharacteristic;

  Directory? storageDirectory = Directory('');
  File logFile = File('');

  bool isResetStatsProcessing = false;

  int rssiLevel = 0;

  int pitchValue = 0;
  int maxPitchValue = 0;
  int minPitchValue = 0;
  int rollValue = 0;
  int maxRollValue = 0;
  int minRollValue = 0;
  int yawValue = 0;
  int maxYawValue = 0;
  int minYawValue = 0;
  int pitchRecordCount = 0;
  int rollRecordCount = 0;
  int yawRecordCount = 0;

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
    flutterBlue.setLogLevel(LogLevel.info);
    bootstrapIO();
    bootstrapOperations();
    bootstrapLocationAwareness();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (doPrecache) {
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
                                      child: (isConnected)
                                        ? Image.asset('assets/images/ble_color.png')
                                        : Image.asset('assets/images/ble_color.png'),
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
                                      '${rssiLevel}~',
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
                                          child: StreamBuilder<BluetoothDeviceState>(
                                            stream: peripheralDevice?.bluetoothDevice?.state,
                                            initialData: BluetoothDeviceState.disconnected,
                                            builder: (BuildContext context, AsyncSnapshot<BluetoothDeviceState> snapshot) {
                                              if (!snapshot.hasData) {
                                                return CircularProgressIndicator();
                                              } else {
                                                switch(snapshot.data) {
                                                  case BluetoothDeviceState.connected:
                                                    return Text(
                                                      'Connected',
                                                      style: TextStyle(
                                                        color: Colors.lightGreen,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  case BluetoothDeviceState.disconnected:
                                                    return Row(
                                                      children: [
                                                        Text(
                                                          'Searching... ',
                                                          style: TextStyle(
                                                            color: Colors.deepOrange,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Container(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 1,
                                                            color: Colors.deepOrange,
                                                          ),
                                                          margin: EdgeInsets.only(left: 5),
                                                          width: 20,height: 20,
                                                        ),
                                                      ],
                                                    );
                                                  default:
                                                    return Text(
                                                      'N/A',
                                                      style: TextStyle(
                                                        color: Colors.indigo,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                }
                                              }
                                            },
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Gauges Row
                          Visibility(
                            visible: isOperational,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(2, 25, 2, 5),
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
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
                          ),
                          // Diver Row
                          // Charts Row
                          Visibility(
                            visible: isOperational,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(2, 5, 2, 5),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                      'Pitch / Time: ',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      'Max: ${maxPitchValue}  |  Min: ${minPitchValue}',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.normal
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
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isOperational,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(2, 5, 2, 5),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                      'Roll / Time: ',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      'Max: ${maxRollValue}  |  Min: ${minRollValue}',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.normal
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
        floatingActionButton: Visibility(
          visible: isOperational,
          child: FloatingActionButton(
            onPressed: () {
              print('onPressed() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
              resetStats(true);
            },
            child: const Icon(Icons.reset_tv),
            backgroundColor: Colors.teal,
          ),
        ),
      ),
    );
  }

  /* Logic */
  /* ************************************************************************************************************************************************** */
  // TODO: Move this functionality to a service.

  Future<void> bootstrapIO() async {
    storageDirectory = await PathProvider.getExternalStorageDirectory();
  }
  
  Future<void> bootstrapOperations() async {
    engagePeriodicReconnectActions(false);
    engagePeriodicChartingActions(false);
    engagePeriodicLoggingActions(false);
    isOperational = false;
    setState(() {});
    BluetoothDevice bluetoothDevice = peripheralDevice!.bluetoothDevice!;
    if (await flutterBlue.isAvailable && await flutterBlue.isOn) {
      isBluetoothOn = true;
      bluetoothDevice.connect(autoConnect: false);
      bluetoothDevice.state.listen((bluetoothDeviceStateChange) async {
        switch (bluetoothDeviceStateChange) {
          // Connecting State
          case BluetoothDeviceState.connecting:
          // DEFER: This is never called although the API recommends having this case.
            break;
          // Connected State
          case BluetoothDeviceState.connected:
            if (!isConnected) {
              isConnected = true;
              List<BluetoothService> bluetoothServices = await bluetoothDevice.discoverServices();
              bluetoothServices.forEach((bluetoothService) async {
                if (bluetoothService.uuid.toString().toUpperCase() == serviceUUID.toUpperCase()) {
                  peripheralService = bluetoothService;
                  await Future.forEach(bluetoothService.characteristics, (BluetoothCharacteristic bluetoothCharacteristic) async {
                    switch (bluetoothCharacteristic.uuid.toString().toUpperCase()) {
                      case 'C4F3FDAF-EAB5-42DE-8F17-2C84503F4AF0':
                        peripheralPitchCharacteristic = bluetoothCharacteristic;
                        await bluetoothCharacteristic.setNotifyValue(true).then((setNotifyResult) {
                          bluetoothCharacteristic.value.listen((newValuesList) {
                            if (newValuesList.isNotEmpty) {
                              pitchValue = ByteData.sublistView(Int8List.fromList(newValuesList)).getInt32(0, Endian.little);
                              if(pitchValue > maxPitchValue) {
                                maxPitchValue = pitchValue;
                              }
                              if(pitchValue < minPitchValue) {
                                minPitchValue = pitchValue;
                              }
                            }
                          });
                        });
                        break;
                      case 'A8425BD8-0271-47BB-BF52-63F950AC9E3F':
                        peripheralRollCharacteristic = bluetoothCharacteristic;
                        await bluetoothCharacteristic.setNotifyValue(true).then((setNotifyResult) {
                          bluetoothCharacteristic.value.listen((newValuesList) {
                            if (newValuesList.isNotEmpty) {
                              rollValue = ByteData.sublistView(Int8List.fromList(newValuesList)).getInt32(0, Endian.little);
                              if(rollValue > maxRollValue) {
                                maxRollValue = rollValue;
                              }
                              if(rollValue < minRollValue) {
                                minRollValue = rollValue;
                              }
                            }
                          });
                        });
                        break;
                      case '4FAF0DFA-CDCA-4826-8091-88F53ACC1763':
                        peripheralYawCharacteristic = bluetoothCharacteristic;
                        await bluetoothCharacteristic.setNotifyValue(true).then((setNotifyResult) {
                          bluetoothCharacteristic.value.listen((newValuesList) {
                            if (newValuesList.isNotEmpty) {
                              yawValue = ByteData.sublistView(Int8List.fromList(newValuesList)).getInt32(0, Endian.little);
                              if(yawValue > maxYawValue) {
                                maxYawValue = yawValue;
                              }
                              if(yawValue < minYawValue) {
                                minYawValue = yawValue;
                              }
                            }
                          });
                        });
                        break;
                      case '7B8F7EBC-DA64-4105-9EBA-04526091DAD6':
                        peripheralRssiCharacteristic = bluetoothCharacteristic;
                        await bluetoothCharacteristic.setNotifyValue(true).then((setNotifyResult) {
                          bluetoothCharacteristic.value.listen((newValuesList) {
                            if (newValuesList.isNotEmpty) {
                              rssiLevel = ByteData.sublistView(Int8List.fromList(newValuesList)).getInt32(0, Endian.little);
                            }
                          });
                        });
                        break;
                      case 'FC98DA0E-EEDB-4814-9215-0C05E3FB5389':
                        peripheralResetCharacteristic = bluetoothCharacteristic;
                        bluetoothCharacteristic.setNotifyValue(true);
                        bluetoothCharacteristic.value.listen((newValuesList) {
                          if (newValuesList.isNotEmpty) {
                            int resetValue = ByteData.sublistView(Int8List.fromList(newValuesList)).getInt32(0, Endian.little);
                            if (resetValue == 1) {
                              resetStats(false);
                            }
                          }
                        });
                        break;
                    }
                  });
                }
              });
              isConnected = true;
              isOperational = true;
              engagePeriodicReconnectActions(false);
              engagePeriodicChartingActions(true);
              engagePeriodicLoggingActions(true);
            } else {

            }
            break;
          // Disconnecting State
          case BluetoothDeviceState.disconnecting:
            // DEFER: This is never called although the API recommends having this case.
            break;
          // Disconnected State
          case BluetoothDeviceState.disconnected:
            if (isConnected) {
              isConnected = false;
              isOperational = false;
              engagePeriodicReconnectActions(true);
              engagePeriodicChartingActions(false);
              engagePeriodicLoggingActions(false);
            }
            break;
        }
        if (mounted) {
          setState(() {});
        }
      }, cancelOnError: false);
    } else {
      print('~~~~~~~ Bluetooth is NOT available ~~~~~~~');
      isBluetoothOn = false;
      engagePeriodicReconnectActions(true);
    }
  }

  Future<void> bootstrapLocationAwareness() async {
    currentLocation = await locationService.getLocation();
    locationService.onLocationChanged.listen((LocationData newLocation) {
      currentLocation = newLocation;
    });
  }

  void engagePeriodicReconnectActions(bool engage) {
    if (engage && !periodicReconnectTimer.isActive) {
      periodicReconnectTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
        bootstrapOperations();
      });
    } else {
      periodicReconnectTimer.cancel();
    }
  }

  void engagePeriodicChartingActions(bool engage) {
    if (engage && !periodicChartingTimer.isActive) {
      periodicChartingTimer = Timer.periodic(Duration(milliseconds: 250), (Timer timer) {
        pitchRecordCount++;
        pitchSpots.add(FlSpot(pitchRecordCount.toDouble(), pitchValue.toDouble()));
        if (pitchSpots.length > 90) {
          pitchSpots.removeAt(0);
        }
        updatePitchGauge();
        rollRecordCount++;
        rollSpots.add(FlSpot(rollRecordCount.toDouble(), rollValue.toDouble()));
        if (rollSpots.length > 90) {
          rollSpots.removeAt(0);
        }
        updateRollGauge();
        yawRecordCount++;
        yawSpots.add(FlSpot(yawRecordCount.toDouble(), yawValue.toDouble()));
        if (yawSpots.length > 90) {
          yawSpots.removeAt(0);
        }
        updateYawGauge();
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      periodicChartingTimer.cancel();
    }
  }

  // TODO: Log data to storage.
  void engagePeriodicLoggingActions(bool engage) {
    if (engage) {
      DateTime now = DateTime.now();
      Directory logsDirectory = Directory('${storageDirectory!.path}/logs');
      print(storageDirectory);
      print(logsDirectory);
      print(logsDirectory.existsSync());
      logsDirectory.createSync(recursive: true);
      print(logsDirectory.existsSync());
      logFile = File('${logsDirectory.path}/${now.year}-${now.month}-${now.day}_${now.hour}:${now.minute}:${now.second}.log');
      print(logFile.existsSync());
      if(!logFile.existsSync()) {
        logFile.writeAsStringSync('[\n', flush: true);
      }
      periodicLoggingTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
        if (isOperational) {
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
            'rssi': rssiLevel,
          };
          String log = '${logEntry.toString()}\n';
          if (timer.isActive && log.length > 7) {
            await logFile.writeAsString(log, mode: FileMode.append, flush: true);
          }
        }
      });
    } else {
      if (periodicLoggingTimer.isActive && logFile.existsSync()) {
        periodicLoggingTimer.cancel();
        logFile.writeAsStringSync(']', mode: FileMode.append, flush: true);
      }
    }
  }

  Future<void> resetStats(bool write) async {
    if (!isResetStatsProcessing) {
      isResetStatsProcessing = true;
      pitchValue = 0;
      rollValue = 0;
      yawValue = 0;
      maxPitchValue = 0;
      maxRollValue = 0;
      maxYawValue = 0;
      minPitchValue = 0;
      minRollValue = 0;
      minYawValue = 0;
      pitchRecordCount = 0;
      rollRecordCount = 0;
      yawRecordCount = 0;
      pitchSpots.clear();
      rollSpots.clear();
      yawSpots.clear();
      pitchSpots = [FlSpot(0.0, 0.0)];
      rollSpots = [FlSpot(0.0, 0.0)];
      yawSpots = [FlSpot(0.0, 0.0)];
      if (write) {
        await peripheralResetCharacteristic!.write([1], withoutResponse: false).then((resetStatsResponse) {
          SnackBar snackBar = SnackBar(content: Text('Stats and chart data have been reset (local initiated)!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          isResetStatsProcessing = false;
        });
      } else {
        SnackBar snackBar = SnackBar(content: Text('Stats and chart data have been reset (remote initiated)!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        isResetStatsProcessing = false;
      }
    }
  }
  
  void updatePitchGauge() {
    if (pitchValue < 3 && pitchValue > -3) {
      pitchMeterImage = Image.asset(
        'assets/images/pitch_meter.png',
        width: 150,
        height: 150,
      );
    } else if (pitchValue > 3 && pitchValue < 7) {
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
    } else if (pitchValue < -3 && pitchValue > -7) {
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
  }

  void updateRollGauge() {
    if (rollValue < 2 && rollValue > -2) {
      rollMeterImage = Image.asset(
        'assets/images/roll_meter.png',
        width: 150,
        height: 150,
      );
    } else if (rollValue > 2 && rollValue < 5) {
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
    } else if (rollValue < -2 && rollValue > -5) {
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
  }

  void updateYawGauge() {

  }

  Future<void> showBluetoothUnavailableAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This app requires Bluetooth services to be available.'),
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
          title: const Text('Bluetooth Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Bluetooth is not accessible at the moment. This app requires Bluetooth to be enabled for wireless connection to the remote device and real-time monitoring.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go to Settings'),
              onPressed: () {
                Navigator.pop(context, 'Go to Settings');
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

  Future<void> cleanUp() async {
    engagePeriodicChartingActions(false);
    engagePeriodicLoggingActions(false);
    engagePeriodicReconnectActions(false);
    peripheralDevice?.bluetoothDevice?.disconnect();
    locationService = Location();
  }

  Future<bool> navigateBack() {
    Navigator.pop(context, '/Devices');
    return Future.value(true);
  }

}
