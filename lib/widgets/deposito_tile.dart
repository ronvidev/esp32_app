

import 'package:flutter/material.dart';

class DepositoTile extends StatelessWidget {
  const DepositoTile(this.factDist,{super.key});

  final double factDist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${(factDist * 100).round()} %',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10.0),
          Expanded(
            child: ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(15.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: AnimatedContainer(
                    curve: Curves.easeInOutQuart,
                    duration: const Duration(milliseconds: 800),
                    height: constraints.maxHeight * factDist,
                    decoration: BoxDecoration(
                        color: factDist < 0.2 ? Colors.red : Colors.lightBlue,
                        borderRadius: BorderRadius.circular(1.0)),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}