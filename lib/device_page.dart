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

  _waiting() {
    return const Center(
      child: Text('Cargando...', style: TextStyle(fontSize: 20.0)),
    );
  }

  _nivelDeposito(distancia) {
    double factDist = 0.0;
    if (distancia != "") {
      factDist = (27 - double.parse(distancia)) / 27;
      if (factDist < 0) {
        factDist = 0;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Container(
        width: double.infinity,
        // height: 250.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).backgroundColor,
            ])),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'Nivel de agua',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              LayoutBuilder(builder: (context, constraints) {
                return Container(
                  height: 20.0,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * factDist,
                    decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  _nivelCisterna(distancia) {
    bool isCorrect = false;
    bool thereWater = false;
    if (distancia != "") {
      if (double.parse(distancia) < 25) {
        thereWater = true;
      } else {
        thereWater = false;
      }
      isCorrect = true;
    }
    return isCorrect
        ? Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
            child: Row(
              children: [
                Text(
                  '${thereWater ? "Sí" : "No"} hay agua en la cisterna',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: thereWater ? Colors.blueAccent : Colors.red,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox(height: 31.0);
  }

  _pH(phValue) {
    double ph = 0;
    if (phValue != "") {
      ph = double.parse(phValue);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Container(
        width: double.infinity,
        // height: 250.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).backgroundColor,
            ])),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'Nivel de pH',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                '${ph.ceil()}',
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _turb(turbValue) {
    double ph = 0;
    if (turbValue != "") {
      ph = double.parse(turbValue);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).backgroundColor,
            ])),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'Nivel de turbidez',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                '${ph.ceil()}',
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _appBar(),
                ),
                isReady ? _widgetsIoT() : _waiting(),
              ],
            ),
          ),
        ));
  }

  Widget _appBar() {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.arrow_back_ios),
        const SizedBox(width: 10.0),
        const Text(
          'Depósito de agua',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Expanded(child: SizedBox()),
        StreamBuilder<BluetoothDeviceState>(
          stream: widget.device.state,
          initialData: BluetoothDeviceState.connecting,
          builder: (c, snapshot) {
            VoidCallback? onPressed;
            Color color;
            switch (snapshot.data) {
              case BluetoothDeviceState.connected:
                onPressed = () {
                  widget.device.disconnect();
                  nextScreenReplace(
                    context,
                    const ConnectToDevice(),
                    PageTransitionType.leftToRight,
                  );
                };
                color = Colors.red;
                break;
              case BluetoothDeviceState.disconnected:
                onPressed = () => widget.device.connect();
                color = Colors.green;
                break;
              default:
                onPressed = null;
                color = Colors.white;
                break;
            }
            return IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.power_settings_new_rounded,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _widgetsIoT() {
    return Column(
      children: [
        StreamBuilder(
          stream: streamSR0401,
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasError) {
              return Text('error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data!);
              return _nivelDeposito(currentValue);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            return const Text('Check the stream');
          },
        ),
        StreamBuilder(
          stream: streamSR0402,
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasError) {
              return Text('error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data!);
              return _nivelCisterna(currentValue);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            return const Text('Check the stream');
          },
        ),
        StreamBuilder(
          stream: streamPH,
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasError) {
              return Text('error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data!);
              return _pH(currentValue);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            return const Text('Check the stream');
          },
        ),
        StreamBuilder(
          stream: streamTurb,
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasError) {
              return Text('error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data!);
              return _turb(currentValue);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            return const Text('Check the stream');
          },
        ),
      ],
    );
  }
}
