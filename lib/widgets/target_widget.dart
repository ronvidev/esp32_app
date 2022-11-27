import 'package:flutter/material.dart';

class Target extends StatefulWidget {
  const Target({
    super.key,
    required this.title,
    required this.content,
    this.height,
  });

  final String title;
  final Widget content;
  final dynamic height;

  @override
  State<Target> createState() => _TargetState();
}

class _TargetState extends State<Target> {
  BorderRadius borderRadius = BorderRadius.circular(24.0);
  @override
  Widget build(BuildContext context) {
    BoxDecoration decorationBack = BoxDecoration(
      color: Theme.of(context).primaryColor,
    );
    BoxDecoration decorationFront = BoxDecoration(
      color: Theme.of(context).canvasColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
    );

    return ClipRRect(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderRadius: borderRadius,
      child: Container(
        decoration: decorationBack,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 3.0),
            child: Text(widget.title,
                style: Theme.of(context).textTheme.labelMedium),
          ),
          widget.height == null
              ? Expanded(
                  child: Container(
                    width: double.maxFinite,
                    decoration: decorationFront,
                    child: widget.content,
                  ),
                )
              : Container(
                  height: widget.height,
                  decoration: decorationFront,
                  child: widget.content,
                ),
        ]),
      ),
    );
  }
}
