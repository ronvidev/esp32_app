import 'package:flutter/material.dart';

class VelocidadTile extends StatelessWidget {
  const VelocidadTile(this.velocidad, {super.key});

  final double velocidad;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Velocidad', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 5.0),
        Text('${velocidad.toStringAsFixed(1)} Lt/s',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
