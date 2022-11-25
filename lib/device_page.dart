import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/widgets/next_screen.dart';
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
  late Stream<List<int>> streamSR0402;
  late Stream<List<int>> streamPH;
  late Stream<List<int>> streamTurb;
  late bool isReady;
  double velocidad = 0.0;
  double distAct = 0.0;
  double distAnt = 0.0;

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

    return Container(
      width: 90.0,
      height: 367.0,
      decoration: _boxDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _text('Nivel', 18.0, FontWeight.normal),
            const SizedBox(height: 10.0),
            _text('${(factDist * 100).round()} %', 20.0, FontWeight.bold),
            const SizedBox(height: 10.0),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: 50.0,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: AnimatedContainer(
                    curve: Curves.easeInOutQuart,
                    duration: const Duration(milliseconds: 800),
                    height: constraints.maxHeight * factDist,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  _velocidad(distancia) {
    if (distancia != "") {
      velocidad = (distAct - distAnt).abs() * 0.4815;
      distAnt = distAct;
    }
    return Expanded(
      flex: 5,
      child: Container(
        height: 80.0,
        decoration: _boxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text('Velocidad', 18.0, FontWeight.normal),
              const Expanded(child: SizedBox()),
              _text('${velocidad.toStringAsFixed(1)} Lt/s', 20.0,
                  FontWeight.bold),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  _motor() {
    return Expanded(
      flex: 5,
      child: Container(
        height: 80.0,
        decoration: _boxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _text('Motor', 18.0, FontWeight.normal),
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              _text('Apagado', 20.0, FontWeight.bold),
            ],
          ),
        ),
      ),
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
    return Container(
      height: 80.0,
      decoration: _boxDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text('Cisterna ', 18.0, FontWeight.normal),
                const SizedBox(height: 5.0),
                isCalculated
                    ? _text(
                        '${thereWater ? "Agua" : "Sin agua"} disponible',
                        20.0,
                        FontWeight.bold,
                      )
                    : _text('Calculando...', 20.0, FontWeight.bold)
              ],
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pH(phValue) {
    double levelPH = 0;
    String pH = 'Calculando...';
    if (phValue != "") {
      levelPH = double.parse(phValue);
      levelPH = 4;
      if (levelPH < 6.5) {
        pH = 'Ácido';
      } else if (levelPH <= 9.5) {
        pH = 'Neutral';
      } else {
        pH = 'Alcalino';
      }
    }
    return Container(
      height: 90.0,
      decoration: _boxDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _text('pH', 18.0, FontWeight.normal),
                const SizedBox(width: 8.0),
                _text(pH, 20.0, FontWeight.bold),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 5.0),
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 10.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          gradient: const LinearGradient(colors: [
                            Colors.red,
                            Colors.green,
                            Colors.deepPurple
                          ]),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        left: (constraints.maxWidth * (levelPH / 14)) - 5.0,
                        child: Container(
                          height: 20.0,
                          width: 10.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  );
                })),
                const SizedBox(width: 18.0),
                SizedBox(
                    width: 45, child: _text('$levelPH', 20.0, FontWeight.bold)),
              ],
            ),
          ],
        ),
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
    return Container(
      height: 80.0,
      decoration: _boxDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _text('Turbidez', 18.0, FontWeight.normal),
                const SizedBox(height: 5.0),
                _text(turbidez, 20.0, FontWeight.bold),
              ],
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: color,
              ),
            ),
          ],
        ),
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
              Expanded(child: isReady ? _widgetsIoT() : _waiting()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 8.0, top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Depósito de agua',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            ],
          ),
          _text('Tinaco (1100 L)', 16.0, FontWeight.bold),
        ],
      ),
    );
  }

  Widget _widgetsIoT() {
    final broadcastStream = streamSR0401.asBroadcastStream();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _widget(broadcastStream, _nivelDeposito),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _widget(broadcastStream, _velocidad),
                  const SizedBox(width: 12.0),
                  _motor(),
                ]),
                const SizedBox(height: 12.0),
                _widget(streamSR0402, _nivelCisterna),
                const SizedBox(height: 12.0),
                _widget(streamPH, _pH),
                const SizedBox(height: 12.0),
                _widget(streamTurb, _turb),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18.0),
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        colors: [
          Theme.of(context).canvasColor,
          Theme.of(context).primaryColor,
        ],
      ),
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
