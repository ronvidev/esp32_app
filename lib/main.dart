import 'package:esp32_app/device_page.dart';
import 'package:esp32_app/screens/bluetooth_disable.dart';
import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
    statusBarIconBrightness: Brightness.dark, // color icons
  ));
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBluePlus.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return stateDevice();
          }
          return BluetoothOffScreen(state: state);
        },
      ),
    );
  }

  stateDevice() {
    dynamic disp;
    return StreamBuilder<List<BluetoothDevice>>(
      stream: FlutterBluePlus.instance.connectedDevices.asStream(),
      initialData: const [],
      builder: (c, snapshot) {
        List<BluetoothDevice> data = snapshot.data!;
        for (var element in data) {
          disp = element;
        }
        return data.isNotEmpty
            ? DeviceScreen(device: disp, isConnected: true)
            : const ConnectToDevice();
      },
    );
  }
}
