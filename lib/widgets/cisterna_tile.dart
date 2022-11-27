import 'package:flutter/material.dart';

class CisternaTile extends StatelessWidget {
  const CisternaTile(this.thereWater, this.color, this.isCalculated, {super.key});

  final bool thereWater;
  final Color color;
  final bool isCalculated;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cisterna', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 5.0),
              isCalculated
                  ? Text(
                      '${thereWater ? "Agua" : "Sin agua"} disponible',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Text('Calculando...',
                      style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 15.0,
          height: 38.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: color,
          ),
        ),
      ],
    );
  }
}
