import 'package:esp32_app/device_page.dart';
import 'package:esp32_app/widgets/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectToDevice extends StatefulWidget {
  const ConnectToDevice({Key? key}) : super(key: key);

  @override
  State<ConnectToDevice> createState() => _ConnectToDeviceState();
}

class _ConnectToDeviceState extends State<ConnectToDevice> {
  final BorderRadius _borderRadius = BorderRadius.circular(24.0);
  @override
  void initState() {
    super.initState();
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18.0),
                child: Text(
                  'Conectar dispositivo',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: _borderRadius,
                ),
                height: 300.0,
                child: ClipRRect(
                  borderRadius: _borderRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: listDevices(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textBubble(BuildContext context, String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget listDevices() {
    return RefreshIndicator(
      color: Theme.of(context).focusColor,
      displacement: 20.0,
      onRefresh: () => FlutterBluePlus.instance
          .startScan(timeout: const Duration(seconds: 1)),
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: [
          Column(
            children: <Widget>[
              _devicesConnected(),
              _deviceScanned(),
            ],
          )
        ],
      ),
    );
  }

  Widget _devicesConnected() {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: FlutterBluePlus.instance.connectedDevices.asStream(),
      initialData: const [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map((d) => ListTile(
                  title: Text(d.name),
                  subtitle: const Text('Conectado'),
                  trailing: StreamBuilder<BluetoothDeviceState>(
                    stream: d.state,
                    initialData: BluetoothDeviceState.disconnected,
                    builder: (c, snapshot) {
                      if (snapshot.data == BluetoothDeviceState.connected) {
                        return ElevatedButton(
                          child: const Text('ABRIR'),
                          onPressed: () => nextScreenReplace(
                            context,
                            DeviceScreen(device: d),
                          ),
                        );
                      }
                      return Text(snapshot.data.toString());
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _deviceScanned() {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.instance.scanResults,
      initialData: const [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map((r) => ListTile(
                  title: Text(r.device.name),
                  subtitle: Text(r.device.id.toString()),
                  trailing: ElevatedButton(
                    child: const Text('Conectar'),
                    onPressed: () {
                      r.device.connect();
                      nextScreenReplace(
                        context,
                        DeviceScreen(device: r.device),
                      );
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }
}