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
  final String characteristicUuid = "ca73b3ba-39f6-4ab3-91ae-186dc9577d99";
  late bool isReady;
  late Stream<List<int>> stream;

  @override
  void initState() {
    super.initState();
    isReady = false;
    discoverServices();
  }

  discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUuid) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

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
          ? const Center(child: Text('waiting...'))
          : StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasError) {
                  return Text('error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  var currenValue = _dataParser(snapshot.data!);
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Distancia:'),
                      Text('$currenValue cm'),
                    ],
                  ));
                }
                return const Text('Check the stream');
              },
            ),
    );
  }
}
