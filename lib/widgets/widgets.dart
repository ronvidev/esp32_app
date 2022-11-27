import 'package:flutter/material.dart';

BorderRadius borderRadius = BorderRadius.circular(24.0);

Widget target(BuildContext context, String title, content, {height}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
          child: Text(title, style: Theme.of(context).textTheme.labelMedium),
        ),
        height == null
            ? Expanded(
                child: Container(
                  width: double.maxFinite,
                  decoration: decorationFront,
                  child: content,
                ),
              )
            : Container(
                height: height,
                decoration: decorationFront,
                child: content,
              ),
      ]),
    ),
  );
}

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
