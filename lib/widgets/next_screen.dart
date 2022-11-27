import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void nextScreen(context, page, transition) {
  Navigator.push(
    context,
    PageTransition(
      opaque: true,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      type: transition,
      child: page,
    ),
  );
}

void nextScreenReplace(context, page, transition) {
  Navigator.pushReplacement(
    context,
    PageTransition(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      curve: const ElasticInCurve(),
      type: transition,
      child: page,
    ),
  );
}

void previousScreen(context) {
  Navigator.pop(context);
}