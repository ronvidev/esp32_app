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
  final String characteristicSR04Uuid = "ca73b3ba-39f6-4ab3-91ae-186dc9577d99";
  late bool isReady;
  late Stream<List<int>> streamSR04;

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
          if (characteristic.uuid.toString() == characteristicSR04Uuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            streamSR04 = characteristic.value;

            setState(() {
              isReady = true;
            });
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

  _distanciaDeposito(distancia) {
    return Container(
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
                  'Distancia (depósito)',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0,),
            Text(
              '$distancia cm',
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
          : Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  StreamBuilder(
                    stream: streamSR04,
                    builder: (context, AsyncSnapshot<List<int>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.active) {
                        var currentValue = _dataParser(snapshot.data!);
                        return _distanciaDeposito(currentValue);
                      }
                      return const Text('Check the stream');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
