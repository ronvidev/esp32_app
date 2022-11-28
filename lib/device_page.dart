import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert' show utf8;

import 'package:page_transition/page_transition.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    Key? key,
    required this.device,
    required this.isConnected,
  }) : super(key: key);

  final BluetoothDevice device;
  final bool isConnected;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final String serviceUuid = "91bad492-b950-4226-aa2b-4ede9fa42f59";
  final String serviceMotorUuid = "c345c464-6ea2-11ed-a1eb-0242ac120002";
  final String charactSR0401Uuid = "ca73b3ba-39f6-4ab3-91ae-186dc9577d99";
  final String charactSR0402Uuid = "3c49eb0c-abca-40b5-8ebe-368bd46a7e5e";
  final String charactPHUuid = "96f89428-696a-11ed-a1eb-0242ac120002";
  final String charactTurbUuid = "cadf63e3-63ea-4626-9667-e2594d0bf4ae";
  final String charactMotorUuid = "d5da51ac-6e99-11ed-a1eb-0242ac120002";
  late Stream<List<int>> streamSR0401;
  late Stream<List<int>> broadcastStream;
  late Stream<List<int>> streamSR0402;
  late Stream<List<int>> streamPH;
  late Stream<List<int>> streamTurb;
  late Stream<List<int>> streamMotor;
  late bool isReady;
  double velocidad = 0.0;
  double distAct = 0.0;
  double distAnt = 0.0;

  late List<Widget> listWidgets = [
    Target(title: 'Nivel', content: _widget(broadcastStream, _nivelDeposito)),
    Target(title: 'pH', content: _widget(streamPH, _pH)),
    Target(title: 'Otros datos', content: _widgetsColumn()),
    Target(title: 'Turbidez', content: _widget(streamTurb, _turb)),
  ];

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectDevice();
  }

  void connectDevice() async {
    if (!widget.isConnected) {
      await widget.device.connect().whenComplete(() => discoverServices());
    } else {
      discoverServices();
    }
  }

  void discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == charactSR0401Uuid) {
            streamSR0401 = characteristic.value;
            broadcastStream = streamSR0401.asBroadcastStream();
          }
          if (characteristic.uuid.toString() == charactSR0402Uuid) {
            streamSR0402 = characteristic.value;
          }
          if (characteristic.uuid.toString() == charactPHUuid) {
            streamPH = characteristic.value;
          }
          if (characteristic.uuid.toString() == charactTurbUuid) {
            streamTurb = characteristic.value;
          }
          if (characteristic.uuid.toString() == charactMotorUuid) {
            streamMotor = characteristic.value;
          }
          await characteristic.setNotifyValue(!characteristic.isNotifying);
        }
      }
      if (service.uuid.toString() == serviceMotorUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == charactMotorUuid) {
            streamMotor = characteristic.value;
            isReady = true;
            setState(() {});
          }
          await characteristic.setNotifyValue(!characteristic.isNotifying);
        }
      }
    }
  }

  Widget _nivelDeposito(distancia) {
    double factDist = 0.0;
    if (distancia != "") {
      distAct = double.parse(distancia);
      factDist = (25 - distAct + 3) / 25; // 3 tolerancia sensor
      if (factDist < 0) factDist = 0;
    }

    return DepositoTile(factDist);
  }

  Widget _pH(phValue) {
    double levelPH = 0;
    String pH = 'Calculando...';
    if (phValue != "") {
      levelPH = double.parse(phValue);
      if (levelPH < 6.5) {
        pH = 'Ácido';
      } else if (levelPH < 8.5) {
        pH = 'Aceptable';
      } else {
        pH = 'Alcalino';
      }
    }
    return PHTile(levelPH, pH);
  }

  Widget _motor(stateMotor) {
    bool state = false;
    Color color = Colors.transparent;
    if (stateMotor != '') {
      state = int.parse(stateMotor) == 1 ? true : false;
      color = state == true ? Colors.lime : Colors.red;
    }
    return MotorTile(state, color);
  }

  Widget _velocidad(distancia) {
    if (distancia != "") {
      velocidad = (distAct - distAnt).abs() * 0.4815;
      distAnt = distAct;
    }
    return VelocidadTile(velocidad);
  }

  Widget _cisterna(distancia) {
    bool thereWater = false;
    Color color = Colors.transparent;
    bool isCalculated = false;
    if (distancia != "") {
      if (double.parse(distancia) < 25) {
        thereWater = true;
        color = Colors.lightBlue;
      } else {
        thereWater = false;
        color = Colors.red;
      }
      isCalculated = true;
    }
    return CisternaTile(thereWater, color, isCalculated);
  }

  Widget _turb(turbValue) {
    double turbVolt = 0;
    String turbidez = 'Cargando...';
    Color color = Colors.transparent;
    if (turbValue != "") {
      turbVolt = double.parse(turbValue);
      if (turbVolt < 2) {
        turbidez = 'Agua muy opaca';
        color = Colors.brown;
      } else if (turbVolt < 3) {
        turbidez = 'Agua opaca';
        color = const Color.fromARGB(255, 29, 171, 171);
      } else if (turbVolt < 4) {
        turbidez = 'Aceptable';
        color = Colors.lightBlueAccent;
      } else {
        turbidez = 'Agua muy limpia';
        color = Colors.lightBlue;
      }
    }
    return TurbidezTile(turbidez, color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              _appBar(),
              Expanded(child: isReady ? gridList(listWidgets) : _waiting()),
              Text(
                'Aplicación demostrativa',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            Text(
              'Depósito de agua',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text('ESP32 - Demo (23 L)',
                style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
        const Expanded(child: SizedBox()),
        StreamBuilder<BluetoothDeviceState>(
          stream: widget.device.state,
          initialData: BluetoothDeviceState.connecting,
          builder: (c, snapshot) {
            VoidCallback? onPressed;
            Color color = Colors.white;
            if (snapshot.data == BluetoothDeviceState.connecting) {
              onPressed = null;
              color = Colors.white;
            } else if (snapshot.data == BluetoothDeviceState.connected) {
              onPressed = () {
                widget.device.disconnect();
                nextScreenReplace(
                  context,
                  const ConnectToDevice(),
                  PageTransitionType.leftToRight,
                );
              };
              color = Colors.red;
            }
            return IconButton(
              iconSize: 28.0,
              onPressed: onPressed,
              icon: Icon(
                Icons.power_settings_new_rounded,
                color: color,
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _widget(Stream<List<int>> stream, Function widget) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          var currentValue = _dataParser(snapshot.data!);
          return widget(currentValue);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        }
        return const Text('Check the stream');
      },
    );
  }

  _widgetsColumn() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _widget(streamMotor, _motor),
        Divider(thickness: 1, color: Colors.blueGrey[350]),
        _widget(broadcastStream, _velocidad),
        Divider(thickness: 1, color: Colors.blueGrey[350]),
        _widget(streamSR0402, _cisterna),
      ]),
    );
  }

  _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  _waiting() {
    return const Center(child: CircularProgressIndicator());
  }
}
