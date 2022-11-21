import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert' show utf8;

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final String serviceUuid = "91bad492-b950-4226-aa2b-4ede9fa42f59";
  final String charactSR0401Uuid = "ca73b3ba-39f6-4ab3-91ae-186dc9577d99";
  final String charactSR0402Uuid = "3c49eb0c-abca-40b5-8ebe-368bd46a7e5e";
  final String charactPHUuid = "96f89428-696a-11ed-a1eb-0242ac120002";
  late bool isReady;
  late Stream<List<int>> streamSR0401;
  late Stream<List<int>> streamSR0402;
  late Stream<List<int>> streamPH;

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectDevice();
  }

  connectDevice() async {
    await widget.device.connect().whenComplete(() => discoverServices());
  }

  discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == charactSR0401Uuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            streamSR0401 = characteristic.value;
            setState(() {
              isReady = true;
            });
          }
          if (characteristic.uuid.toString() == charactSR0402Uuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            streamSR0402 = characteristic.value;
          }
          if (characteristic.uuid.toString() == charactPHUuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            streamPH = characteristic.value;
          }
        }
      }
    }
  }

  _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  _waiting() {
    return const Center(
      child: Text('Cargando...', style: TextStyle(fontSize: 24.0)),
    );
  }

  _nivelDeposito(distancia) {
    double factDist = 0.0;
    if (distancia != "") {
      factDist = (140 - double.parse(distancia)) / 135;
      if (factDist < 0) {
        factDist = 0;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(18.0),
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
      if (double.parse(distancia) < 135) {
        thereWater = true;
      } else {
        thereWater = false;
      }
      isCorrect = true;
    }
    return isCorrect
        ? Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 36.0, vertical: 5.0),
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
    if(phValue != ""){
      ph = double.parse(phValue);
    }
    return Padding(
      padding: const EdgeInsets.all(18.0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: !isReady
          ? _waiting()
          : Column(
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
                    return const Text('Check the stream');
                  },
                ),
                const Expanded(child: SizedBox())
              ],
            ),
    );
  }
}
