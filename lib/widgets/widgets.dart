export 'cisterna_tile.dart';
export 'motor_tile.dart';
export 'next_screen.dart';
export 'target_widget.dart';
export 'velocidad_tile.dart';
export 'turbidez_tile.dart';
export 'ph_tile.dart';
export 'deposito_tile.dart';

import 'package:flutter/material.dart';

Widget gridList(List<Widget> lista) {
  return Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: lista[0],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: lista[1],
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: lista[2],
              ),
            ),
            Expanded(
              child:
                  Padding(padding: const EdgeInsets.all(6.0), child: lista[3]),
            ),
          ],
        ),
      ),
    ],
  );
}
