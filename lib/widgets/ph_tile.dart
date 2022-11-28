import 'package:flutter/material.dart';

class PHTile extends StatelessWidget {
  const PHTile(this.levelPH, this.pH,{super.key});

  final double levelPH;
  final String pH;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(levelPH.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyLarge),
          Text(pH, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16.0),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 20.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.red, Colors.green, Colors.deepPurple],
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  bottom: (constraints.maxHeight * (levelPH / 14)) - 5,
                  child: Container(
                    height: 15.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            );
          })),
        ],
      ),
    );
  }
}
