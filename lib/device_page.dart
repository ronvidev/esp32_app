import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/widgets/next_screen.dart';
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
  final String charactSR0401Uuid = "ca73b3ba-39f6-4ab3-91ae-186dc9577d99";
  final String charactSR0402Uuid = "3c49eb0c-abca-40b5-8ebe-368bd46a7e5e";
  final String charactPHUuid = "96f89428-696a-11ed-a1eb-0242ac120002";
  final String charactTurbUuid = "cadf63e3-63ea-4626-9667-e2594d0bf4ae";
  late Stream<List<int>> streamSR0401;
  late Stream<List<int>> broadcastStream;
  late Stream<List<int>> streamSR0402;
  late Stream<List<int>> streamPH;
  late Stream<List<int>> streamTurb;
  late bool isReady;
  double velocidad = 0.0;
  double distAct = 0.0;
  double distAnt = 0.0;

  late List<Widget> listWidgets = [
    target(context, 'Nivel', _widget(broadcastStream, _nivelDeposito)),
    target(context, 'Otros datos', _widgetsColumn()),
    target(context, 'pH', _widget(streamPH, _pH)),
    target(context, 'Turbidez', _widget(streamTurb, _turb)),
  ];

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectDevice();
  }

  connectDevice() async {
    if (!widget.isConnected) {
      await widget.device.connect().whenComplete(() => discoverServices());
    } else {
      discoverServices();
    }
  }

  discoverServices() async {
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
          await characteristic.setNotifyValue(!characteristic.isNotifying);
        }
        setState(() {
          isReady = true;
        });
      }
    }
  }

  _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  _nivelDeposito(distancia) {
    double factDist = 0.0;
    if (distancia != "") {
      distAct = double.parse(distancia);
      factDist = (25 - distAct + 3) / 25; // 3 tolerancia sensor
      if (factDist < 0) factDist = 0;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _text('${(factDist * 100).round()} %', 20.0, FontWeight.bold),
          const SizedBox(height: 10.0),
          Expanded(
            child: ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(15.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: AnimatedContainer(
                    curve: Curves.easeInOutQuart,
                    duration: const Duration(milliseconds: 800),
                    height: constraints.maxHeight * factDist,
                    decoration: BoxDecoration(
                        color: factDist < 0.2 ? Colors.red : Colors.lightBlue,
                        borderRadius: BorderRadius.circular(1.0)),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  _velocidad(distancia) {
    if (distancia != "") {
      velocidad = (distAct - distAnt).abs() * 0.4815;
      distAnt = distAct;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text('Velocidad', 14.0, FontWeight.normal),
        const SizedBox(height: 5.0),
        _text('${velocidad.toStringAsFixed(1)} Lt/s', 18.0, FontWeight.bold),
      ],
    );
  }

  _motor() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _text('Motor', 14.0, FontWeight.normal),
            const SizedBox(height: 5.0),
            _text('Apagado', 18.0, FontWeight.bold),
          ],
        ),
        Container(
          width: 12.0,
          height: 30.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  _nivelCisterna(distancia) {
    bool isCalculated = false;
    bool thereWater = false;
    Color color = Colors.white;
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text('Cisterna', 14.0, FontWeight.normal),
              const SizedBox(height: 5.0),
              isCalculated
                  ? _text(
                      '${thereWater ? "Agua" : "Sin agua"} disponible',
                      18.0,
                      FontWeight.bold,
                    )
                  : _text('Calculando...', 18.0, FontWeight.bold)
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 15.0,
          height: 38.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _pH(phValue) {
    double levelPH = 0;
    String pH = 'Calculando...';
    if (phValue != "") {
      levelPH = double.parse(phValue);
      levelPH = 9;
      if (levelPH < 6.5) {
        pH = 'Ácido';
      } else if (levelPH <= 9.5) {
        pH = 'Neutral';
      } else {
        pH = 'Alcalino';
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _text('$levelPH', 32.0, FontWeight.bold),
          _text(pH, 20.0, FontWeight.bold),
          const SizedBox(height: 16.0),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 20.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.red, Colors.green, Colors.deepPurple],
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  bottom: (constraints.maxHeight * (levelPH / 14)) - 5,
                  child: Container(
                    height: 15.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            );
          })),
        ],
      ),
    );
  }

  Widget _turb(turbValue) {
    double turbVolt = 0;
    String turbidez = 'Cargando...';
    Color color = Colors.white;
    if (turbValue != "") {
      turbVolt = double.parse(turbValue);
      turbVolt = 5;
      if (turbVolt < 4) {
        turbidez = 'Agua sucia';
        color = Colors.green;
      } else if (turbVolt < 5) {
        turbidez = 'Aceptable';
        color = Colors.lightBlueAccent;
      } else {
        turbidez = 'Agua limpia';
        color = Colors.lightBlue;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            color: Colors.red,
            height: 60.0,
            child: Center(child: Text(turbidez, style: Theme.of(context).textTheme.bodyLarge)),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
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
                style: Theme.of(context).textTheme.bodySmall,
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
            _text('1 100L', 16.0, FontWeight.bold),
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

  Widget _widgetsColumn() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _motor(),
        Divider(thickness: 2.0, color: Theme.of(context).backgroundColor),
        _widget(broadcastStream, _velocidad),
        Divider(thickness: 2.0, color: Theme.of(context).backgroundColor),
        _widget(streamSR0402, _nivelCisterna),
      ]),
    );
  }

  BoxDecoration _boxDecoration(context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18.0),
      color: Theme.of(context).canvasColor,
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

  Widget _text(String text, double size, FontWeight weight) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }

  _waiting() {
    return const Center(child: CircularProgressIndicator());
  }
}
