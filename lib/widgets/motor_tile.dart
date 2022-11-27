import 'package:flutter/material.dart';

class MotorTile extends StatelessWidget {
  const MotorTile(this.state, this.color, {super.key});

  final bool state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Motor', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 5.0),
            Text(
              state == true ? 'Encendido' : 'Apagado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12.0,
          height: 30.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: color,
          ),
        ),
      ],
    );
  }
}
