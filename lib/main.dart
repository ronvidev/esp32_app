import 'dart:async';
import 'dart:io';

import 'package:esp32_app/device_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'widgets.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const ConnectToDevice();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.instance.turnOn()
                  : null,
              child: const Text('TURN ON'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectToDevice extends StatelessWidget {
  const ConnectToDevice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: FlutterBluePlus.instance.connectedDevices.asStream(),
      initialData: const [],
      builder: (c, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('ESP32')),
          body: Column(
            children: <Widget>[
              Column(
                children: snapshot.data!
                    .map((d) => ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.id.toString()),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              if (snapshot.data ==
                                  BluetoothDeviceState.connected) {
                                return ElevatedButton(
                                  child: const Text('OPEN'),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeviceScreen(device: d),
                                    ),
                                  ),
                                );
                              }
                              return Text(snapshot.data.toString());
                            },
                          ),
                        ))
                    .toList(),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) {
                          return ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            return DeviceScreen(device: r.device);
                          })),
                        );
                        },
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          floatingActionButton: StreamBuilder<bool>(
            stream: FlutterBluePlus.instance.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data!) {
                return FloatingActionButton(
                  onPressed: () => FlutterBluePlus.instance.stopScan(),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.stop),
                );
              } else {
                return FloatingActionButton(
                  child: const Icon(Icons.search),
                  onPressed: () => FlutterBluePlus.instance
                      .startScan(timeout: const Duration(seconds: 4)),
                );
              }
            },
          ),
        );
      },
    );
  }
}
