import 'package:flutter/material.dart';

class TurbidezTile extends StatelessWidget {
  const TurbidezTile(this.turbidez,this.color,{super.key});

  final String turbidez;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 55.0,
            width: 115.0,
            child: Center(
              child: Text(
                turbidez,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
