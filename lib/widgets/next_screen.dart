import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// void nextScreen(context, page, transition) {
//   Navigator.push(
//     context,
//     PageTransition(
//       duration: const Duration(milliseconds: 800),
//       reverseDuration: const Duration(milliseconds: 300),
//       curve: Curves.easeOutQuint,
//       type: transition,
//       child: page,
//     ),
//   );
// }

void nextScreenReplace(context, page, transition) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        animation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
        );
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
    ),
  );
}
